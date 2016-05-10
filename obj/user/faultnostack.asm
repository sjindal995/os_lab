
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 29 00 00 00       	call   80005a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	c7 44 24 04 fa 04 80 	movl   $0x8004fa,0x4(%esp)
  800040:	00 
  800041:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800048:	e8 1d 03 00 00       	call   80036a <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004d:	b8 00 00 00 00       	mov    $0x0,%eax
  800052:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
  800058:	c9                   	leave  
  800059:	c3                   	ret    

0080005a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005a:	55                   	push   %ebp
  80005b:	89 e5                	mov    %esp,%ebp
  80005d:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800060:	e8 72 01 00 00       	call   8001d7 <sys_getenvid>
  800065:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006a:	c1 e0 02             	shl    $0x2,%eax
  80006d:	89 c2                	mov    %eax,%edx
  80006f:	c1 e2 05             	shl    $0x5,%edx
  800072:	29 c2                	sub    %eax,%edx
  800074:	89 d0                	mov    %edx,%eax
  800076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007b:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	// if (argc > 0)
	// 	binaryname = argv[0];

	// call user main routine
	umain(argc, argv);
  800080:	8b 45 0c             	mov    0xc(%ebp),%eax
  800083:	89 44 24 04          	mov    %eax,0x4(%esp)
  800087:	8b 45 08             	mov    0x8(%ebp),%eax
  80008a:	89 04 24             	mov    %eax,(%esp)
  80008d:	e8 a1 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800092:	e8 02 00 00 00       	call   800099 <exit>
}
  800097:	c9                   	leave  
  800098:	c3                   	ret    

00800099 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80009f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a6:	e8 e9 00 00 00       	call   800194 <sys_env_destroy>
}
  8000ab:	c9                   	leave  
  8000ac:	c3                   	ret    

008000ad <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000ad:	55                   	push   %ebp
  8000ae:	89 e5                	mov    %esp,%ebp
  8000b0:	57                   	push   %edi
  8000b1:	56                   	push   %esi
  8000b2:	53                   	push   %ebx
  8000b3:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8000b9:	8b 55 10             	mov    0x10(%ebp),%edx
  8000bc:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8000bf:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8000c2:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  8000c5:	8b 75 20             	mov    0x20(%ebp),%esi
  8000c8:	cd 30                	int    $0x30
  8000ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000cd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8000d1:	74 30                	je     800103 <syscall+0x56>
  8000d3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000d7:	7e 2a                	jle    800103 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000dc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8000e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000e7:	c7 44 24 08 6a 15 80 	movl   $0x80156a,0x8(%esp)
  8000ee:	00 
  8000ef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000f6:	00 
  8000f7:	c7 04 24 87 15 80 00 	movl   $0x801587,(%esp)
  8000fe:	e8 1b 04 00 00       	call   80051e <_panic>

	return ret;
  800103:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800106:	83 c4 3c             	add    $0x3c,%esp
  800109:	5b                   	pop    %ebx
  80010a:	5e                   	pop    %esi
  80010b:	5f                   	pop    %edi
  80010c:	5d                   	pop    %ebp
  80010d:	c3                   	ret    

0080010e <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  80010e:	55                   	push   %ebp
  80010f:	89 e5                	mov    %esp,%ebp
  800111:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800114:	8b 45 08             	mov    0x8(%ebp),%eax
  800117:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80011e:	00 
  80011f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800126:	00 
  800127:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80012e:	00 
  80012f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800132:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800136:	89 44 24 08          	mov    %eax,0x8(%esp)
  80013a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800141:	00 
  800142:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800149:	e8 5f ff ff ff       	call   8000ad <syscall>
}
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    

00800150 <sys_cgetc>:

int
sys_cgetc(void)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800156:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80015d:	00 
  80015e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800165:	00 
  800166:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80016d:	00 
  80016e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800175:	00 
  800176:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80017d:	00 
  80017e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800185:	00 
  800186:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80018d:	e8 1b ff ff ff       	call   8000ad <syscall>
}
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80019a:	8b 45 08             	mov    0x8(%ebp),%eax
  80019d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001a4:	00 
  8001a5:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001ac:	00 
  8001ad:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001b4:	00 
  8001b5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001bc:	00 
  8001bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001c8:	00 
  8001c9:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8001d0:	e8 d8 fe ff ff       	call   8000ad <syscall>
}
  8001d5:	c9                   	leave  
  8001d6:	c3                   	ret    

008001d7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8001dd:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001e4:	00 
  8001e5:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001ec:	00 
  8001ed:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001f4:	00 
  8001f5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001fc:	00 
  8001fd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800204:	00 
  800205:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80020c:	00 
  80020d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800214:	e8 94 fe ff ff       	call   8000ad <syscall>
}
  800219:	c9                   	leave  
  80021a:	c3                   	ret    

0080021b <sys_yield>:

void
sys_yield(void)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800221:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800228:	00 
  800229:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800230:	00 
  800231:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800238:	00 
  800239:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800240:	00 
  800241:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800248:	00 
  800249:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800250:	00 
  800251:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800258:	e8 50 fe ff ff       	call   8000ad <syscall>
}
  80025d:	c9                   	leave  
  80025e:	c3                   	ret    

0080025f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800265:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800268:	8b 55 0c             	mov    0xc(%ebp),%edx
  80026b:	8b 45 08             	mov    0x8(%ebp),%eax
  80026e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800275:	00 
  800276:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80027d:	00 
  80027e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800282:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800286:	89 44 24 08          	mov    %eax,0x8(%esp)
  80028a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800291:	00 
  800292:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800299:	e8 0f fe ff ff       	call   8000ad <syscall>
}
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	56                   	push   %esi
  8002a4:	53                   	push   %ebx
  8002a5:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8002a8:	8b 75 18             	mov    0x18(%ebp),%esi
  8002ab:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b7:	89 74 24 18          	mov    %esi,0x18(%esp)
  8002bb:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002bf:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002c3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002cb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002d2:	00 
  8002d3:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8002da:	e8 ce fd ff ff       	call   8000ad <syscall>
}
  8002df:	83 c4 20             	add    $0x20,%esp
  8002e2:	5b                   	pop    %ebx
  8002e3:	5e                   	pop    %esi
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8002ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f2:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8002f9:	00 
  8002fa:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800301:	00 
  800302:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800309:	00 
  80030a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80030e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800312:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800319:	00 
  80031a:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  800321:	e8 87 fd ff ff       	call   8000ad <syscall>
}
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80032e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800331:	8b 45 08             	mov    0x8(%ebp),%eax
  800334:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80033b:	00 
  80033c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800343:	00 
  800344:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80034b:	00 
  80034c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800350:	89 44 24 08          	mov    %eax,0x8(%esp)
  800354:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80035b:	00 
  80035c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800363:	e8 45 fd ff ff       	call   8000ad <syscall>
}
  800368:	c9                   	leave  
  800369:	c3                   	ret    

0080036a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800370:	8b 55 0c             	mov    0xc(%ebp),%edx
  800373:	8b 45 08             	mov    0x8(%ebp),%eax
  800376:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80037d:	00 
  80037e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800385:	00 
  800386:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80038d:	00 
  80038e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800392:	89 44 24 08          	mov    %eax,0x8(%esp)
  800396:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80039d:	00 
  80039e:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8003a5:	e8 03 fd ff ff       	call   8000ad <syscall>
}
  8003aa:	c9                   	leave  
  8003ab:	c3                   	ret    

008003ac <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8003b2:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003b5:	8b 55 10             	mov    0x10(%ebp),%edx
  8003b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bb:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003c2:	00 
  8003c3:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8003c7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003dd:	00 
  8003de:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8003e5:	e8 c3 fc ff ff       	call   8000ad <syscall>
}
  8003ea:	c9                   	leave  
  8003eb:	c3                   	ret    

008003ec <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8003f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003fc:	00 
  8003fd:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800404:	00 
  800405:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80040c:	00 
  80040d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800414:	00 
  800415:	89 44 24 08          	mov    %eax,0x8(%esp)
  800419:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800420:	00 
  800421:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  800428:	e8 80 fc ff ff       	call   8000ad <syscall>
}
  80042d:	c9                   	leave  
  80042e:	c3                   	ret    

0080042f <sys_exec>:

void sys_exec(char* buf){
  80042f:	55                   	push   %ebp
  800430:	89 e5                	mov    %esp,%ebp
  800432:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  800435:	8b 45 08             	mov    0x8(%ebp),%eax
  800438:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80043f:	00 
  800440:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800447:	00 
  800448:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80044f:	00 
  800450:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800457:	00 
  800458:	89 44 24 08          	mov    %eax,0x8(%esp)
  80045c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800463:	00 
  800464:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  80046b:	e8 3d fc ff ff       	call   8000ad <syscall>
}
  800470:	c9                   	leave  
  800471:	c3                   	ret    

00800472 <sys_wait>:

void sys_wait(){
  800472:	55                   	push   %ebp
  800473:	89 e5                	mov    %esp,%ebp
  800475:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_wait, 0, 0, 0, 0, 0, 0);
  800478:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80047f:	00 
  800480:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800487:	00 
  800488:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80048f:	00 
  800490:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800497:	00 
  800498:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80049f:	00 
  8004a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004a7:	00 
  8004a8:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  8004af:	e8 f9 fb ff ff       	call   8000ad <syscall>
}
  8004b4:	c9                   	leave  
  8004b5:	c3                   	ret    

008004b6 <sys_guest>:

void sys_guest(){
  8004b6:	55                   	push   %ebp
  8004b7:	89 e5                	mov    %esp,%ebp
  8004b9:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_guest, 0, 0, 0, 0, 0, 0);
  8004bc:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8004c3:	00 
  8004c4:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8004cb:	00 
  8004cc:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8004d3:	00 
  8004d4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004db:	00 
  8004dc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004e3:	00 
  8004e4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004eb:	00 
  8004ec:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
  8004f3:	e8 b5 fb ff ff       	call   8000ad <syscall>
  8004f8:	c9                   	leave  
  8004f9:	c3                   	ret    

008004fa <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8004fa:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8004fb:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800500:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800502:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 40(%esp) , %eax 		//store trap-time eip in eax
  800505:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %esp , %ebp 			// save current stack location
  800509:	89 e5                	mov    %esp,%ebp
	movl 48(%esp) , %esp 		// switch to trap time stack
  80050b:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 					// push eip, esp gets changed
  80050f:	50                   	push   %eax
	movl %esp , 48(%ebp) 		// save current esp to update the trap time esp
  800510:	89 65 30             	mov    %esp,0x30(%ebp)
	movl %ebp , %esp 			// move to user stack
  800513:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	popl %eax 					// pop fault_va
  800515:	58                   	pop    %eax
	popl %eax 					// pop tf_err
  800516:	58                   	pop    %eax
	popal 						// pop all the registers
  800517:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4 , %esp
  800518:	83 c4 04             	add    $0x4,%esp
	popfl
  80051b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp
  80051c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80051d:	c3                   	ret    

0080051e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80051e:	55                   	push   %ebp
  80051f:	89 e5                	mov    %esp,%ebp
  800521:	53                   	push   %ebx
  800522:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  800525:	8d 45 14             	lea    0x14(%ebp),%eax
  800528:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80052b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800531:	e8 a1 fc ff ff       	call   8001d7 <sys_getenvid>
  800536:	8b 55 0c             	mov    0xc(%ebp),%edx
  800539:	89 54 24 10          	mov    %edx,0x10(%esp)
  80053d:	8b 55 08             	mov    0x8(%ebp),%edx
  800540:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800544:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800548:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054c:	c7 04 24 98 15 80 00 	movl   $0x801598,(%esp)
  800553:	e8 e1 00 00 00       	call   800639 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800558:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80055b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055f:	8b 45 10             	mov    0x10(%ebp),%eax
  800562:	89 04 24             	mov    %eax,(%esp)
  800565:	e8 6b 00 00 00       	call   8005d5 <vcprintf>
	cprintf("\n");
  80056a:	c7 04 24 bb 15 80 00 	movl   $0x8015bb,(%esp)
  800571:	e8 c3 00 00 00       	call   800639 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800576:	cc                   	int3   
  800577:	eb fd                	jmp    800576 <_panic+0x58>

00800579 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800579:	55                   	push   %ebp
  80057a:	89 e5                	mov    %esp,%ebp
  80057c:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  80057f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800582:	8b 00                	mov    (%eax),%eax
  800584:	8d 48 01             	lea    0x1(%eax),%ecx
  800587:	8b 55 0c             	mov    0xc(%ebp),%edx
  80058a:	89 0a                	mov    %ecx,(%edx)
  80058c:	8b 55 08             	mov    0x8(%ebp),%edx
  80058f:	89 d1                	mov    %edx,%ecx
  800591:	8b 55 0c             	mov    0xc(%ebp),%edx
  800594:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800598:	8b 45 0c             	mov    0xc(%ebp),%eax
  80059b:	8b 00                	mov    (%eax),%eax
  80059d:	3d ff 00 00 00       	cmp    $0xff,%eax
  8005a2:	75 20                	jne    8005c4 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8005a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005a7:	8b 00                	mov    (%eax),%eax
  8005a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005ac:	83 c2 08             	add    $0x8,%edx
  8005af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b3:	89 14 24             	mov    %edx,(%esp)
  8005b6:	e8 53 fb ff ff       	call   80010e <sys_cputs>
		b->idx = 0;
  8005bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005be:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8005c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005c7:	8b 40 04             	mov    0x4(%eax),%eax
  8005ca:	8d 50 01             	lea    0x1(%eax),%edx
  8005cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005d0:	89 50 04             	mov    %edx,0x4(%eax)
}
  8005d3:	c9                   	leave  
  8005d4:	c3                   	ret    

008005d5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8005d5:	55                   	push   %ebp
  8005d6:	89 e5                	mov    %esp,%ebp
  8005d8:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8005de:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8005e5:	00 00 00 
	b.cnt = 0;
  8005e8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8005ef:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8005f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800600:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800606:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060a:	c7 04 24 79 05 80 00 	movl   $0x800579,(%esp)
  800611:	e8 bd 01 00 00       	call   8007d3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800616:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80061c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800620:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800626:	83 c0 08             	add    $0x8,%eax
  800629:	89 04 24             	mov    %eax,(%esp)
  80062c:	e8 dd fa ff ff       	call   80010e <sys_cputs>

	return b.cnt;
  800631:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800637:	c9                   	leave  
  800638:	c3                   	ret    

00800639 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800639:	55                   	push   %ebp
  80063a:	89 e5                	mov    %esp,%ebp
  80063c:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80063f:	8d 45 0c             	lea    0xc(%ebp),%eax
  800642:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800645:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800648:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064c:	8b 45 08             	mov    0x8(%ebp),%eax
  80064f:	89 04 24             	mov    %eax,(%esp)
  800652:	e8 7e ff ff ff       	call   8005d5 <vcprintf>
  800657:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  80065a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80065d:	c9                   	leave  
  80065e:	c3                   	ret    

0080065f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80065f:	55                   	push   %ebp
  800660:	89 e5                	mov    %esp,%ebp
  800662:	53                   	push   %ebx
  800663:	83 ec 34             	sub    $0x34,%esp
  800666:	8b 45 10             	mov    0x10(%ebp),%eax
  800669:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800672:	8b 45 18             	mov    0x18(%ebp),%eax
  800675:	ba 00 00 00 00       	mov    $0x0,%edx
  80067a:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80067d:	77 72                	ja     8006f1 <printnum+0x92>
  80067f:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800682:	72 05                	jb     800689 <printnum+0x2a>
  800684:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800687:	77 68                	ja     8006f1 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800689:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80068c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80068f:	8b 45 18             	mov    0x18(%ebp),%eax
  800692:	ba 00 00 00 00       	mov    $0x0,%edx
  800697:	89 44 24 08          	mov    %eax,0x8(%esp)
  80069b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80069f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006a5:	89 04 24             	mov    %eax,(%esp)
  8006a8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006ac:	e8 0f 0c 00 00       	call   8012c0 <__udivdi3>
  8006b1:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8006b4:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8006b8:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8006bc:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8006bf:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8006c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006c7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d5:	89 04 24             	mov    %eax,(%esp)
  8006d8:	e8 82 ff ff ff       	call   80065f <printnum>
  8006dd:	eb 1c                	jmp    8006fb <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8006df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006e6:	8b 45 20             	mov    0x20(%ebp),%eax
  8006e9:	89 04 24             	mov    %eax,(%esp)
  8006ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ef:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006f1:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8006f5:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8006f9:	7f e4                	jg     8006df <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006fb:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8006fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800703:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800706:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800709:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80070d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800711:	89 04 24             	mov    %eax,(%esp)
  800714:	89 54 24 04          	mov    %edx,0x4(%esp)
  800718:	e8 d3 0c 00 00       	call   8013f0 <__umoddi3>
  80071d:	05 88 16 80 00       	add    $0x801688,%eax
  800722:	0f b6 00             	movzbl (%eax),%eax
  800725:	0f be c0             	movsbl %al,%eax
  800728:	8b 55 0c             	mov    0xc(%ebp),%edx
  80072b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80072f:	89 04 24             	mov    %eax,(%esp)
  800732:	8b 45 08             	mov    0x8(%ebp),%eax
  800735:	ff d0                	call   *%eax
}
  800737:	83 c4 34             	add    $0x34,%esp
  80073a:	5b                   	pop    %ebx
  80073b:	5d                   	pop    %ebp
  80073c:	c3                   	ret    

0080073d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800740:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800744:	7e 14                	jle    80075a <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800746:	8b 45 08             	mov    0x8(%ebp),%eax
  800749:	8b 00                	mov    (%eax),%eax
  80074b:	8d 48 08             	lea    0x8(%eax),%ecx
  80074e:	8b 55 08             	mov    0x8(%ebp),%edx
  800751:	89 0a                	mov    %ecx,(%edx)
  800753:	8b 50 04             	mov    0x4(%eax),%edx
  800756:	8b 00                	mov    (%eax),%eax
  800758:	eb 30                	jmp    80078a <getuint+0x4d>
	else if (lflag)
  80075a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80075e:	74 16                	je     800776 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800760:	8b 45 08             	mov    0x8(%ebp),%eax
  800763:	8b 00                	mov    (%eax),%eax
  800765:	8d 48 04             	lea    0x4(%eax),%ecx
  800768:	8b 55 08             	mov    0x8(%ebp),%edx
  80076b:	89 0a                	mov    %ecx,(%edx)
  80076d:	8b 00                	mov    (%eax),%eax
  80076f:	ba 00 00 00 00       	mov    $0x0,%edx
  800774:	eb 14                	jmp    80078a <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800776:	8b 45 08             	mov    0x8(%ebp),%eax
  800779:	8b 00                	mov    (%eax),%eax
  80077b:	8d 48 04             	lea    0x4(%eax),%ecx
  80077e:	8b 55 08             	mov    0x8(%ebp),%edx
  800781:	89 0a                	mov    %ecx,(%edx)
  800783:	8b 00                	mov    (%eax),%eax
  800785:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80078a:	5d                   	pop    %ebp
  80078b:	c3                   	ret    

0080078c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80078f:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800793:	7e 14                	jle    8007a9 <getint+0x1d>
		return va_arg(*ap, long long);
  800795:	8b 45 08             	mov    0x8(%ebp),%eax
  800798:	8b 00                	mov    (%eax),%eax
  80079a:	8d 48 08             	lea    0x8(%eax),%ecx
  80079d:	8b 55 08             	mov    0x8(%ebp),%edx
  8007a0:	89 0a                	mov    %ecx,(%edx)
  8007a2:	8b 50 04             	mov    0x4(%eax),%edx
  8007a5:	8b 00                	mov    (%eax),%eax
  8007a7:	eb 28                	jmp    8007d1 <getint+0x45>
	else if (lflag)
  8007a9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8007ad:	74 12                	je     8007c1 <getint+0x35>
		return va_arg(*ap, long);
  8007af:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b2:	8b 00                	mov    (%eax),%eax
  8007b4:	8d 48 04             	lea    0x4(%eax),%ecx
  8007b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8007ba:	89 0a                	mov    %ecx,(%edx)
  8007bc:	8b 00                	mov    (%eax),%eax
  8007be:	99                   	cltd   
  8007bf:	eb 10                	jmp    8007d1 <getint+0x45>
	else
		return va_arg(*ap, int);
  8007c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c4:	8b 00                	mov    (%eax),%eax
  8007c6:	8d 48 04             	lea    0x4(%eax),%ecx
  8007c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8007cc:	89 0a                	mov    %ecx,(%edx)
  8007ce:	8b 00                	mov    (%eax),%eax
  8007d0:	99                   	cltd   
}
  8007d1:	5d                   	pop    %ebp
  8007d2:	c3                   	ret    

008007d3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	56                   	push   %esi
  8007d7:	53                   	push   %ebx
  8007d8:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007db:	eb 18                	jmp    8007f5 <vprintfmt+0x22>
			if (ch == '\0')
  8007dd:	85 db                	test   %ebx,%ebx
  8007df:	75 05                	jne    8007e6 <vprintfmt+0x13>
				return;
  8007e1:	e9 cc 03 00 00       	jmp    800bb2 <vprintfmt+0x3df>
			putch(ch, putdat);
  8007e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ed:	89 1c 24             	mov    %ebx,(%esp)
  8007f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f3:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f8:	8d 50 01             	lea    0x1(%eax),%edx
  8007fb:	89 55 10             	mov    %edx,0x10(%ebp)
  8007fe:	0f b6 00             	movzbl (%eax),%eax
  800801:	0f b6 d8             	movzbl %al,%ebx
  800804:	83 fb 25             	cmp    $0x25,%ebx
  800807:	75 d4                	jne    8007dd <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800809:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80080d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800814:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80081b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800822:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800829:	8b 45 10             	mov    0x10(%ebp),%eax
  80082c:	8d 50 01             	lea    0x1(%eax),%edx
  80082f:	89 55 10             	mov    %edx,0x10(%ebp)
  800832:	0f b6 00             	movzbl (%eax),%eax
  800835:	0f b6 d8             	movzbl %al,%ebx
  800838:	8d 43 dd             	lea    -0x23(%ebx),%eax
  80083b:	83 f8 55             	cmp    $0x55,%eax
  80083e:	0f 87 3d 03 00 00    	ja     800b81 <vprintfmt+0x3ae>
  800844:	8b 04 85 ac 16 80 00 	mov    0x8016ac(,%eax,4),%eax
  80084b:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  80084d:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800851:	eb d6                	jmp    800829 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800853:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800857:	eb d0                	jmp    800829 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800859:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800860:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800863:	89 d0                	mov    %edx,%eax
  800865:	c1 e0 02             	shl    $0x2,%eax
  800868:	01 d0                	add    %edx,%eax
  80086a:	01 c0                	add    %eax,%eax
  80086c:	01 d8                	add    %ebx,%eax
  80086e:	83 e8 30             	sub    $0x30,%eax
  800871:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800874:	8b 45 10             	mov    0x10(%ebp),%eax
  800877:	0f b6 00             	movzbl (%eax),%eax
  80087a:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  80087d:	83 fb 2f             	cmp    $0x2f,%ebx
  800880:	7e 0b                	jle    80088d <vprintfmt+0xba>
  800882:	83 fb 39             	cmp    $0x39,%ebx
  800885:	7f 06                	jg     80088d <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800887:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80088b:	eb d3                	jmp    800860 <vprintfmt+0x8d>
			goto process_precision;
  80088d:	eb 33                	jmp    8008c2 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  80088f:	8b 45 14             	mov    0x14(%ebp),%eax
  800892:	8d 50 04             	lea    0x4(%eax),%edx
  800895:	89 55 14             	mov    %edx,0x14(%ebp)
  800898:	8b 00                	mov    (%eax),%eax
  80089a:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80089d:	eb 23                	jmp    8008c2 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  80089f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008a3:	79 0c                	jns    8008b1 <vprintfmt+0xde>
				width = 0;
  8008a5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8008ac:	e9 78 ff ff ff       	jmp    800829 <vprintfmt+0x56>
  8008b1:	e9 73 ff ff ff       	jmp    800829 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8008b6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8008bd:	e9 67 ff ff ff       	jmp    800829 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  8008c2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008c6:	79 12                	jns    8008da <vprintfmt+0x107>
				width = precision, precision = -1;
  8008c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008ce:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8008d5:	e9 4f ff ff ff       	jmp    800829 <vprintfmt+0x56>
  8008da:	e9 4a ff ff ff       	jmp    800829 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008df:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8008e3:	e9 41 ff ff ff       	jmp    800829 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008eb:	8d 50 04             	lea    0x4(%eax),%edx
  8008ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8008f1:	8b 00                	mov    (%eax),%eax
  8008f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008fa:	89 04 24             	mov    %eax,(%esp)
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	ff d0                	call   *%eax
			break;
  800902:	e9 a5 02 00 00       	jmp    800bac <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800907:	8b 45 14             	mov    0x14(%ebp),%eax
  80090a:	8d 50 04             	lea    0x4(%eax),%edx
  80090d:	89 55 14             	mov    %edx,0x14(%ebp)
  800910:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800912:	85 db                	test   %ebx,%ebx
  800914:	79 02                	jns    800918 <vprintfmt+0x145>
				err = -err;
  800916:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800918:	83 fb 09             	cmp    $0x9,%ebx
  80091b:	7f 0b                	jg     800928 <vprintfmt+0x155>
  80091d:	8b 34 9d 60 16 80 00 	mov    0x801660(,%ebx,4),%esi
  800924:	85 f6                	test   %esi,%esi
  800926:	75 23                	jne    80094b <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800928:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80092c:	c7 44 24 08 99 16 80 	movl   $0x801699,0x8(%esp)
  800933:	00 
  800934:	8b 45 0c             	mov    0xc(%ebp),%eax
  800937:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093b:	8b 45 08             	mov    0x8(%ebp),%eax
  80093e:	89 04 24             	mov    %eax,(%esp)
  800941:	e8 73 02 00 00       	call   800bb9 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800946:	e9 61 02 00 00       	jmp    800bac <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80094b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80094f:	c7 44 24 08 a2 16 80 	movl   $0x8016a2,0x8(%esp)
  800956:	00 
  800957:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	89 04 24             	mov    %eax,(%esp)
  800964:	e8 50 02 00 00       	call   800bb9 <printfmt>
			break;
  800969:	e9 3e 02 00 00       	jmp    800bac <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80096e:	8b 45 14             	mov    0x14(%ebp),%eax
  800971:	8d 50 04             	lea    0x4(%eax),%edx
  800974:	89 55 14             	mov    %edx,0x14(%ebp)
  800977:	8b 30                	mov    (%eax),%esi
  800979:	85 f6                	test   %esi,%esi
  80097b:	75 05                	jne    800982 <vprintfmt+0x1af>
				p = "(null)";
  80097d:	be a5 16 80 00       	mov    $0x8016a5,%esi
			if (width > 0 && padc != '-')
  800982:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800986:	7e 37                	jle    8009bf <vprintfmt+0x1ec>
  800988:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  80098c:	74 31                	je     8009bf <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  80098e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800991:	89 44 24 04          	mov    %eax,0x4(%esp)
  800995:	89 34 24             	mov    %esi,(%esp)
  800998:	e8 39 03 00 00       	call   800cd6 <strnlen>
  80099d:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8009a0:	eb 17                	jmp    8009b9 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8009a2:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8009a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009ad:	89 04 24             	mov    %eax,(%esp)
  8009b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b3:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009b5:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8009b9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009bd:	7f e3                	jg     8009a2 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009bf:	eb 38                	jmp    8009f9 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8009c1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009c5:	74 1f                	je     8009e6 <vprintfmt+0x213>
  8009c7:	83 fb 1f             	cmp    $0x1f,%ebx
  8009ca:	7e 05                	jle    8009d1 <vprintfmt+0x1fe>
  8009cc:	83 fb 7e             	cmp    $0x7e,%ebx
  8009cf:	7e 15                	jle    8009e6 <vprintfmt+0x213>
					putch('?', putdat);
  8009d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e2:	ff d0                	call   *%eax
  8009e4:	eb 0f                	jmp    8009f5 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8009e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ed:	89 1c 24             	mov    %ebx,(%esp)
  8009f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f3:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009f5:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8009f9:	89 f0                	mov    %esi,%eax
  8009fb:	8d 70 01             	lea    0x1(%eax),%esi
  8009fe:	0f b6 00             	movzbl (%eax),%eax
  800a01:	0f be d8             	movsbl %al,%ebx
  800a04:	85 db                	test   %ebx,%ebx
  800a06:	74 10                	je     800a18 <vprintfmt+0x245>
  800a08:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a0c:	78 b3                	js     8009c1 <vprintfmt+0x1ee>
  800a0e:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800a12:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a16:	79 a9                	jns    8009c1 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a18:	eb 17                	jmp    800a31 <vprintfmt+0x25e>
				putch(' ', putdat);
  800a1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a21:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a28:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2b:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a2d:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800a31:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a35:	7f e3                	jg     800a1a <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800a37:	e9 70 01 00 00       	jmp    800bac <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a3c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a43:	8d 45 14             	lea    0x14(%ebp),%eax
  800a46:	89 04 24             	mov    %eax,(%esp)
  800a49:	e8 3e fd ff ff       	call   80078c <getint>
  800a4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a51:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a57:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a5a:	85 d2                	test   %edx,%edx
  800a5c:	79 26                	jns    800a84 <vprintfmt+0x2b1>
				putch('-', putdat);
  800a5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a61:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a65:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6f:	ff d0                	call   *%eax
				num = -(long long) num;
  800a71:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a74:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a77:	f7 d8                	neg    %eax
  800a79:	83 d2 00             	adc    $0x0,%edx
  800a7c:	f7 da                	neg    %edx
  800a7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a81:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800a84:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a8b:	e9 a8 00 00 00       	jmp    800b38 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a90:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a93:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a97:	8d 45 14             	lea    0x14(%ebp),%eax
  800a9a:	89 04 24             	mov    %eax,(%esp)
  800a9d:	e8 9b fc ff ff       	call   80073d <getuint>
  800aa2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800aa5:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800aa8:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800aaf:	e9 84 00 00 00       	jmp    800b38 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800ab4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800abb:	8d 45 14             	lea    0x14(%ebp),%eax
  800abe:	89 04 24             	mov    %eax,(%esp)
  800ac1:	e8 77 fc ff ff       	call   80073d <getuint>
  800ac6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ac9:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800acc:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800ad3:	eb 63                	jmp    800b38 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800ad5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800adc:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800ae3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae6:	ff d0                	call   *%eax
			putch('x', putdat);
  800ae8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aeb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aef:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800af6:	8b 45 08             	mov    0x8(%ebp),%eax
  800af9:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800afb:	8b 45 14             	mov    0x14(%ebp),%eax
  800afe:	8d 50 04             	lea    0x4(%eax),%edx
  800b01:	89 55 14             	mov    %edx,0x14(%ebp)
  800b04:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b06:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b09:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b10:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800b17:	eb 1f                	jmp    800b38 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b19:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800b1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b20:	8d 45 14             	lea    0x14(%ebp),%eax
  800b23:	89 04 24             	mov    %eax,(%esp)
  800b26:	e8 12 fc ff ff       	call   80073d <getuint>
  800b2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b2e:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800b31:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b38:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800b3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b3f:	89 54 24 18          	mov    %edx,0x18(%esp)
  800b43:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b46:	89 54 24 14          	mov    %edx,0x14(%esp)
  800b4a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b51:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b54:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b58:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b63:	8b 45 08             	mov    0x8(%ebp),%eax
  800b66:	89 04 24             	mov    %eax,(%esp)
  800b69:	e8 f1 fa ff ff       	call   80065f <printnum>
			break;
  800b6e:	eb 3c                	jmp    800bac <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b70:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b73:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b77:	89 1c 24             	mov    %ebx,(%esp)
  800b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7d:	ff d0                	call   *%eax
			break;
  800b7f:	eb 2b                	jmp    800bac <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b81:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b84:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b88:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b92:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b94:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b98:	eb 04                	jmp    800b9e <vprintfmt+0x3cb>
  800b9a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b9e:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba1:	83 e8 01             	sub    $0x1,%eax
  800ba4:	0f b6 00             	movzbl (%eax),%eax
  800ba7:	3c 25                	cmp    $0x25,%al
  800ba9:	75 ef                	jne    800b9a <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800bab:	90                   	nop
		}
	}
  800bac:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800bad:	e9 43 fc ff ff       	jmp    8007f5 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800bb2:	83 c4 40             	add    $0x40,%esp
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800bbf:	8d 45 14             	lea    0x14(%ebp),%eax
  800bc2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bc8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bcc:	8b 45 10             	mov    0x10(%ebp),%eax
  800bcf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bda:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdd:	89 04 24             	mov    %eax,(%esp)
  800be0:	e8 ee fb ff ff       	call   8007d3 <vprintfmt>
	va_end(ap);
}
  800be5:	c9                   	leave  
  800be6:	c3                   	ret    

00800be7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800bea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bed:	8b 40 08             	mov    0x8(%eax),%eax
  800bf0:	8d 50 01             	lea    0x1(%eax),%edx
  800bf3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf6:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800bf9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bfc:	8b 10                	mov    (%eax),%edx
  800bfe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c01:	8b 40 04             	mov    0x4(%eax),%eax
  800c04:	39 c2                	cmp    %eax,%edx
  800c06:	73 12                	jae    800c1a <sprintputch+0x33>
		*b->buf++ = ch;
  800c08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c0b:	8b 00                	mov    (%eax),%eax
  800c0d:	8d 48 01             	lea    0x1(%eax),%ecx
  800c10:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c13:	89 0a                	mov    %ecx,(%edx)
  800c15:	8b 55 08             	mov    0x8(%ebp),%edx
  800c18:	88 10                	mov    %dl,(%eax)
}
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c22:	8b 45 08             	mov    0x8(%ebp),%eax
  800c25:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2b:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c31:	01 d0                	add    %edx,%eax
  800c33:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c3d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800c41:	74 06                	je     800c49 <vsnprintf+0x2d>
  800c43:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c47:	7f 07                	jg     800c50 <vsnprintf+0x34>
		return -E_INVAL;
  800c49:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c4e:	eb 2a                	jmp    800c7a <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c50:	8b 45 14             	mov    0x14(%ebp),%eax
  800c53:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c57:	8b 45 10             	mov    0x10(%ebp),%eax
  800c5a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c5e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c61:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c65:	c7 04 24 e7 0b 80 00 	movl   $0x800be7,(%esp)
  800c6c:	e8 62 fb ff ff       	call   8007d3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c71:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c74:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c7a:	c9                   	leave  
  800c7b:	c3                   	ret    

00800c7c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c82:	8d 45 14             	lea    0x14(%ebp),%eax
  800c85:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800c88:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c8b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c8f:	8b 45 10             	mov    0x10(%ebp),%eax
  800c92:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c96:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c99:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca0:	89 04 24             	mov    %eax,(%esp)
  800ca3:	e8 74 ff ff ff       	call   800c1c <vsnprintf>
  800ca8:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800cae:	c9                   	leave  
  800caf:	c3                   	ret    

00800cb0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800cb6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800cbd:	eb 08                	jmp    800cc7 <strlen+0x17>
		n++;
  800cbf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800cc3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cca:	0f b6 00             	movzbl (%eax),%eax
  800ccd:	84 c0                	test   %al,%al
  800ccf:	75 ee                	jne    800cbf <strlen+0xf>
		n++;
	return n;
  800cd1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800cd4:	c9                   	leave  
  800cd5:	c3                   	ret    

00800cd6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cdc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800ce3:	eb 0c                	jmp    800cf1 <strnlen+0x1b>
		n++;
  800ce5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ce9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ced:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800cf1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cf5:	74 0a                	je     800d01 <strnlen+0x2b>
  800cf7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfa:	0f b6 00             	movzbl (%eax),%eax
  800cfd:	84 c0                	test   %al,%al
  800cff:	75 e4                	jne    800ce5 <strnlen+0xf>
		n++;
	return n;
  800d01:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800d04:	c9                   	leave  
  800d05:	c3                   	ret    

00800d06 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800d0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800d12:	90                   	nop
  800d13:	8b 45 08             	mov    0x8(%ebp),%eax
  800d16:	8d 50 01             	lea    0x1(%eax),%edx
  800d19:	89 55 08             	mov    %edx,0x8(%ebp)
  800d1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d1f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d22:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d25:	0f b6 12             	movzbl (%edx),%edx
  800d28:	88 10                	mov    %dl,(%eax)
  800d2a:	0f b6 00             	movzbl (%eax),%eax
  800d2d:	84 c0                	test   %al,%al
  800d2f:	75 e2                	jne    800d13 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800d31:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800d34:	c9                   	leave  
  800d35:	c3                   	ret    

00800d36 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800d3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3f:	89 04 24             	mov    %eax,(%esp)
  800d42:	e8 69 ff ff ff       	call   800cb0 <strlen>
  800d47:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800d4a:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800d4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d50:	01 c2                	add    %eax,%edx
  800d52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d55:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d59:	89 14 24             	mov    %edx,(%esp)
  800d5c:	e8 a5 ff ff ff       	call   800d06 <strcpy>
	return dst;
  800d61:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d64:	c9                   	leave  
  800d65:	c3                   	ret    

00800d66 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800d6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6f:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800d72:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800d79:	eb 23                	jmp    800d9e <strncpy+0x38>
		*dst++ = *src;
  800d7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7e:	8d 50 01             	lea    0x1(%eax),%edx
  800d81:	89 55 08             	mov    %edx,0x8(%ebp)
  800d84:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d87:	0f b6 12             	movzbl (%edx),%edx
  800d8a:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800d8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d8f:	0f b6 00             	movzbl (%eax),%eax
  800d92:	84 c0                	test   %al,%al
  800d94:	74 04                	je     800d9a <strncpy+0x34>
			src++;
  800d96:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d9a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800da1:	3b 45 10             	cmp    0x10(%ebp),%eax
  800da4:	72 d5                	jb     800d7b <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800da6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800da9:	c9                   	leave  
  800daa:	c3                   	ret    

00800dab <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800db1:	8b 45 08             	mov    0x8(%ebp),%eax
  800db4:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800db7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dbb:	74 33                	je     800df0 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800dbd:	eb 17                	jmp    800dd6 <strlcpy+0x2b>
			*dst++ = *src++;
  800dbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc2:	8d 50 01             	lea    0x1(%eax),%edx
  800dc5:	89 55 08             	mov    %edx,0x8(%ebp)
  800dc8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dcb:	8d 4a 01             	lea    0x1(%edx),%ecx
  800dce:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800dd1:	0f b6 12             	movzbl (%edx),%edx
  800dd4:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800dd6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800dda:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dde:	74 0a                	je     800dea <strlcpy+0x3f>
  800de0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de3:	0f b6 00             	movzbl (%eax),%eax
  800de6:	84 c0                	test   %al,%al
  800de8:	75 d5                	jne    800dbf <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800dea:	8b 45 08             	mov    0x8(%ebp),%eax
  800ded:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800df0:	8b 55 08             	mov    0x8(%ebp),%edx
  800df3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800df6:	29 c2                	sub    %eax,%edx
  800df8:	89 d0                	mov    %edx,%eax
}
  800dfa:	c9                   	leave  
  800dfb:	c3                   	ret    

00800dfc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800dff:	eb 08                	jmp    800e09 <strcmp+0xd>
		p++, q++;
  800e01:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e05:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e09:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0c:	0f b6 00             	movzbl (%eax),%eax
  800e0f:	84 c0                	test   %al,%al
  800e11:	74 10                	je     800e23 <strcmp+0x27>
  800e13:	8b 45 08             	mov    0x8(%ebp),%eax
  800e16:	0f b6 10             	movzbl (%eax),%edx
  800e19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e1c:	0f b6 00             	movzbl (%eax),%eax
  800e1f:	38 c2                	cmp    %al,%dl
  800e21:	74 de                	je     800e01 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e23:	8b 45 08             	mov    0x8(%ebp),%eax
  800e26:	0f b6 00             	movzbl (%eax),%eax
  800e29:	0f b6 d0             	movzbl %al,%edx
  800e2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e2f:	0f b6 00             	movzbl (%eax),%eax
  800e32:	0f b6 c0             	movzbl %al,%eax
  800e35:	29 c2                	sub    %eax,%edx
  800e37:	89 d0                	mov    %edx,%eax
}
  800e39:	5d                   	pop    %ebp
  800e3a:	c3                   	ret    

00800e3b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e3b:	55                   	push   %ebp
  800e3c:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800e3e:	eb 0c                	jmp    800e4c <strncmp+0x11>
		n--, p++, q++;
  800e40:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800e44:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e48:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e4c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e50:	74 1a                	je     800e6c <strncmp+0x31>
  800e52:	8b 45 08             	mov    0x8(%ebp),%eax
  800e55:	0f b6 00             	movzbl (%eax),%eax
  800e58:	84 c0                	test   %al,%al
  800e5a:	74 10                	je     800e6c <strncmp+0x31>
  800e5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5f:	0f b6 10             	movzbl (%eax),%edx
  800e62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e65:	0f b6 00             	movzbl (%eax),%eax
  800e68:	38 c2                	cmp    %al,%dl
  800e6a:	74 d4                	je     800e40 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800e6c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e70:	75 07                	jne    800e79 <strncmp+0x3e>
		return 0;
  800e72:	b8 00 00 00 00       	mov    $0x0,%eax
  800e77:	eb 16                	jmp    800e8f <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e79:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7c:	0f b6 00             	movzbl (%eax),%eax
  800e7f:	0f b6 d0             	movzbl %al,%edx
  800e82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e85:	0f b6 00             	movzbl (%eax),%eax
  800e88:	0f b6 c0             	movzbl %al,%eax
  800e8b:	29 c2                	sub    %eax,%edx
  800e8d:	89 d0                	mov    %edx,%eax
}
  800e8f:	5d                   	pop    %ebp
  800e90:	c3                   	ret    

00800e91 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	83 ec 04             	sub    $0x4,%esp
  800e97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9a:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e9d:	eb 14                	jmp    800eb3 <strchr+0x22>
		if (*s == c)
  800e9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea2:	0f b6 00             	movzbl (%eax),%eax
  800ea5:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800ea8:	75 05                	jne    800eaf <strchr+0x1e>
			return (char *) s;
  800eaa:	8b 45 08             	mov    0x8(%ebp),%eax
  800ead:	eb 13                	jmp    800ec2 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800eaf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800eb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb6:	0f b6 00             	movzbl (%eax),%eax
  800eb9:	84 c0                	test   %al,%al
  800ebb:	75 e2                	jne    800e9f <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800ebd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ec2:	c9                   	leave  
  800ec3:	c3                   	ret    

00800ec4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	83 ec 04             	sub    $0x4,%esp
  800eca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ecd:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800ed0:	eb 11                	jmp    800ee3 <strfind+0x1f>
		if (*s == c)
  800ed2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed5:	0f b6 00             	movzbl (%eax),%eax
  800ed8:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800edb:	75 02                	jne    800edf <strfind+0x1b>
			break;
  800edd:	eb 0e                	jmp    800eed <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800edf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ee3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee6:	0f b6 00             	movzbl (%eax),%eax
  800ee9:	84 c0                	test   %al,%al
  800eeb:	75 e5                	jne    800ed2 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800eed:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ef0:	c9                   	leave  
  800ef1:	c3                   	ret    

00800ef2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
  800ef5:	57                   	push   %edi
	char *p;

	if (n == 0)
  800ef6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800efa:	75 05                	jne    800f01 <memset+0xf>
		return v;
  800efc:	8b 45 08             	mov    0x8(%ebp),%eax
  800eff:	eb 5c                	jmp    800f5d <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800f01:	8b 45 08             	mov    0x8(%ebp),%eax
  800f04:	83 e0 03             	and    $0x3,%eax
  800f07:	85 c0                	test   %eax,%eax
  800f09:	75 41                	jne    800f4c <memset+0x5a>
  800f0b:	8b 45 10             	mov    0x10(%ebp),%eax
  800f0e:	83 e0 03             	and    $0x3,%eax
  800f11:	85 c0                	test   %eax,%eax
  800f13:	75 37                	jne    800f4c <memset+0x5a>
		c &= 0xFF;
  800f15:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1f:	c1 e0 18             	shl    $0x18,%eax
  800f22:	89 c2                	mov    %eax,%edx
  800f24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f27:	c1 e0 10             	shl    $0x10,%eax
  800f2a:	09 c2                	or     %eax,%edx
  800f2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f2f:	c1 e0 08             	shl    $0x8,%eax
  800f32:	09 d0                	or     %edx,%eax
  800f34:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800f37:	8b 45 10             	mov    0x10(%ebp),%eax
  800f3a:	c1 e8 02             	shr    $0x2,%eax
  800f3d:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800f3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f45:	89 d7                	mov    %edx,%edi
  800f47:	fc                   	cld    
  800f48:	f3 ab                	rep stos %eax,%es:(%edi)
  800f4a:	eb 0e                	jmp    800f5a <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f52:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f55:	89 d7                	mov    %edx,%edi
  800f57:	fc                   	cld    
  800f58:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800f5a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f5d:	5f                   	pop    %edi
  800f5e:	5d                   	pop    %ebp
  800f5f:	c3                   	ret    

00800f60 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	57                   	push   %edi
  800f64:	56                   	push   %esi
  800f65:	53                   	push   %ebx
  800f66:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800f69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800f6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f72:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800f75:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f78:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f7b:	73 6d                	jae    800fea <memmove+0x8a>
  800f7d:	8b 45 10             	mov    0x10(%ebp),%eax
  800f80:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f83:	01 d0                	add    %edx,%eax
  800f85:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f88:	76 60                	jbe    800fea <memmove+0x8a>
		s += n;
  800f8a:	8b 45 10             	mov    0x10(%ebp),%eax
  800f8d:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800f90:	8b 45 10             	mov    0x10(%ebp),%eax
  800f93:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f96:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f99:	83 e0 03             	and    $0x3,%eax
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	75 2f                	jne    800fcf <memmove+0x6f>
  800fa0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fa3:	83 e0 03             	and    $0x3,%eax
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	75 25                	jne    800fcf <memmove+0x6f>
  800faa:	8b 45 10             	mov    0x10(%ebp),%eax
  800fad:	83 e0 03             	and    $0x3,%eax
  800fb0:	85 c0                	test   %eax,%eax
  800fb2:	75 1b                	jne    800fcf <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800fb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fb7:	83 e8 04             	sub    $0x4,%eax
  800fba:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fbd:	83 ea 04             	sub    $0x4,%edx
  800fc0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fc3:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800fc6:	89 c7                	mov    %eax,%edi
  800fc8:	89 d6                	mov    %edx,%esi
  800fca:	fd                   	std    
  800fcb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fcd:	eb 18                	jmp    800fe7 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800fcf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fd2:	8d 50 ff             	lea    -0x1(%eax),%edx
  800fd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fd8:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800fdb:	8b 45 10             	mov    0x10(%ebp),%eax
  800fde:	89 d7                	mov    %edx,%edi
  800fe0:	89 de                	mov    %ebx,%esi
  800fe2:	89 c1                	mov    %eax,%ecx
  800fe4:	fd                   	std    
  800fe5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fe7:	fc                   	cld    
  800fe8:	eb 45                	jmp    80102f <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fed:	83 e0 03             	and    $0x3,%eax
  800ff0:	85 c0                	test   %eax,%eax
  800ff2:	75 2b                	jne    80101f <memmove+0xbf>
  800ff4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ff7:	83 e0 03             	and    $0x3,%eax
  800ffa:	85 c0                	test   %eax,%eax
  800ffc:	75 21                	jne    80101f <memmove+0xbf>
  800ffe:	8b 45 10             	mov    0x10(%ebp),%eax
  801001:	83 e0 03             	and    $0x3,%eax
  801004:	85 c0                	test   %eax,%eax
  801006:	75 17                	jne    80101f <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801008:	8b 45 10             	mov    0x10(%ebp),%eax
  80100b:	c1 e8 02             	shr    $0x2,%eax
  80100e:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801010:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801013:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801016:	89 c7                	mov    %eax,%edi
  801018:	89 d6                	mov    %edx,%esi
  80101a:	fc                   	cld    
  80101b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80101d:	eb 10                	jmp    80102f <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80101f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801022:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801025:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801028:	89 c7                	mov    %eax,%edi
  80102a:	89 d6                	mov    %edx,%esi
  80102c:	fc                   	cld    
  80102d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  80102f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801032:	83 c4 10             	add    $0x10,%esp
  801035:	5b                   	pop    %ebx
  801036:	5e                   	pop    %esi
  801037:	5f                   	pop    %edi
  801038:	5d                   	pop    %ebp
  801039:	c3                   	ret    

0080103a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801040:	8b 45 10             	mov    0x10(%ebp),%eax
  801043:	89 44 24 08          	mov    %eax,0x8(%esp)
  801047:	8b 45 0c             	mov    0xc(%ebp),%eax
  80104a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80104e:	8b 45 08             	mov    0x8(%ebp),%eax
  801051:	89 04 24             	mov    %eax,(%esp)
  801054:	e8 07 ff ff ff       	call   800f60 <memmove>
}
  801059:	c9                   	leave  
  80105a:	c3                   	ret    

0080105b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  801061:	8b 45 08             	mov    0x8(%ebp),%eax
  801064:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  801067:	8b 45 0c             	mov    0xc(%ebp),%eax
  80106a:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  80106d:	eb 30                	jmp    80109f <memcmp+0x44>
		if (*s1 != *s2)
  80106f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801072:	0f b6 10             	movzbl (%eax),%edx
  801075:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801078:	0f b6 00             	movzbl (%eax),%eax
  80107b:	38 c2                	cmp    %al,%dl
  80107d:	74 18                	je     801097 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  80107f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801082:	0f b6 00             	movzbl (%eax),%eax
  801085:	0f b6 d0             	movzbl %al,%edx
  801088:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80108b:	0f b6 00             	movzbl (%eax),%eax
  80108e:	0f b6 c0             	movzbl %al,%eax
  801091:	29 c2                	sub    %eax,%edx
  801093:	89 d0                	mov    %edx,%eax
  801095:	eb 1a                	jmp    8010b1 <memcmp+0x56>
		s1++, s2++;
  801097:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80109b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80109f:	8b 45 10             	mov    0x10(%ebp),%eax
  8010a2:	8d 50 ff             	lea    -0x1(%eax),%edx
  8010a5:	89 55 10             	mov    %edx,0x10(%ebp)
  8010a8:	85 c0                	test   %eax,%eax
  8010aa:	75 c3                	jne    80106f <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8010ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010b1:	c9                   	leave  
  8010b2:	c3                   	ret    

008010b3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  8010b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8010bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8010bf:	01 d0                	add    %edx,%eax
  8010c1:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  8010c4:	eb 13                	jmp    8010d9 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  8010c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c9:	0f b6 10             	movzbl (%eax),%edx
  8010cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010cf:	38 c2                	cmp    %al,%dl
  8010d1:	75 02                	jne    8010d5 <memfind+0x22>
			break;
  8010d3:	eb 0c                	jmp    8010e1 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8010d5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010dc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  8010df:	72 e5                	jb     8010c6 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  8010e1:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8010e4:	c9                   	leave  
  8010e5:	c3                   	ret    

008010e6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  8010ec:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  8010f3:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010fa:	eb 04                	jmp    801100 <strtol+0x1a>
		s++;
  8010fc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801100:	8b 45 08             	mov    0x8(%ebp),%eax
  801103:	0f b6 00             	movzbl (%eax),%eax
  801106:	3c 20                	cmp    $0x20,%al
  801108:	74 f2                	je     8010fc <strtol+0x16>
  80110a:	8b 45 08             	mov    0x8(%ebp),%eax
  80110d:	0f b6 00             	movzbl (%eax),%eax
  801110:	3c 09                	cmp    $0x9,%al
  801112:	74 e8                	je     8010fc <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  801114:	8b 45 08             	mov    0x8(%ebp),%eax
  801117:	0f b6 00             	movzbl (%eax),%eax
  80111a:	3c 2b                	cmp    $0x2b,%al
  80111c:	75 06                	jne    801124 <strtol+0x3e>
		s++;
  80111e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801122:	eb 15                	jmp    801139 <strtol+0x53>
	else if (*s == '-')
  801124:	8b 45 08             	mov    0x8(%ebp),%eax
  801127:	0f b6 00             	movzbl (%eax),%eax
  80112a:	3c 2d                	cmp    $0x2d,%al
  80112c:	75 0b                	jne    801139 <strtol+0x53>
		s++, neg = 1;
  80112e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801132:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801139:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80113d:	74 06                	je     801145 <strtol+0x5f>
  80113f:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  801143:	75 24                	jne    801169 <strtol+0x83>
  801145:	8b 45 08             	mov    0x8(%ebp),%eax
  801148:	0f b6 00             	movzbl (%eax),%eax
  80114b:	3c 30                	cmp    $0x30,%al
  80114d:	75 1a                	jne    801169 <strtol+0x83>
  80114f:	8b 45 08             	mov    0x8(%ebp),%eax
  801152:	83 c0 01             	add    $0x1,%eax
  801155:	0f b6 00             	movzbl (%eax),%eax
  801158:	3c 78                	cmp    $0x78,%al
  80115a:	75 0d                	jne    801169 <strtol+0x83>
		s += 2, base = 16;
  80115c:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  801160:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  801167:	eb 2a                	jmp    801193 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  801169:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80116d:	75 17                	jne    801186 <strtol+0xa0>
  80116f:	8b 45 08             	mov    0x8(%ebp),%eax
  801172:	0f b6 00             	movzbl (%eax),%eax
  801175:	3c 30                	cmp    $0x30,%al
  801177:	75 0d                	jne    801186 <strtol+0xa0>
		s++, base = 8;
  801179:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80117d:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801184:	eb 0d                	jmp    801193 <strtol+0xad>
	else if (base == 0)
  801186:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80118a:	75 07                	jne    801193 <strtol+0xad>
		base = 10;
  80118c:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801193:	8b 45 08             	mov    0x8(%ebp),%eax
  801196:	0f b6 00             	movzbl (%eax),%eax
  801199:	3c 2f                	cmp    $0x2f,%al
  80119b:	7e 1b                	jle    8011b8 <strtol+0xd2>
  80119d:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a0:	0f b6 00             	movzbl (%eax),%eax
  8011a3:	3c 39                	cmp    $0x39,%al
  8011a5:	7f 11                	jg     8011b8 <strtol+0xd2>
			dig = *s - '0';
  8011a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011aa:	0f b6 00             	movzbl (%eax),%eax
  8011ad:	0f be c0             	movsbl %al,%eax
  8011b0:	83 e8 30             	sub    $0x30,%eax
  8011b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8011b6:	eb 48                	jmp    801200 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  8011b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011bb:	0f b6 00             	movzbl (%eax),%eax
  8011be:	3c 60                	cmp    $0x60,%al
  8011c0:	7e 1b                	jle    8011dd <strtol+0xf7>
  8011c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c5:	0f b6 00             	movzbl (%eax),%eax
  8011c8:	3c 7a                	cmp    $0x7a,%al
  8011ca:	7f 11                	jg     8011dd <strtol+0xf7>
			dig = *s - 'a' + 10;
  8011cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8011cf:	0f b6 00             	movzbl (%eax),%eax
  8011d2:	0f be c0             	movsbl %al,%eax
  8011d5:	83 e8 57             	sub    $0x57,%eax
  8011d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8011db:	eb 23                	jmp    801200 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  8011dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e0:	0f b6 00             	movzbl (%eax),%eax
  8011e3:	3c 40                	cmp    $0x40,%al
  8011e5:	7e 3d                	jle    801224 <strtol+0x13e>
  8011e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ea:	0f b6 00             	movzbl (%eax),%eax
  8011ed:	3c 5a                	cmp    $0x5a,%al
  8011ef:	7f 33                	jg     801224 <strtol+0x13e>
			dig = *s - 'A' + 10;
  8011f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f4:	0f b6 00             	movzbl (%eax),%eax
  8011f7:	0f be c0             	movsbl %al,%eax
  8011fa:	83 e8 37             	sub    $0x37,%eax
  8011fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  801200:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801203:	3b 45 10             	cmp    0x10(%ebp),%eax
  801206:	7c 02                	jl     80120a <strtol+0x124>
			break;
  801208:	eb 1a                	jmp    801224 <strtol+0x13e>
		s++, val = (val * base) + dig;
  80120a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80120e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801211:	0f af 45 10          	imul   0x10(%ebp),%eax
  801215:	89 c2                	mov    %eax,%edx
  801217:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80121a:	01 d0                	add    %edx,%eax
  80121c:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  80121f:	e9 6f ff ff ff       	jmp    801193 <strtol+0xad>

	if (endptr)
  801224:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801228:	74 08                	je     801232 <strtol+0x14c>
		*endptr = (char *) s;
  80122a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80122d:	8b 55 08             	mov    0x8(%ebp),%edx
  801230:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801232:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  801236:	74 07                	je     80123f <strtol+0x159>
  801238:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80123b:	f7 d8                	neg    %eax
  80123d:	eb 03                	jmp    801242 <strtol+0x15c>
  80123f:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  801242:	c9                   	leave  
  801243:	c3                   	ret    

00801244 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  80124a:	a1 08 20 80 00       	mov    0x802008,%eax
  80124f:	85 c0                	test   %eax,%eax
  801251:	75 5d                	jne    8012b0 <set_pgfault_handler+0x6c>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(thisenv->env_id, (void *)UXSTACKTOP-PGSIZE, PTE_U | PTE_W | PTE_P)) < 0) panic("set_pgfault_handler unable to allocate page");
  801253:	a1 04 20 80 00       	mov    0x802004,%eax
  801258:	8b 40 48             	mov    0x48(%eax),%eax
  80125b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801262:	00 
  801263:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80126a:	ee 
  80126b:	89 04 24             	mov    %eax,(%esp)
  80126e:	e8 ec ef ff ff       	call   80025f <sys_page_alloc>
  801273:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801276:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80127a:	79 1c                	jns    801298 <set_pgfault_handler+0x54>
  80127c:	c7 44 24 08 04 18 80 	movl   $0x801804,0x8(%esp)
  801283:	00 
  801284:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80128b:	00 
  80128c:	c7 04 24 30 18 80 00 	movl   $0x801830,(%esp)
  801293:	e8 86 f2 ff ff       	call   80051e <_panic>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801298:	a1 04 20 80 00       	mov    0x802004,%eax
  80129d:	8b 40 48             	mov    0x48(%eax),%eax
  8012a0:	c7 44 24 04 fa 04 80 	movl   $0x8004fa,0x4(%esp)
  8012a7:	00 
  8012a8:	89 04 24             	mov    %eax,(%esp)
  8012ab:	e8 ba f0 ff ff       	call   80036a <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b3:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8012b8:	c9                   	leave  
  8012b9:	c3                   	ret    
  8012ba:	66 90                	xchg   %ax,%ax
  8012bc:	66 90                	xchg   %ax,%ax
  8012be:	66 90                	xchg   %ax,%ax

008012c0 <__udivdi3>:
  8012c0:	55                   	push   %ebp
  8012c1:	57                   	push   %edi
  8012c2:	56                   	push   %esi
  8012c3:	83 ec 0c             	sub    $0xc,%esp
  8012c6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8012ca:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8012ce:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8012d2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8012d6:	85 c0                	test   %eax,%eax
  8012d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8012dc:	89 ea                	mov    %ebp,%edx
  8012de:	89 0c 24             	mov    %ecx,(%esp)
  8012e1:	75 2d                	jne    801310 <__udivdi3+0x50>
  8012e3:	39 e9                	cmp    %ebp,%ecx
  8012e5:	77 61                	ja     801348 <__udivdi3+0x88>
  8012e7:	85 c9                	test   %ecx,%ecx
  8012e9:	89 ce                	mov    %ecx,%esi
  8012eb:	75 0b                	jne    8012f8 <__udivdi3+0x38>
  8012ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8012f2:	31 d2                	xor    %edx,%edx
  8012f4:	f7 f1                	div    %ecx
  8012f6:	89 c6                	mov    %eax,%esi
  8012f8:	31 d2                	xor    %edx,%edx
  8012fa:	89 e8                	mov    %ebp,%eax
  8012fc:	f7 f6                	div    %esi
  8012fe:	89 c5                	mov    %eax,%ebp
  801300:	89 f8                	mov    %edi,%eax
  801302:	f7 f6                	div    %esi
  801304:	89 ea                	mov    %ebp,%edx
  801306:	83 c4 0c             	add    $0xc,%esp
  801309:	5e                   	pop    %esi
  80130a:	5f                   	pop    %edi
  80130b:	5d                   	pop    %ebp
  80130c:	c3                   	ret    
  80130d:	8d 76 00             	lea    0x0(%esi),%esi
  801310:	39 e8                	cmp    %ebp,%eax
  801312:	77 24                	ja     801338 <__udivdi3+0x78>
  801314:	0f bd e8             	bsr    %eax,%ebp
  801317:	83 f5 1f             	xor    $0x1f,%ebp
  80131a:	75 3c                	jne    801358 <__udivdi3+0x98>
  80131c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801320:	39 34 24             	cmp    %esi,(%esp)
  801323:	0f 86 9f 00 00 00    	jbe    8013c8 <__udivdi3+0x108>
  801329:	39 d0                	cmp    %edx,%eax
  80132b:	0f 82 97 00 00 00    	jb     8013c8 <__udivdi3+0x108>
  801331:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801338:	31 d2                	xor    %edx,%edx
  80133a:	31 c0                	xor    %eax,%eax
  80133c:	83 c4 0c             	add    $0xc,%esp
  80133f:	5e                   	pop    %esi
  801340:	5f                   	pop    %edi
  801341:	5d                   	pop    %ebp
  801342:	c3                   	ret    
  801343:	90                   	nop
  801344:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801348:	89 f8                	mov    %edi,%eax
  80134a:	f7 f1                	div    %ecx
  80134c:	31 d2                	xor    %edx,%edx
  80134e:	83 c4 0c             	add    $0xc,%esp
  801351:	5e                   	pop    %esi
  801352:	5f                   	pop    %edi
  801353:	5d                   	pop    %ebp
  801354:	c3                   	ret    
  801355:	8d 76 00             	lea    0x0(%esi),%esi
  801358:	89 e9                	mov    %ebp,%ecx
  80135a:	8b 3c 24             	mov    (%esp),%edi
  80135d:	d3 e0                	shl    %cl,%eax
  80135f:	89 c6                	mov    %eax,%esi
  801361:	b8 20 00 00 00       	mov    $0x20,%eax
  801366:	29 e8                	sub    %ebp,%eax
  801368:	89 c1                	mov    %eax,%ecx
  80136a:	d3 ef                	shr    %cl,%edi
  80136c:	89 e9                	mov    %ebp,%ecx
  80136e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801372:	8b 3c 24             	mov    (%esp),%edi
  801375:	09 74 24 08          	or     %esi,0x8(%esp)
  801379:	89 d6                	mov    %edx,%esi
  80137b:	d3 e7                	shl    %cl,%edi
  80137d:	89 c1                	mov    %eax,%ecx
  80137f:	89 3c 24             	mov    %edi,(%esp)
  801382:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801386:	d3 ee                	shr    %cl,%esi
  801388:	89 e9                	mov    %ebp,%ecx
  80138a:	d3 e2                	shl    %cl,%edx
  80138c:	89 c1                	mov    %eax,%ecx
  80138e:	d3 ef                	shr    %cl,%edi
  801390:	09 d7                	or     %edx,%edi
  801392:	89 f2                	mov    %esi,%edx
  801394:	89 f8                	mov    %edi,%eax
  801396:	f7 74 24 08          	divl   0x8(%esp)
  80139a:	89 d6                	mov    %edx,%esi
  80139c:	89 c7                	mov    %eax,%edi
  80139e:	f7 24 24             	mull   (%esp)
  8013a1:	39 d6                	cmp    %edx,%esi
  8013a3:	89 14 24             	mov    %edx,(%esp)
  8013a6:	72 30                	jb     8013d8 <__udivdi3+0x118>
  8013a8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013ac:	89 e9                	mov    %ebp,%ecx
  8013ae:	d3 e2                	shl    %cl,%edx
  8013b0:	39 c2                	cmp    %eax,%edx
  8013b2:	73 05                	jae    8013b9 <__udivdi3+0xf9>
  8013b4:	3b 34 24             	cmp    (%esp),%esi
  8013b7:	74 1f                	je     8013d8 <__udivdi3+0x118>
  8013b9:	89 f8                	mov    %edi,%eax
  8013bb:	31 d2                	xor    %edx,%edx
  8013bd:	e9 7a ff ff ff       	jmp    80133c <__udivdi3+0x7c>
  8013c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013c8:	31 d2                	xor    %edx,%edx
  8013ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8013cf:	e9 68 ff ff ff       	jmp    80133c <__udivdi3+0x7c>
  8013d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013d8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8013db:	31 d2                	xor    %edx,%edx
  8013dd:	83 c4 0c             	add    $0xc,%esp
  8013e0:	5e                   	pop    %esi
  8013e1:	5f                   	pop    %edi
  8013e2:	5d                   	pop    %ebp
  8013e3:	c3                   	ret    
  8013e4:	66 90                	xchg   %ax,%ax
  8013e6:	66 90                	xchg   %ax,%ax
  8013e8:	66 90                	xchg   %ax,%ax
  8013ea:	66 90                	xchg   %ax,%ax
  8013ec:	66 90                	xchg   %ax,%ax
  8013ee:	66 90                	xchg   %ax,%ax

008013f0 <__umoddi3>:
  8013f0:	55                   	push   %ebp
  8013f1:	57                   	push   %edi
  8013f2:	56                   	push   %esi
  8013f3:	83 ec 14             	sub    $0x14,%esp
  8013f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8013fa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8013fe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801402:	89 c7                	mov    %eax,%edi
  801404:	89 44 24 04          	mov    %eax,0x4(%esp)
  801408:	8b 44 24 30          	mov    0x30(%esp),%eax
  80140c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801410:	89 34 24             	mov    %esi,(%esp)
  801413:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801417:	85 c0                	test   %eax,%eax
  801419:	89 c2                	mov    %eax,%edx
  80141b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80141f:	75 17                	jne    801438 <__umoddi3+0x48>
  801421:	39 fe                	cmp    %edi,%esi
  801423:	76 4b                	jbe    801470 <__umoddi3+0x80>
  801425:	89 c8                	mov    %ecx,%eax
  801427:	89 fa                	mov    %edi,%edx
  801429:	f7 f6                	div    %esi
  80142b:	89 d0                	mov    %edx,%eax
  80142d:	31 d2                	xor    %edx,%edx
  80142f:	83 c4 14             	add    $0x14,%esp
  801432:	5e                   	pop    %esi
  801433:	5f                   	pop    %edi
  801434:	5d                   	pop    %ebp
  801435:	c3                   	ret    
  801436:	66 90                	xchg   %ax,%ax
  801438:	39 f8                	cmp    %edi,%eax
  80143a:	77 54                	ja     801490 <__umoddi3+0xa0>
  80143c:	0f bd e8             	bsr    %eax,%ebp
  80143f:	83 f5 1f             	xor    $0x1f,%ebp
  801442:	75 5c                	jne    8014a0 <__umoddi3+0xb0>
  801444:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801448:	39 3c 24             	cmp    %edi,(%esp)
  80144b:	0f 87 e7 00 00 00    	ja     801538 <__umoddi3+0x148>
  801451:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801455:	29 f1                	sub    %esi,%ecx
  801457:	19 c7                	sbb    %eax,%edi
  801459:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80145d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801461:	8b 44 24 08          	mov    0x8(%esp),%eax
  801465:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801469:	83 c4 14             	add    $0x14,%esp
  80146c:	5e                   	pop    %esi
  80146d:	5f                   	pop    %edi
  80146e:	5d                   	pop    %ebp
  80146f:	c3                   	ret    
  801470:	85 f6                	test   %esi,%esi
  801472:	89 f5                	mov    %esi,%ebp
  801474:	75 0b                	jne    801481 <__umoddi3+0x91>
  801476:	b8 01 00 00 00       	mov    $0x1,%eax
  80147b:	31 d2                	xor    %edx,%edx
  80147d:	f7 f6                	div    %esi
  80147f:	89 c5                	mov    %eax,%ebp
  801481:	8b 44 24 04          	mov    0x4(%esp),%eax
  801485:	31 d2                	xor    %edx,%edx
  801487:	f7 f5                	div    %ebp
  801489:	89 c8                	mov    %ecx,%eax
  80148b:	f7 f5                	div    %ebp
  80148d:	eb 9c                	jmp    80142b <__umoddi3+0x3b>
  80148f:	90                   	nop
  801490:	89 c8                	mov    %ecx,%eax
  801492:	89 fa                	mov    %edi,%edx
  801494:	83 c4 14             	add    $0x14,%esp
  801497:	5e                   	pop    %esi
  801498:	5f                   	pop    %edi
  801499:	5d                   	pop    %ebp
  80149a:	c3                   	ret    
  80149b:	90                   	nop
  80149c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014a0:	8b 04 24             	mov    (%esp),%eax
  8014a3:	be 20 00 00 00       	mov    $0x20,%esi
  8014a8:	89 e9                	mov    %ebp,%ecx
  8014aa:	29 ee                	sub    %ebp,%esi
  8014ac:	d3 e2                	shl    %cl,%edx
  8014ae:	89 f1                	mov    %esi,%ecx
  8014b0:	d3 e8                	shr    %cl,%eax
  8014b2:	89 e9                	mov    %ebp,%ecx
  8014b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b8:	8b 04 24             	mov    (%esp),%eax
  8014bb:	09 54 24 04          	or     %edx,0x4(%esp)
  8014bf:	89 fa                	mov    %edi,%edx
  8014c1:	d3 e0                	shl    %cl,%eax
  8014c3:	89 f1                	mov    %esi,%ecx
  8014c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014c9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8014cd:	d3 ea                	shr    %cl,%edx
  8014cf:	89 e9                	mov    %ebp,%ecx
  8014d1:	d3 e7                	shl    %cl,%edi
  8014d3:	89 f1                	mov    %esi,%ecx
  8014d5:	d3 e8                	shr    %cl,%eax
  8014d7:	89 e9                	mov    %ebp,%ecx
  8014d9:	09 f8                	or     %edi,%eax
  8014db:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8014df:	f7 74 24 04          	divl   0x4(%esp)
  8014e3:	d3 e7                	shl    %cl,%edi
  8014e5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014e9:	89 d7                	mov    %edx,%edi
  8014eb:	f7 64 24 08          	mull   0x8(%esp)
  8014ef:	39 d7                	cmp    %edx,%edi
  8014f1:	89 c1                	mov    %eax,%ecx
  8014f3:	89 14 24             	mov    %edx,(%esp)
  8014f6:	72 2c                	jb     801524 <__umoddi3+0x134>
  8014f8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8014fc:	72 22                	jb     801520 <__umoddi3+0x130>
  8014fe:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801502:	29 c8                	sub    %ecx,%eax
  801504:	19 d7                	sbb    %edx,%edi
  801506:	89 e9                	mov    %ebp,%ecx
  801508:	89 fa                	mov    %edi,%edx
  80150a:	d3 e8                	shr    %cl,%eax
  80150c:	89 f1                	mov    %esi,%ecx
  80150e:	d3 e2                	shl    %cl,%edx
  801510:	89 e9                	mov    %ebp,%ecx
  801512:	d3 ef                	shr    %cl,%edi
  801514:	09 d0                	or     %edx,%eax
  801516:	89 fa                	mov    %edi,%edx
  801518:	83 c4 14             	add    $0x14,%esp
  80151b:	5e                   	pop    %esi
  80151c:	5f                   	pop    %edi
  80151d:	5d                   	pop    %ebp
  80151e:	c3                   	ret    
  80151f:	90                   	nop
  801520:	39 d7                	cmp    %edx,%edi
  801522:	75 da                	jne    8014fe <__umoddi3+0x10e>
  801524:	8b 14 24             	mov    (%esp),%edx
  801527:	89 c1                	mov    %eax,%ecx
  801529:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80152d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801531:	eb cb                	jmp    8014fe <__umoddi3+0x10e>
  801533:	90                   	nop
  801534:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801538:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80153c:	0f 82 0f ff ff ff    	jb     801451 <__umoddi3+0x61>
  801542:	e9 1a ff ff ff       	jmp    801461 <__umoddi3+0x71>
