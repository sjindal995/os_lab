
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
  8000dc:	c7 44 24 08 ca 14 80 	movl   $0x8014ca,0x8(%esp)
  8000e3:	00 
  8000e4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000eb:	00 
  8000ec:	c7 04 24 e7 14 80 00 	movl   $0x8014e7,(%esp)
  8000f3:	e8 f7 03 00 00       	call   8004ef <_panic>

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
}
  8004a9:	c9                   	leave  
  8004aa:	c3                   	ret    

008004ab <sys_guest>:

void sys_guest(){
  8004ab:	55                   	push   %ebp
  8004ac:	89 e5                	mov    %esp,%ebp
  8004ae:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_guest, 0, 0, 0, 0, 0, 0);
  8004b1:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8004b8:	00 
  8004b9:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8004c0:	00 
  8004c1:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8004c8:	00 
  8004c9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004d0:	00 
  8004d1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004d8:	00 
  8004d9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004e0:	00 
  8004e1:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
  8004e8:	e8 b5 fb ff ff       	call   8000a2 <syscall>
  8004ed:	c9                   	leave  
  8004ee:	c3                   	ret    

008004ef <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004ef:	55                   	push   %ebp
  8004f0:	89 e5                	mov    %esp,%ebp
  8004f2:	53                   	push   %ebx
  8004f3:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8004f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8004f9:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004fc:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800502:	e8 c5 fc ff ff       	call   8001cc <sys_getenvid>
  800507:	8b 55 0c             	mov    0xc(%ebp),%edx
  80050a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80050e:	8b 55 08             	mov    0x8(%ebp),%edx
  800511:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800515:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800519:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051d:	c7 04 24 f8 14 80 00 	movl   $0x8014f8,(%esp)
  800524:	e8 e1 00 00 00       	call   80060a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800529:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80052c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800530:	8b 45 10             	mov    0x10(%ebp),%eax
  800533:	89 04 24             	mov    %eax,(%esp)
  800536:	e8 6b 00 00 00       	call   8005a6 <vcprintf>
	cprintf("\n");
  80053b:	c7 04 24 1b 15 80 00 	movl   $0x80151b,(%esp)
  800542:	e8 c3 00 00 00       	call   80060a <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800547:	cc                   	int3   
  800548:	eb fd                	jmp    800547 <_panic+0x58>

0080054a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80054a:	55                   	push   %ebp
  80054b:	89 e5                	mov    %esp,%ebp
  80054d:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800550:	8b 45 0c             	mov    0xc(%ebp),%eax
  800553:	8b 00                	mov    (%eax),%eax
  800555:	8d 48 01             	lea    0x1(%eax),%ecx
  800558:	8b 55 0c             	mov    0xc(%ebp),%edx
  80055b:	89 0a                	mov    %ecx,(%edx)
  80055d:	8b 55 08             	mov    0x8(%ebp),%edx
  800560:	89 d1                	mov    %edx,%ecx
  800562:	8b 55 0c             	mov    0xc(%ebp),%edx
  800565:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800569:	8b 45 0c             	mov    0xc(%ebp),%eax
  80056c:	8b 00                	mov    (%eax),%eax
  80056e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800573:	75 20                	jne    800595 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800575:	8b 45 0c             	mov    0xc(%ebp),%eax
  800578:	8b 00                	mov    (%eax),%eax
  80057a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80057d:	83 c2 08             	add    $0x8,%edx
  800580:	89 44 24 04          	mov    %eax,0x4(%esp)
  800584:	89 14 24             	mov    %edx,(%esp)
  800587:	e8 77 fb ff ff       	call   800103 <sys_cputs>
		b->idx = 0;
  80058c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80058f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800595:	8b 45 0c             	mov    0xc(%ebp),%eax
  800598:	8b 40 04             	mov    0x4(%eax),%eax
  80059b:	8d 50 01             	lea    0x1(%eax),%edx
  80059e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005a1:	89 50 04             	mov    %edx,0x4(%eax)
}
  8005a4:	c9                   	leave  
  8005a5:	c3                   	ret    

008005a6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8005a6:	55                   	push   %ebp
  8005a7:	89 e5                	mov    %esp,%ebp
  8005a9:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8005af:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8005b6:	00 00 00 
	b.cnt = 0;
  8005b9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8005c0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8005c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8005cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005d1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005db:	c7 04 24 4a 05 80 00 	movl   $0x80054a,(%esp)
  8005e2:	e8 bd 01 00 00       	call   8007a4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005e7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8005ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005f7:	83 c0 08             	add    $0x8,%eax
  8005fa:	89 04 24             	mov    %eax,(%esp)
  8005fd:	e8 01 fb ff ff       	call   800103 <sys_cputs>

	return b.cnt;
  800602:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800608:	c9                   	leave  
  800609:	c3                   	ret    

0080060a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80060a:	55                   	push   %ebp
  80060b:	89 e5                	mov    %esp,%ebp
  80060d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800610:	8d 45 0c             	lea    0xc(%ebp),%eax
  800613:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800616:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800619:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061d:	8b 45 08             	mov    0x8(%ebp),%eax
  800620:	89 04 24             	mov    %eax,(%esp)
  800623:	e8 7e ff ff ff       	call   8005a6 <vcprintf>
  800628:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  80062b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80062e:	c9                   	leave  
  80062f:	c3                   	ret    

00800630 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800630:	55                   	push   %ebp
  800631:	89 e5                	mov    %esp,%ebp
  800633:	53                   	push   %ebx
  800634:	83 ec 34             	sub    $0x34,%esp
  800637:	8b 45 10             	mov    0x10(%ebp),%eax
  80063a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800643:	8b 45 18             	mov    0x18(%ebp),%eax
  800646:	ba 00 00 00 00       	mov    $0x0,%edx
  80064b:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80064e:	77 72                	ja     8006c2 <printnum+0x92>
  800650:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800653:	72 05                	jb     80065a <printnum+0x2a>
  800655:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800658:	77 68                	ja     8006c2 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80065a:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80065d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800660:	8b 45 18             	mov    0x18(%ebp),%eax
  800663:	ba 00 00 00 00       	mov    $0x0,%edx
  800668:	89 44 24 08          	mov    %eax,0x8(%esp)
  80066c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800670:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800673:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800676:	89 04 24             	mov    %eax,(%esp)
  800679:	89 54 24 04          	mov    %edx,0x4(%esp)
  80067d:	e8 9e 0b 00 00       	call   801220 <__udivdi3>
  800682:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800685:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800689:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80068d:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800690:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800694:	89 44 24 08          	mov    %eax,0x8(%esp)
  800698:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80069c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80069f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a6:	89 04 24             	mov    %eax,(%esp)
  8006a9:	e8 82 ff ff ff       	call   800630 <printnum>
  8006ae:	eb 1c                	jmp    8006cc <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8006b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b7:	8b 45 20             	mov    0x20(%ebp),%eax
  8006ba:	89 04 24             	mov    %eax,(%esp)
  8006bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c0:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006c2:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8006c6:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8006ca:	7f e4                	jg     8006b0 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006cc:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8006cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006da:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006de:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006e2:	89 04 24             	mov    %eax,(%esp)
  8006e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006e9:	e8 62 0c 00 00       	call   801350 <__umoddi3>
  8006ee:	05 e8 15 80 00       	add    $0x8015e8,%eax
  8006f3:	0f b6 00             	movzbl (%eax),%eax
  8006f6:	0f be c0             	movsbl %al,%eax
  8006f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006fc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800700:	89 04 24             	mov    %eax,(%esp)
  800703:	8b 45 08             	mov    0x8(%ebp),%eax
  800706:	ff d0                	call   *%eax
}
  800708:	83 c4 34             	add    $0x34,%esp
  80070b:	5b                   	pop    %ebx
  80070c:	5d                   	pop    %ebp
  80070d:	c3                   	ret    

0080070e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80070e:	55                   	push   %ebp
  80070f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800711:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800715:	7e 14                	jle    80072b <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800717:	8b 45 08             	mov    0x8(%ebp),%eax
  80071a:	8b 00                	mov    (%eax),%eax
  80071c:	8d 48 08             	lea    0x8(%eax),%ecx
  80071f:	8b 55 08             	mov    0x8(%ebp),%edx
  800722:	89 0a                	mov    %ecx,(%edx)
  800724:	8b 50 04             	mov    0x4(%eax),%edx
  800727:	8b 00                	mov    (%eax),%eax
  800729:	eb 30                	jmp    80075b <getuint+0x4d>
	else if (lflag)
  80072b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80072f:	74 16                	je     800747 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800731:	8b 45 08             	mov    0x8(%ebp),%eax
  800734:	8b 00                	mov    (%eax),%eax
  800736:	8d 48 04             	lea    0x4(%eax),%ecx
  800739:	8b 55 08             	mov    0x8(%ebp),%edx
  80073c:	89 0a                	mov    %ecx,(%edx)
  80073e:	8b 00                	mov    (%eax),%eax
  800740:	ba 00 00 00 00       	mov    $0x0,%edx
  800745:	eb 14                	jmp    80075b <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800747:	8b 45 08             	mov    0x8(%ebp),%eax
  80074a:	8b 00                	mov    (%eax),%eax
  80074c:	8d 48 04             	lea    0x4(%eax),%ecx
  80074f:	8b 55 08             	mov    0x8(%ebp),%edx
  800752:	89 0a                	mov    %ecx,(%edx)
  800754:	8b 00                	mov    (%eax),%eax
  800756:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80075b:	5d                   	pop    %ebp
  80075c:	c3                   	ret    

0080075d <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800760:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800764:	7e 14                	jle    80077a <getint+0x1d>
		return va_arg(*ap, long long);
  800766:	8b 45 08             	mov    0x8(%ebp),%eax
  800769:	8b 00                	mov    (%eax),%eax
  80076b:	8d 48 08             	lea    0x8(%eax),%ecx
  80076e:	8b 55 08             	mov    0x8(%ebp),%edx
  800771:	89 0a                	mov    %ecx,(%edx)
  800773:	8b 50 04             	mov    0x4(%eax),%edx
  800776:	8b 00                	mov    (%eax),%eax
  800778:	eb 28                	jmp    8007a2 <getint+0x45>
	else if (lflag)
  80077a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80077e:	74 12                	je     800792 <getint+0x35>
		return va_arg(*ap, long);
  800780:	8b 45 08             	mov    0x8(%ebp),%eax
  800783:	8b 00                	mov    (%eax),%eax
  800785:	8d 48 04             	lea    0x4(%eax),%ecx
  800788:	8b 55 08             	mov    0x8(%ebp),%edx
  80078b:	89 0a                	mov    %ecx,(%edx)
  80078d:	8b 00                	mov    (%eax),%eax
  80078f:	99                   	cltd   
  800790:	eb 10                	jmp    8007a2 <getint+0x45>
	else
		return va_arg(*ap, int);
  800792:	8b 45 08             	mov    0x8(%ebp),%eax
  800795:	8b 00                	mov    (%eax),%eax
  800797:	8d 48 04             	lea    0x4(%eax),%ecx
  80079a:	8b 55 08             	mov    0x8(%ebp),%edx
  80079d:	89 0a                	mov    %ecx,(%edx)
  80079f:	8b 00                	mov    (%eax),%eax
  8007a1:	99                   	cltd   
}
  8007a2:	5d                   	pop    %ebp
  8007a3:	c3                   	ret    

008007a4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	56                   	push   %esi
  8007a8:	53                   	push   %ebx
  8007a9:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007ac:	eb 18                	jmp    8007c6 <vprintfmt+0x22>
			if (ch == '\0')
  8007ae:	85 db                	test   %ebx,%ebx
  8007b0:	75 05                	jne    8007b7 <vprintfmt+0x13>
				return;
  8007b2:	e9 cc 03 00 00       	jmp    800b83 <vprintfmt+0x3df>
			putch(ch, putdat);
  8007b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007be:	89 1c 24             	mov    %ebx,(%esp)
  8007c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c4:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c9:	8d 50 01             	lea    0x1(%eax),%edx
  8007cc:	89 55 10             	mov    %edx,0x10(%ebp)
  8007cf:	0f b6 00             	movzbl (%eax),%eax
  8007d2:	0f b6 d8             	movzbl %al,%ebx
  8007d5:	83 fb 25             	cmp    $0x25,%ebx
  8007d8:	75 d4                	jne    8007ae <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8007da:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8007de:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8007e5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8007ec:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8007f3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8007fd:	8d 50 01             	lea    0x1(%eax),%edx
  800800:	89 55 10             	mov    %edx,0x10(%ebp)
  800803:	0f b6 00             	movzbl (%eax),%eax
  800806:	0f b6 d8             	movzbl %al,%ebx
  800809:	8d 43 dd             	lea    -0x23(%ebx),%eax
  80080c:	83 f8 55             	cmp    $0x55,%eax
  80080f:	0f 87 3d 03 00 00    	ja     800b52 <vprintfmt+0x3ae>
  800815:	8b 04 85 0c 16 80 00 	mov    0x80160c(,%eax,4),%eax
  80081c:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  80081e:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800822:	eb d6                	jmp    8007fa <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800824:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800828:	eb d0                	jmp    8007fa <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80082a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800831:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800834:	89 d0                	mov    %edx,%eax
  800836:	c1 e0 02             	shl    $0x2,%eax
  800839:	01 d0                	add    %edx,%eax
  80083b:	01 c0                	add    %eax,%eax
  80083d:	01 d8                	add    %ebx,%eax
  80083f:	83 e8 30             	sub    $0x30,%eax
  800842:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800845:	8b 45 10             	mov    0x10(%ebp),%eax
  800848:	0f b6 00             	movzbl (%eax),%eax
  80084b:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  80084e:	83 fb 2f             	cmp    $0x2f,%ebx
  800851:	7e 0b                	jle    80085e <vprintfmt+0xba>
  800853:	83 fb 39             	cmp    $0x39,%ebx
  800856:	7f 06                	jg     80085e <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800858:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80085c:	eb d3                	jmp    800831 <vprintfmt+0x8d>
			goto process_precision;
  80085e:	eb 33                	jmp    800893 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800860:	8b 45 14             	mov    0x14(%ebp),%eax
  800863:	8d 50 04             	lea    0x4(%eax),%edx
  800866:	89 55 14             	mov    %edx,0x14(%ebp)
  800869:	8b 00                	mov    (%eax),%eax
  80086b:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80086e:	eb 23                	jmp    800893 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800870:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800874:	79 0c                	jns    800882 <vprintfmt+0xde>
				width = 0;
  800876:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  80087d:	e9 78 ff ff ff       	jmp    8007fa <vprintfmt+0x56>
  800882:	e9 73 ff ff ff       	jmp    8007fa <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800887:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80088e:	e9 67 ff ff ff       	jmp    8007fa <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800893:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800897:	79 12                	jns    8008ab <vprintfmt+0x107>
				width = precision, precision = -1;
  800899:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80089c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80089f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8008a6:	e9 4f ff ff ff       	jmp    8007fa <vprintfmt+0x56>
  8008ab:	e9 4a ff ff ff       	jmp    8007fa <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008b0:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8008b4:	e9 41 ff ff ff       	jmp    8007fa <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bc:	8d 50 04             	lea    0x4(%eax),%edx
  8008bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c2:	8b 00                	mov    (%eax),%eax
  8008c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008cb:	89 04 24             	mov    %eax,(%esp)
  8008ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d1:	ff d0                	call   *%eax
			break;
  8008d3:	e9 a5 02 00 00       	jmp    800b7d <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008db:	8d 50 04             	lea    0x4(%eax),%edx
  8008de:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e1:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8008e3:	85 db                	test   %ebx,%ebx
  8008e5:	79 02                	jns    8008e9 <vprintfmt+0x145>
				err = -err;
  8008e7:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8008e9:	83 fb 09             	cmp    $0x9,%ebx
  8008ec:	7f 0b                	jg     8008f9 <vprintfmt+0x155>
  8008ee:	8b 34 9d c0 15 80 00 	mov    0x8015c0(,%ebx,4),%esi
  8008f5:	85 f6                	test   %esi,%esi
  8008f7:	75 23                	jne    80091c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8008f9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8008fd:	c7 44 24 08 f9 15 80 	movl   $0x8015f9,0x8(%esp)
  800904:	00 
  800905:	8b 45 0c             	mov    0xc(%ebp),%eax
  800908:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	89 04 24             	mov    %eax,(%esp)
  800912:	e8 73 02 00 00       	call   800b8a <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800917:	e9 61 02 00 00       	jmp    800b7d <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80091c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800920:	c7 44 24 08 02 16 80 	movl   $0x801602,0x8(%esp)
  800927:	00 
  800928:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	89 04 24             	mov    %eax,(%esp)
  800935:	e8 50 02 00 00       	call   800b8a <printfmt>
			break;
  80093a:	e9 3e 02 00 00       	jmp    800b7d <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80093f:	8b 45 14             	mov    0x14(%ebp),%eax
  800942:	8d 50 04             	lea    0x4(%eax),%edx
  800945:	89 55 14             	mov    %edx,0x14(%ebp)
  800948:	8b 30                	mov    (%eax),%esi
  80094a:	85 f6                	test   %esi,%esi
  80094c:	75 05                	jne    800953 <vprintfmt+0x1af>
				p = "(null)";
  80094e:	be 05 16 80 00       	mov    $0x801605,%esi
			if (width > 0 && padc != '-')
  800953:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800957:	7e 37                	jle    800990 <vprintfmt+0x1ec>
  800959:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  80095d:	74 31                	je     800990 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  80095f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800962:	89 44 24 04          	mov    %eax,0x4(%esp)
  800966:	89 34 24             	mov    %esi,(%esp)
  800969:	e8 39 03 00 00       	call   800ca7 <strnlen>
  80096e:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800971:	eb 17                	jmp    80098a <vprintfmt+0x1e6>
					putch(padc, putdat);
  800973:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800977:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80097e:	89 04 24             	mov    %eax,(%esp)
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800986:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80098a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80098e:	7f e3                	jg     800973 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800990:	eb 38                	jmp    8009ca <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800992:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800996:	74 1f                	je     8009b7 <vprintfmt+0x213>
  800998:	83 fb 1f             	cmp    $0x1f,%ebx
  80099b:	7e 05                	jle    8009a2 <vprintfmt+0x1fe>
  80099d:	83 fb 7e             	cmp    $0x7e,%ebx
  8009a0:	7e 15                	jle    8009b7 <vprintfmt+0x213>
					putch('?', putdat);
  8009a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8009b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b3:	ff d0                	call   *%eax
  8009b5:	eb 0f                	jmp    8009c6 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8009b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009be:	89 1c 24             	mov    %ebx,(%esp)
  8009c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c4:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009c6:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8009ca:	89 f0                	mov    %esi,%eax
  8009cc:	8d 70 01             	lea    0x1(%eax),%esi
  8009cf:	0f b6 00             	movzbl (%eax),%eax
  8009d2:	0f be d8             	movsbl %al,%ebx
  8009d5:	85 db                	test   %ebx,%ebx
  8009d7:	74 10                	je     8009e9 <vprintfmt+0x245>
  8009d9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009dd:	78 b3                	js     800992 <vprintfmt+0x1ee>
  8009df:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8009e3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009e7:	79 a9                	jns    800992 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009e9:	eb 17                	jmp    800a02 <vprintfmt+0x25e>
				putch(' ', putdat);
  8009eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009fe:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800a02:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a06:	7f e3                	jg     8009eb <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800a08:	e9 70 01 00 00       	jmp    800b7d <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a10:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a14:	8d 45 14             	lea    0x14(%ebp),%eax
  800a17:	89 04 24             	mov    %eax,(%esp)
  800a1a:	e8 3e fd ff ff       	call   80075d <getint>
  800a1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a22:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800a25:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a28:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a2b:	85 d2                	test   %edx,%edx
  800a2d:	79 26                	jns    800a55 <vprintfmt+0x2b1>
				putch('-', putdat);
  800a2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a32:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a36:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a40:	ff d0                	call   *%eax
				num = -(long long) num;
  800a42:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a45:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a48:	f7 d8                	neg    %eax
  800a4a:	83 d2 00             	adc    $0x0,%edx
  800a4d:	f7 da                	neg    %edx
  800a4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a52:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800a55:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a5c:	e9 a8 00 00 00       	jmp    800b09 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a61:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a64:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a68:	8d 45 14             	lea    0x14(%ebp),%eax
  800a6b:	89 04 24             	mov    %eax,(%esp)
  800a6e:	e8 9b fc ff ff       	call   80070e <getuint>
  800a73:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a76:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800a79:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a80:	e9 84 00 00 00       	jmp    800b09 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a85:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a88:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a8c:	8d 45 14             	lea    0x14(%ebp),%eax
  800a8f:	89 04 24             	mov    %eax,(%esp)
  800a92:	e8 77 fc ff ff       	call   80070e <getuint>
  800a97:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a9a:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800a9d:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800aa4:	eb 63                	jmp    800b09 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800aa6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aad:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab7:	ff d0                	call   *%eax
			putch('x', putdat);
  800ab9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aca:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800acc:	8b 45 14             	mov    0x14(%ebp),%eax
  800acf:	8d 50 04             	lea    0x4(%eax),%edx
  800ad2:	89 55 14             	mov    %edx,0x14(%ebp)
  800ad5:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800ad7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ada:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800ae1:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800ae8:	eb 1f                	jmp    800b09 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800aea:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800aed:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af1:	8d 45 14             	lea    0x14(%ebp),%eax
  800af4:	89 04 24             	mov    %eax,(%esp)
  800af7:	e8 12 fc ff ff       	call   80070e <getuint>
  800afc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800aff:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800b02:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b09:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800b0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b10:	89 54 24 18          	mov    %edx,0x18(%esp)
  800b14:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b17:	89 54 24 14          	mov    %edx,0x14(%esp)
  800b1b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b22:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b25:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b29:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b30:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b34:	8b 45 08             	mov    0x8(%ebp),%eax
  800b37:	89 04 24             	mov    %eax,(%esp)
  800b3a:	e8 f1 fa ff ff       	call   800630 <printnum>
			break;
  800b3f:	eb 3c                	jmp    800b7d <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b41:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b44:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b48:	89 1c 24             	mov    %ebx,(%esp)
  800b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4e:	ff d0                	call   *%eax
			break;
  800b50:	eb 2b                	jmp    800b7d <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b55:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b59:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b60:	8b 45 08             	mov    0x8(%ebp),%eax
  800b63:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b65:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b69:	eb 04                	jmp    800b6f <vprintfmt+0x3cb>
  800b6b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b6f:	8b 45 10             	mov    0x10(%ebp),%eax
  800b72:	83 e8 01             	sub    $0x1,%eax
  800b75:	0f b6 00             	movzbl (%eax),%eax
  800b78:	3c 25                	cmp    $0x25,%al
  800b7a:	75 ef                	jne    800b6b <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800b7c:	90                   	nop
		}
	}
  800b7d:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b7e:	e9 43 fc ff ff       	jmp    8007c6 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800b83:	83 c4 40             	add    $0x40,%esp
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b90:	8d 45 14             	lea    0x14(%ebp),%eax
  800b93:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b9d:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ba4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bab:	8b 45 08             	mov    0x8(%ebp),%eax
  800bae:	89 04 24             	mov    %eax,(%esp)
  800bb1:	e8 ee fb ff ff       	call   8007a4 <vprintfmt>
	va_end(ap);
}
  800bb6:	c9                   	leave  
  800bb7:	c3                   	ret    

00800bb8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800bbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbe:	8b 40 08             	mov    0x8(%eax),%eax
  800bc1:	8d 50 01             	lea    0x1(%eax),%edx
  800bc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc7:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800bca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bcd:	8b 10                	mov    (%eax),%edx
  800bcf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd2:	8b 40 04             	mov    0x4(%eax),%eax
  800bd5:	39 c2                	cmp    %eax,%edx
  800bd7:	73 12                	jae    800beb <sprintputch+0x33>
		*b->buf++ = ch;
  800bd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bdc:	8b 00                	mov    (%eax),%eax
  800bde:	8d 48 01             	lea    0x1(%eax),%ecx
  800be1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800be4:	89 0a                	mov    %ecx,(%edx)
  800be6:	8b 55 08             	mov    0x8(%ebp),%edx
  800be9:	88 10                	mov    %dl,(%eax)
}
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    

00800bed <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bf3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bf9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bfc:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bff:	8b 45 08             	mov    0x8(%ebp),%eax
  800c02:	01 d0                	add    %edx,%eax
  800c04:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c07:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c0e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800c12:	74 06                	je     800c1a <vsnprintf+0x2d>
  800c14:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c18:	7f 07                	jg     800c21 <vsnprintf+0x34>
		return -E_INVAL;
  800c1a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c1f:	eb 2a                	jmp    800c4b <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c21:	8b 45 14             	mov    0x14(%ebp),%eax
  800c24:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c28:	8b 45 10             	mov    0x10(%ebp),%eax
  800c2b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c2f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c32:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c36:	c7 04 24 b8 0b 80 00 	movl   $0x800bb8,(%esp)
  800c3d:	e8 62 fb ff ff       	call   8007a4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c42:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c45:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c4b:	c9                   	leave  
  800c4c:	c3                   	ret    

00800c4d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c53:	8d 45 14             	lea    0x14(%ebp),%eax
  800c56:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800c59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c5c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c60:	8b 45 10             	mov    0x10(%ebp),%eax
  800c63:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c71:	89 04 24             	mov    %eax,(%esp)
  800c74:	e8 74 ff ff ff       	call   800bed <vsnprintf>
  800c79:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800c7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c7f:	c9                   	leave  
  800c80:	c3                   	ret    

00800c81 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800c87:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c8e:	eb 08                	jmp    800c98 <strlen+0x17>
		n++;
  800c90:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c94:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c98:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9b:	0f b6 00             	movzbl (%eax),%eax
  800c9e:	84 c0                	test   %al,%al
  800ca0:	75 ee                	jne    800c90 <strlen+0xf>
		n++;
	return n;
  800ca2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800ca5:	c9                   	leave  
  800ca6:	c3                   	ret    

00800ca7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cad:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800cb4:	eb 0c                	jmp    800cc2 <strnlen+0x1b>
		n++;
  800cb6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cba:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cbe:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800cc2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cc6:	74 0a                	je     800cd2 <strnlen+0x2b>
  800cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccb:	0f b6 00             	movzbl (%eax),%eax
  800cce:	84 c0                	test   %al,%al
  800cd0:	75 e4                	jne    800cb6 <strnlen+0xf>
		n++;
	return n;
  800cd2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800cd5:	c9                   	leave  
  800cd6:	c3                   	ret    

00800cd7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800cdd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce0:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800ce3:	90                   	nop
  800ce4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce7:	8d 50 01             	lea    0x1(%eax),%edx
  800cea:	89 55 08             	mov    %edx,0x8(%ebp)
  800ced:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cf0:	8d 4a 01             	lea    0x1(%edx),%ecx
  800cf3:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800cf6:	0f b6 12             	movzbl (%edx),%edx
  800cf9:	88 10                	mov    %dl,(%eax)
  800cfb:	0f b6 00             	movzbl (%eax),%eax
  800cfe:	84 c0                	test   %al,%al
  800d00:	75 e2                	jne    800ce4 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800d02:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800d05:	c9                   	leave  
  800d06:	c3                   	ret    

00800d07 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800d0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d10:	89 04 24             	mov    %eax,(%esp)
  800d13:	e8 69 ff ff ff       	call   800c81 <strlen>
  800d18:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800d1b:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d21:	01 c2                	add    %eax,%edx
  800d23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d26:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d2a:	89 14 24             	mov    %edx,(%esp)
  800d2d:	e8 a5 ff ff ff       	call   800cd7 <strcpy>
	return dst;
  800d32:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d35:	c9                   	leave  
  800d36:	c3                   	ret    

00800d37 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800d3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d40:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800d43:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800d4a:	eb 23                	jmp    800d6f <strncpy+0x38>
		*dst++ = *src;
  800d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4f:	8d 50 01             	lea    0x1(%eax),%edx
  800d52:	89 55 08             	mov    %edx,0x8(%ebp)
  800d55:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d58:	0f b6 12             	movzbl (%edx),%edx
  800d5b:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800d5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d60:	0f b6 00             	movzbl (%eax),%eax
  800d63:	84 c0                	test   %al,%al
  800d65:	74 04                	je     800d6b <strncpy+0x34>
			src++;
  800d67:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d6b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d6f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d72:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d75:	72 d5                	jb     800d4c <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800d77:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d7a:	c9                   	leave  
  800d7b:	c3                   	ret    

00800d7c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800d82:	8b 45 08             	mov    0x8(%ebp),%eax
  800d85:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800d88:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d8c:	74 33                	je     800dc1 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d8e:	eb 17                	jmp    800da7 <strlcpy+0x2b>
			*dst++ = *src++;
  800d90:	8b 45 08             	mov    0x8(%ebp),%eax
  800d93:	8d 50 01             	lea    0x1(%eax),%edx
  800d96:	89 55 08             	mov    %edx,0x8(%ebp)
  800d99:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d9c:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d9f:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800da2:	0f b6 12             	movzbl (%edx),%edx
  800da5:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800da7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800dab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800daf:	74 0a                	je     800dbb <strlcpy+0x3f>
  800db1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db4:	0f b6 00             	movzbl (%eax),%eax
  800db7:	84 c0                	test   %al,%al
  800db9:	75 d5                	jne    800d90 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800dbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbe:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800dc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800dc7:	29 c2                	sub    %eax,%edx
  800dc9:	89 d0                	mov    %edx,%eax
}
  800dcb:	c9                   	leave  
  800dcc:	c3                   	ret    

00800dcd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800dd0:	eb 08                	jmp    800dda <strcmp+0xd>
		p++, q++;
  800dd2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dd6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800dda:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddd:	0f b6 00             	movzbl (%eax),%eax
  800de0:	84 c0                	test   %al,%al
  800de2:	74 10                	je     800df4 <strcmp+0x27>
  800de4:	8b 45 08             	mov    0x8(%ebp),%eax
  800de7:	0f b6 10             	movzbl (%eax),%edx
  800dea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ded:	0f b6 00             	movzbl (%eax),%eax
  800df0:	38 c2                	cmp    %al,%dl
  800df2:	74 de                	je     800dd2 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800df4:	8b 45 08             	mov    0x8(%ebp),%eax
  800df7:	0f b6 00             	movzbl (%eax),%eax
  800dfa:	0f b6 d0             	movzbl %al,%edx
  800dfd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e00:	0f b6 00             	movzbl (%eax),%eax
  800e03:	0f b6 c0             	movzbl %al,%eax
  800e06:	29 c2                	sub    %eax,%edx
  800e08:	89 d0                	mov    %edx,%eax
}
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    

00800e0c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800e0f:	eb 0c                	jmp    800e1d <strncmp+0x11>
		n--, p++, q++;
  800e11:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800e15:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e19:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e1d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e21:	74 1a                	je     800e3d <strncmp+0x31>
  800e23:	8b 45 08             	mov    0x8(%ebp),%eax
  800e26:	0f b6 00             	movzbl (%eax),%eax
  800e29:	84 c0                	test   %al,%al
  800e2b:	74 10                	je     800e3d <strncmp+0x31>
  800e2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e30:	0f b6 10             	movzbl (%eax),%edx
  800e33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e36:	0f b6 00             	movzbl (%eax),%eax
  800e39:	38 c2                	cmp    %al,%dl
  800e3b:	74 d4                	je     800e11 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800e3d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e41:	75 07                	jne    800e4a <strncmp+0x3e>
		return 0;
  800e43:	b8 00 00 00 00       	mov    $0x0,%eax
  800e48:	eb 16                	jmp    800e60 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4d:	0f b6 00             	movzbl (%eax),%eax
  800e50:	0f b6 d0             	movzbl %al,%edx
  800e53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e56:	0f b6 00             	movzbl (%eax),%eax
  800e59:	0f b6 c0             	movzbl %al,%eax
  800e5c:	29 c2                	sub    %eax,%edx
  800e5e:	89 d0                	mov    %edx,%eax
}
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    

00800e62 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	83 ec 04             	sub    $0x4,%esp
  800e68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6b:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e6e:	eb 14                	jmp    800e84 <strchr+0x22>
		if (*s == c)
  800e70:	8b 45 08             	mov    0x8(%ebp),%eax
  800e73:	0f b6 00             	movzbl (%eax),%eax
  800e76:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e79:	75 05                	jne    800e80 <strchr+0x1e>
			return (char *) s;
  800e7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7e:	eb 13                	jmp    800e93 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e80:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e84:	8b 45 08             	mov    0x8(%ebp),%eax
  800e87:	0f b6 00             	movzbl (%eax),%eax
  800e8a:	84 c0                	test   %al,%al
  800e8c:	75 e2                	jne    800e70 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e93:	c9                   	leave  
  800e94:	c3                   	ret    

00800e95 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	83 ec 04             	sub    $0x4,%esp
  800e9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9e:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800ea1:	eb 11                	jmp    800eb4 <strfind+0x1f>
		if (*s == c)
  800ea3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea6:	0f b6 00             	movzbl (%eax),%eax
  800ea9:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800eac:	75 02                	jne    800eb0 <strfind+0x1b>
			break;
  800eae:	eb 0e                	jmp    800ebe <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800eb0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800eb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb7:	0f b6 00             	movzbl (%eax),%eax
  800eba:	84 c0                	test   %al,%al
  800ebc:	75 e5                	jne    800ea3 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800ebe:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ec1:	c9                   	leave  
  800ec2:	c3                   	ret    

00800ec3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	57                   	push   %edi
	char *p;

	if (n == 0)
  800ec7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ecb:	75 05                	jne    800ed2 <memset+0xf>
		return v;
  800ecd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed0:	eb 5c                	jmp    800f2e <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800ed2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed5:	83 e0 03             	and    $0x3,%eax
  800ed8:	85 c0                	test   %eax,%eax
  800eda:	75 41                	jne    800f1d <memset+0x5a>
  800edc:	8b 45 10             	mov    0x10(%ebp),%eax
  800edf:	83 e0 03             	and    $0x3,%eax
  800ee2:	85 c0                	test   %eax,%eax
  800ee4:	75 37                	jne    800f1d <memset+0x5a>
		c &= 0xFF;
  800ee6:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800eed:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef0:	c1 e0 18             	shl    $0x18,%eax
  800ef3:	89 c2                	mov    %eax,%edx
  800ef5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef8:	c1 e0 10             	shl    $0x10,%eax
  800efb:	09 c2                	or     %eax,%edx
  800efd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f00:	c1 e0 08             	shl    $0x8,%eax
  800f03:	09 d0                	or     %edx,%eax
  800f05:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800f08:	8b 45 10             	mov    0x10(%ebp),%eax
  800f0b:	c1 e8 02             	shr    $0x2,%eax
  800f0e:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800f10:	8b 55 08             	mov    0x8(%ebp),%edx
  800f13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f16:	89 d7                	mov    %edx,%edi
  800f18:	fc                   	cld    
  800f19:	f3 ab                	rep stos %eax,%es:(%edi)
  800f1b:	eb 0e                	jmp    800f2b <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f20:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f23:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f26:	89 d7                	mov    %edx,%edi
  800f28:	fc                   	cld    
  800f29:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800f2b:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f2e:	5f                   	pop    %edi
  800f2f:	5d                   	pop    %ebp
  800f30:	c3                   	ret    

00800f31 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	57                   	push   %edi
  800f35:	56                   	push   %esi
  800f36:	53                   	push   %ebx
  800f37:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800f3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800f40:	8b 45 08             	mov    0x8(%ebp),%eax
  800f43:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800f46:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f49:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f4c:	73 6d                	jae    800fbb <memmove+0x8a>
  800f4e:	8b 45 10             	mov    0x10(%ebp),%eax
  800f51:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f54:	01 d0                	add    %edx,%eax
  800f56:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f59:	76 60                	jbe    800fbb <memmove+0x8a>
		s += n;
  800f5b:	8b 45 10             	mov    0x10(%ebp),%eax
  800f5e:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800f61:	8b 45 10             	mov    0x10(%ebp),%eax
  800f64:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f67:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f6a:	83 e0 03             	and    $0x3,%eax
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	75 2f                	jne    800fa0 <memmove+0x6f>
  800f71:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f74:	83 e0 03             	and    $0x3,%eax
  800f77:	85 c0                	test   %eax,%eax
  800f79:	75 25                	jne    800fa0 <memmove+0x6f>
  800f7b:	8b 45 10             	mov    0x10(%ebp),%eax
  800f7e:	83 e0 03             	and    $0x3,%eax
  800f81:	85 c0                	test   %eax,%eax
  800f83:	75 1b                	jne    800fa0 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f85:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f88:	83 e8 04             	sub    $0x4,%eax
  800f8b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f8e:	83 ea 04             	sub    $0x4,%edx
  800f91:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f94:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f97:	89 c7                	mov    %eax,%edi
  800f99:	89 d6                	mov    %edx,%esi
  800f9b:	fd                   	std    
  800f9c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f9e:	eb 18                	jmp    800fb8 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800fa0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fa3:	8d 50 ff             	lea    -0x1(%eax),%edx
  800fa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fa9:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800fac:	8b 45 10             	mov    0x10(%ebp),%eax
  800faf:	89 d7                	mov    %edx,%edi
  800fb1:	89 de                	mov    %ebx,%esi
  800fb3:	89 c1                	mov    %eax,%ecx
  800fb5:	fd                   	std    
  800fb6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fb8:	fc                   	cld    
  800fb9:	eb 45                	jmp    801000 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fbe:	83 e0 03             	and    $0x3,%eax
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	75 2b                	jne    800ff0 <memmove+0xbf>
  800fc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fc8:	83 e0 03             	and    $0x3,%eax
  800fcb:	85 c0                	test   %eax,%eax
  800fcd:	75 21                	jne    800ff0 <memmove+0xbf>
  800fcf:	8b 45 10             	mov    0x10(%ebp),%eax
  800fd2:	83 e0 03             	and    $0x3,%eax
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	75 17                	jne    800ff0 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800fd9:	8b 45 10             	mov    0x10(%ebp),%eax
  800fdc:	c1 e8 02             	shr    $0x2,%eax
  800fdf:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800fe1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fe4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fe7:	89 c7                	mov    %eax,%edi
  800fe9:	89 d6                	mov    %edx,%esi
  800feb:	fc                   	cld    
  800fec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fee:	eb 10                	jmp    801000 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ff0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ff3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ff6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ff9:	89 c7                	mov    %eax,%edi
  800ffb:	89 d6                	mov    %edx,%esi
  800ffd:	fc                   	cld    
  800ffe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  801000:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801003:	83 c4 10             	add    $0x10,%esp
  801006:	5b                   	pop    %ebx
  801007:	5e                   	pop    %esi
  801008:	5f                   	pop    %edi
  801009:	5d                   	pop    %ebp
  80100a:	c3                   	ret    

0080100b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801011:	8b 45 10             	mov    0x10(%ebp),%eax
  801014:	89 44 24 08          	mov    %eax,0x8(%esp)
  801018:	8b 45 0c             	mov    0xc(%ebp),%eax
  80101b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80101f:	8b 45 08             	mov    0x8(%ebp),%eax
  801022:	89 04 24             	mov    %eax,(%esp)
  801025:	e8 07 ff ff ff       	call   800f31 <memmove>
}
  80102a:	c9                   	leave  
  80102b:	c3                   	ret    

0080102c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  801032:	8b 45 08             	mov    0x8(%ebp),%eax
  801035:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  801038:	8b 45 0c             	mov    0xc(%ebp),%eax
  80103b:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  80103e:	eb 30                	jmp    801070 <memcmp+0x44>
		if (*s1 != *s2)
  801040:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801043:	0f b6 10             	movzbl (%eax),%edx
  801046:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801049:	0f b6 00             	movzbl (%eax),%eax
  80104c:	38 c2                	cmp    %al,%dl
  80104e:	74 18                	je     801068 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  801050:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801053:	0f b6 00             	movzbl (%eax),%eax
  801056:	0f b6 d0             	movzbl %al,%edx
  801059:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80105c:	0f b6 00             	movzbl (%eax),%eax
  80105f:	0f b6 c0             	movzbl %al,%eax
  801062:	29 c2                	sub    %eax,%edx
  801064:	89 d0                	mov    %edx,%eax
  801066:	eb 1a                	jmp    801082 <memcmp+0x56>
		s1++, s2++;
  801068:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80106c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801070:	8b 45 10             	mov    0x10(%ebp),%eax
  801073:	8d 50 ff             	lea    -0x1(%eax),%edx
  801076:	89 55 10             	mov    %edx,0x10(%ebp)
  801079:	85 c0                	test   %eax,%eax
  80107b:	75 c3                	jne    801040 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80107d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801082:	c9                   	leave  
  801083:	c3                   	ret    

00801084 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  80108a:	8b 45 10             	mov    0x10(%ebp),%eax
  80108d:	8b 55 08             	mov    0x8(%ebp),%edx
  801090:	01 d0                	add    %edx,%eax
  801092:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801095:	eb 13                	jmp    8010aa <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801097:	8b 45 08             	mov    0x8(%ebp),%eax
  80109a:	0f b6 10             	movzbl (%eax),%edx
  80109d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010a0:	38 c2                	cmp    %al,%dl
  8010a2:	75 02                	jne    8010a6 <memfind+0x22>
			break;
  8010a4:	eb 0c                	jmp    8010b2 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8010a6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ad:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  8010b0:	72 e5                	jb     801097 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  8010b2:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8010b5:	c9                   	leave  
  8010b6:	c3                   	ret    

008010b7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  8010bd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  8010c4:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010cb:	eb 04                	jmp    8010d1 <strtol+0x1a>
		s++;
  8010cd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d4:	0f b6 00             	movzbl (%eax),%eax
  8010d7:	3c 20                	cmp    $0x20,%al
  8010d9:	74 f2                	je     8010cd <strtol+0x16>
  8010db:	8b 45 08             	mov    0x8(%ebp),%eax
  8010de:	0f b6 00             	movzbl (%eax),%eax
  8010e1:	3c 09                	cmp    $0x9,%al
  8010e3:	74 e8                	je     8010cd <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  8010e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e8:	0f b6 00             	movzbl (%eax),%eax
  8010eb:	3c 2b                	cmp    $0x2b,%al
  8010ed:	75 06                	jne    8010f5 <strtol+0x3e>
		s++;
  8010ef:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010f3:	eb 15                	jmp    80110a <strtol+0x53>
	else if (*s == '-')
  8010f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f8:	0f b6 00             	movzbl (%eax),%eax
  8010fb:	3c 2d                	cmp    $0x2d,%al
  8010fd:	75 0b                	jne    80110a <strtol+0x53>
		s++, neg = 1;
  8010ff:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801103:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80110a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80110e:	74 06                	je     801116 <strtol+0x5f>
  801110:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  801114:	75 24                	jne    80113a <strtol+0x83>
  801116:	8b 45 08             	mov    0x8(%ebp),%eax
  801119:	0f b6 00             	movzbl (%eax),%eax
  80111c:	3c 30                	cmp    $0x30,%al
  80111e:	75 1a                	jne    80113a <strtol+0x83>
  801120:	8b 45 08             	mov    0x8(%ebp),%eax
  801123:	83 c0 01             	add    $0x1,%eax
  801126:	0f b6 00             	movzbl (%eax),%eax
  801129:	3c 78                	cmp    $0x78,%al
  80112b:	75 0d                	jne    80113a <strtol+0x83>
		s += 2, base = 16;
  80112d:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  801131:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  801138:	eb 2a                	jmp    801164 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  80113a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80113e:	75 17                	jne    801157 <strtol+0xa0>
  801140:	8b 45 08             	mov    0x8(%ebp),%eax
  801143:	0f b6 00             	movzbl (%eax),%eax
  801146:	3c 30                	cmp    $0x30,%al
  801148:	75 0d                	jne    801157 <strtol+0xa0>
		s++, base = 8;
  80114a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80114e:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801155:	eb 0d                	jmp    801164 <strtol+0xad>
	else if (base == 0)
  801157:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80115b:	75 07                	jne    801164 <strtol+0xad>
		base = 10;
  80115d:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801164:	8b 45 08             	mov    0x8(%ebp),%eax
  801167:	0f b6 00             	movzbl (%eax),%eax
  80116a:	3c 2f                	cmp    $0x2f,%al
  80116c:	7e 1b                	jle    801189 <strtol+0xd2>
  80116e:	8b 45 08             	mov    0x8(%ebp),%eax
  801171:	0f b6 00             	movzbl (%eax),%eax
  801174:	3c 39                	cmp    $0x39,%al
  801176:	7f 11                	jg     801189 <strtol+0xd2>
			dig = *s - '0';
  801178:	8b 45 08             	mov    0x8(%ebp),%eax
  80117b:	0f b6 00             	movzbl (%eax),%eax
  80117e:	0f be c0             	movsbl %al,%eax
  801181:	83 e8 30             	sub    $0x30,%eax
  801184:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801187:	eb 48                	jmp    8011d1 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  801189:	8b 45 08             	mov    0x8(%ebp),%eax
  80118c:	0f b6 00             	movzbl (%eax),%eax
  80118f:	3c 60                	cmp    $0x60,%al
  801191:	7e 1b                	jle    8011ae <strtol+0xf7>
  801193:	8b 45 08             	mov    0x8(%ebp),%eax
  801196:	0f b6 00             	movzbl (%eax),%eax
  801199:	3c 7a                	cmp    $0x7a,%al
  80119b:	7f 11                	jg     8011ae <strtol+0xf7>
			dig = *s - 'a' + 10;
  80119d:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a0:	0f b6 00             	movzbl (%eax),%eax
  8011a3:	0f be c0             	movsbl %al,%eax
  8011a6:	83 e8 57             	sub    $0x57,%eax
  8011a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8011ac:	eb 23                	jmp    8011d1 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  8011ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b1:	0f b6 00             	movzbl (%eax),%eax
  8011b4:	3c 40                	cmp    $0x40,%al
  8011b6:	7e 3d                	jle    8011f5 <strtol+0x13e>
  8011b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011bb:	0f b6 00             	movzbl (%eax),%eax
  8011be:	3c 5a                	cmp    $0x5a,%al
  8011c0:	7f 33                	jg     8011f5 <strtol+0x13e>
			dig = *s - 'A' + 10;
  8011c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c5:	0f b6 00             	movzbl (%eax),%eax
  8011c8:	0f be c0             	movsbl %al,%eax
  8011cb:	83 e8 37             	sub    $0x37,%eax
  8011ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  8011d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011d4:	3b 45 10             	cmp    0x10(%ebp),%eax
  8011d7:	7c 02                	jl     8011db <strtol+0x124>
			break;
  8011d9:	eb 1a                	jmp    8011f5 <strtol+0x13e>
		s++, val = (val * base) + dig;
  8011db:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8011df:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011e2:	0f af 45 10          	imul   0x10(%ebp),%eax
  8011e6:	89 c2                	mov    %eax,%edx
  8011e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011eb:	01 d0                	add    %edx,%eax
  8011ed:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  8011f0:	e9 6f ff ff ff       	jmp    801164 <strtol+0xad>

	if (endptr)
  8011f5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011f9:	74 08                	je     801203 <strtol+0x14c>
		*endptr = (char *) s;
  8011fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011fe:	8b 55 08             	mov    0x8(%ebp),%edx
  801201:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801203:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  801207:	74 07                	je     801210 <strtol+0x159>
  801209:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80120c:	f7 d8                	neg    %eax
  80120e:	eb 03                	jmp    801213 <strtol+0x15c>
  801210:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  801213:	c9                   	leave  
  801214:	c3                   	ret    
  801215:	66 90                	xchg   %ax,%ax
  801217:	66 90                	xchg   %ax,%ax
  801219:	66 90                	xchg   %ax,%ax
  80121b:	66 90                	xchg   %ax,%ax
  80121d:	66 90                	xchg   %ax,%ax
  80121f:	90                   	nop

00801220 <__udivdi3>:
  801220:	55                   	push   %ebp
  801221:	57                   	push   %edi
  801222:	56                   	push   %esi
  801223:	83 ec 0c             	sub    $0xc,%esp
  801226:	8b 44 24 28          	mov    0x28(%esp),%eax
  80122a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80122e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801232:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801236:	85 c0                	test   %eax,%eax
  801238:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80123c:	89 ea                	mov    %ebp,%edx
  80123e:	89 0c 24             	mov    %ecx,(%esp)
  801241:	75 2d                	jne    801270 <__udivdi3+0x50>
  801243:	39 e9                	cmp    %ebp,%ecx
  801245:	77 61                	ja     8012a8 <__udivdi3+0x88>
  801247:	85 c9                	test   %ecx,%ecx
  801249:	89 ce                	mov    %ecx,%esi
  80124b:	75 0b                	jne    801258 <__udivdi3+0x38>
  80124d:	b8 01 00 00 00       	mov    $0x1,%eax
  801252:	31 d2                	xor    %edx,%edx
  801254:	f7 f1                	div    %ecx
  801256:	89 c6                	mov    %eax,%esi
  801258:	31 d2                	xor    %edx,%edx
  80125a:	89 e8                	mov    %ebp,%eax
  80125c:	f7 f6                	div    %esi
  80125e:	89 c5                	mov    %eax,%ebp
  801260:	89 f8                	mov    %edi,%eax
  801262:	f7 f6                	div    %esi
  801264:	89 ea                	mov    %ebp,%edx
  801266:	83 c4 0c             	add    $0xc,%esp
  801269:	5e                   	pop    %esi
  80126a:	5f                   	pop    %edi
  80126b:	5d                   	pop    %ebp
  80126c:	c3                   	ret    
  80126d:	8d 76 00             	lea    0x0(%esi),%esi
  801270:	39 e8                	cmp    %ebp,%eax
  801272:	77 24                	ja     801298 <__udivdi3+0x78>
  801274:	0f bd e8             	bsr    %eax,%ebp
  801277:	83 f5 1f             	xor    $0x1f,%ebp
  80127a:	75 3c                	jne    8012b8 <__udivdi3+0x98>
  80127c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801280:	39 34 24             	cmp    %esi,(%esp)
  801283:	0f 86 9f 00 00 00    	jbe    801328 <__udivdi3+0x108>
  801289:	39 d0                	cmp    %edx,%eax
  80128b:	0f 82 97 00 00 00    	jb     801328 <__udivdi3+0x108>
  801291:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801298:	31 d2                	xor    %edx,%edx
  80129a:	31 c0                	xor    %eax,%eax
  80129c:	83 c4 0c             	add    $0xc,%esp
  80129f:	5e                   	pop    %esi
  8012a0:	5f                   	pop    %edi
  8012a1:	5d                   	pop    %ebp
  8012a2:	c3                   	ret    
  8012a3:	90                   	nop
  8012a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012a8:	89 f8                	mov    %edi,%eax
  8012aa:	f7 f1                	div    %ecx
  8012ac:	31 d2                	xor    %edx,%edx
  8012ae:	83 c4 0c             	add    $0xc,%esp
  8012b1:	5e                   	pop    %esi
  8012b2:	5f                   	pop    %edi
  8012b3:	5d                   	pop    %ebp
  8012b4:	c3                   	ret    
  8012b5:	8d 76 00             	lea    0x0(%esi),%esi
  8012b8:	89 e9                	mov    %ebp,%ecx
  8012ba:	8b 3c 24             	mov    (%esp),%edi
  8012bd:	d3 e0                	shl    %cl,%eax
  8012bf:	89 c6                	mov    %eax,%esi
  8012c1:	b8 20 00 00 00       	mov    $0x20,%eax
  8012c6:	29 e8                	sub    %ebp,%eax
  8012c8:	89 c1                	mov    %eax,%ecx
  8012ca:	d3 ef                	shr    %cl,%edi
  8012cc:	89 e9                	mov    %ebp,%ecx
  8012ce:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8012d2:	8b 3c 24             	mov    (%esp),%edi
  8012d5:	09 74 24 08          	or     %esi,0x8(%esp)
  8012d9:	89 d6                	mov    %edx,%esi
  8012db:	d3 e7                	shl    %cl,%edi
  8012dd:	89 c1                	mov    %eax,%ecx
  8012df:	89 3c 24             	mov    %edi,(%esp)
  8012e2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012e6:	d3 ee                	shr    %cl,%esi
  8012e8:	89 e9                	mov    %ebp,%ecx
  8012ea:	d3 e2                	shl    %cl,%edx
  8012ec:	89 c1                	mov    %eax,%ecx
  8012ee:	d3 ef                	shr    %cl,%edi
  8012f0:	09 d7                	or     %edx,%edi
  8012f2:	89 f2                	mov    %esi,%edx
  8012f4:	89 f8                	mov    %edi,%eax
  8012f6:	f7 74 24 08          	divl   0x8(%esp)
  8012fa:	89 d6                	mov    %edx,%esi
  8012fc:	89 c7                	mov    %eax,%edi
  8012fe:	f7 24 24             	mull   (%esp)
  801301:	39 d6                	cmp    %edx,%esi
  801303:	89 14 24             	mov    %edx,(%esp)
  801306:	72 30                	jb     801338 <__udivdi3+0x118>
  801308:	8b 54 24 04          	mov    0x4(%esp),%edx
  80130c:	89 e9                	mov    %ebp,%ecx
  80130e:	d3 e2                	shl    %cl,%edx
  801310:	39 c2                	cmp    %eax,%edx
  801312:	73 05                	jae    801319 <__udivdi3+0xf9>
  801314:	3b 34 24             	cmp    (%esp),%esi
  801317:	74 1f                	je     801338 <__udivdi3+0x118>
  801319:	89 f8                	mov    %edi,%eax
  80131b:	31 d2                	xor    %edx,%edx
  80131d:	e9 7a ff ff ff       	jmp    80129c <__udivdi3+0x7c>
  801322:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801328:	31 d2                	xor    %edx,%edx
  80132a:	b8 01 00 00 00       	mov    $0x1,%eax
  80132f:	e9 68 ff ff ff       	jmp    80129c <__udivdi3+0x7c>
  801334:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801338:	8d 47 ff             	lea    -0x1(%edi),%eax
  80133b:	31 d2                	xor    %edx,%edx
  80133d:	83 c4 0c             	add    $0xc,%esp
  801340:	5e                   	pop    %esi
  801341:	5f                   	pop    %edi
  801342:	5d                   	pop    %ebp
  801343:	c3                   	ret    
  801344:	66 90                	xchg   %ax,%ax
  801346:	66 90                	xchg   %ax,%ax
  801348:	66 90                	xchg   %ax,%ax
  80134a:	66 90                	xchg   %ax,%ax
  80134c:	66 90                	xchg   %ax,%ax
  80134e:	66 90                	xchg   %ax,%ax

00801350 <__umoddi3>:
  801350:	55                   	push   %ebp
  801351:	57                   	push   %edi
  801352:	56                   	push   %esi
  801353:	83 ec 14             	sub    $0x14,%esp
  801356:	8b 44 24 28          	mov    0x28(%esp),%eax
  80135a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80135e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801362:	89 c7                	mov    %eax,%edi
  801364:	89 44 24 04          	mov    %eax,0x4(%esp)
  801368:	8b 44 24 30          	mov    0x30(%esp),%eax
  80136c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801370:	89 34 24             	mov    %esi,(%esp)
  801373:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801377:	85 c0                	test   %eax,%eax
  801379:	89 c2                	mov    %eax,%edx
  80137b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80137f:	75 17                	jne    801398 <__umoddi3+0x48>
  801381:	39 fe                	cmp    %edi,%esi
  801383:	76 4b                	jbe    8013d0 <__umoddi3+0x80>
  801385:	89 c8                	mov    %ecx,%eax
  801387:	89 fa                	mov    %edi,%edx
  801389:	f7 f6                	div    %esi
  80138b:	89 d0                	mov    %edx,%eax
  80138d:	31 d2                	xor    %edx,%edx
  80138f:	83 c4 14             	add    $0x14,%esp
  801392:	5e                   	pop    %esi
  801393:	5f                   	pop    %edi
  801394:	5d                   	pop    %ebp
  801395:	c3                   	ret    
  801396:	66 90                	xchg   %ax,%ax
  801398:	39 f8                	cmp    %edi,%eax
  80139a:	77 54                	ja     8013f0 <__umoddi3+0xa0>
  80139c:	0f bd e8             	bsr    %eax,%ebp
  80139f:	83 f5 1f             	xor    $0x1f,%ebp
  8013a2:	75 5c                	jne    801400 <__umoddi3+0xb0>
  8013a4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8013a8:	39 3c 24             	cmp    %edi,(%esp)
  8013ab:	0f 87 e7 00 00 00    	ja     801498 <__umoddi3+0x148>
  8013b1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013b5:	29 f1                	sub    %esi,%ecx
  8013b7:	19 c7                	sbb    %eax,%edi
  8013b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013bd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013c1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8013c5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8013c9:	83 c4 14             	add    $0x14,%esp
  8013cc:	5e                   	pop    %esi
  8013cd:	5f                   	pop    %edi
  8013ce:	5d                   	pop    %ebp
  8013cf:	c3                   	ret    
  8013d0:	85 f6                	test   %esi,%esi
  8013d2:	89 f5                	mov    %esi,%ebp
  8013d4:	75 0b                	jne    8013e1 <__umoddi3+0x91>
  8013d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013db:	31 d2                	xor    %edx,%edx
  8013dd:	f7 f6                	div    %esi
  8013df:	89 c5                	mov    %eax,%ebp
  8013e1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8013e5:	31 d2                	xor    %edx,%edx
  8013e7:	f7 f5                	div    %ebp
  8013e9:	89 c8                	mov    %ecx,%eax
  8013eb:	f7 f5                	div    %ebp
  8013ed:	eb 9c                	jmp    80138b <__umoddi3+0x3b>
  8013ef:	90                   	nop
  8013f0:	89 c8                	mov    %ecx,%eax
  8013f2:	89 fa                	mov    %edi,%edx
  8013f4:	83 c4 14             	add    $0x14,%esp
  8013f7:	5e                   	pop    %esi
  8013f8:	5f                   	pop    %edi
  8013f9:	5d                   	pop    %ebp
  8013fa:	c3                   	ret    
  8013fb:	90                   	nop
  8013fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801400:	8b 04 24             	mov    (%esp),%eax
  801403:	be 20 00 00 00       	mov    $0x20,%esi
  801408:	89 e9                	mov    %ebp,%ecx
  80140a:	29 ee                	sub    %ebp,%esi
  80140c:	d3 e2                	shl    %cl,%edx
  80140e:	89 f1                	mov    %esi,%ecx
  801410:	d3 e8                	shr    %cl,%eax
  801412:	89 e9                	mov    %ebp,%ecx
  801414:	89 44 24 04          	mov    %eax,0x4(%esp)
  801418:	8b 04 24             	mov    (%esp),%eax
  80141b:	09 54 24 04          	or     %edx,0x4(%esp)
  80141f:	89 fa                	mov    %edi,%edx
  801421:	d3 e0                	shl    %cl,%eax
  801423:	89 f1                	mov    %esi,%ecx
  801425:	89 44 24 08          	mov    %eax,0x8(%esp)
  801429:	8b 44 24 10          	mov    0x10(%esp),%eax
  80142d:	d3 ea                	shr    %cl,%edx
  80142f:	89 e9                	mov    %ebp,%ecx
  801431:	d3 e7                	shl    %cl,%edi
  801433:	89 f1                	mov    %esi,%ecx
  801435:	d3 e8                	shr    %cl,%eax
  801437:	89 e9                	mov    %ebp,%ecx
  801439:	09 f8                	or     %edi,%eax
  80143b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80143f:	f7 74 24 04          	divl   0x4(%esp)
  801443:	d3 e7                	shl    %cl,%edi
  801445:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801449:	89 d7                	mov    %edx,%edi
  80144b:	f7 64 24 08          	mull   0x8(%esp)
  80144f:	39 d7                	cmp    %edx,%edi
  801451:	89 c1                	mov    %eax,%ecx
  801453:	89 14 24             	mov    %edx,(%esp)
  801456:	72 2c                	jb     801484 <__umoddi3+0x134>
  801458:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80145c:	72 22                	jb     801480 <__umoddi3+0x130>
  80145e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801462:	29 c8                	sub    %ecx,%eax
  801464:	19 d7                	sbb    %edx,%edi
  801466:	89 e9                	mov    %ebp,%ecx
  801468:	89 fa                	mov    %edi,%edx
  80146a:	d3 e8                	shr    %cl,%eax
  80146c:	89 f1                	mov    %esi,%ecx
  80146e:	d3 e2                	shl    %cl,%edx
  801470:	89 e9                	mov    %ebp,%ecx
  801472:	d3 ef                	shr    %cl,%edi
  801474:	09 d0                	or     %edx,%eax
  801476:	89 fa                	mov    %edi,%edx
  801478:	83 c4 14             	add    $0x14,%esp
  80147b:	5e                   	pop    %esi
  80147c:	5f                   	pop    %edi
  80147d:	5d                   	pop    %ebp
  80147e:	c3                   	ret    
  80147f:	90                   	nop
  801480:	39 d7                	cmp    %edx,%edi
  801482:	75 da                	jne    80145e <__umoddi3+0x10e>
  801484:	8b 14 24             	mov    (%esp),%edx
  801487:	89 c1                	mov    %eax,%ecx
  801489:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80148d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801491:	eb cb                	jmp    80145e <__umoddi3+0x10e>
  801493:	90                   	nop
  801494:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801498:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80149c:	0f 82 0f ff ff ff    	jb     8013b1 <__umoddi3+0x61>
  8014a2:	e9 1a ff ff ff       	jmp    8013c1 <__umoddi3+0x71>
