
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
  800039:	c7 05 00 20 80 00 40 	movl   $0x801440,0x802000
  800040:	14 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800043:	e8 d3 01 00 00       	call   80021b <sys_yield>
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
  800050:	e8 82 01 00 00       	call   8001d7 <sys_getenvid>
  800055:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005a:	c1 e0 02             	shl    $0x2,%eax
  80005d:	89 c2                	mov    %eax,%edx
  80005f:	c1 e2 05             	shl    $0x5,%edx
  800062:	29 c2                	sub    %eax,%edx
  800064:	89 d0                	mov    %edx,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800074:	7e 0a                	jle    800080 <libmain+0x36>
		binaryname = argv[0];
  800076:	8b 45 0c             	mov    0xc(%ebp),%eax
  800079:	8b 00                	mov    (%eax),%eax
  80007b:	a3 00 20 80 00       	mov    %eax,0x802000

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
  8000e7:	c7 44 24 08 4f 14 80 	movl   $0x80144f,0x8(%esp)
  8000ee:	00 
  8000ef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000f6:	00 
  8000f7:	c7 04 24 6c 14 80 00 	movl   $0x80146c,(%esp)
  8000fe:	e8 6f 03 00 00       	call   800472 <_panic>

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

00800472 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800472:	55                   	push   %ebp
  800473:	89 e5                	mov    %esp,%ebp
  800475:	53                   	push   %ebx
  800476:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  800479:	8d 45 14             	lea    0x14(%ebp),%eax
  80047c:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80047f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800485:	e8 4d fd ff ff       	call   8001d7 <sys_getenvid>
  80048a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80048d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800491:	8b 55 08             	mov    0x8(%ebp),%edx
  800494:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800498:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80049c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a0:	c7 04 24 7c 14 80 00 	movl   $0x80147c,(%esp)
  8004a7:	e8 e1 00 00 00       	call   80058d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8004af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8004b6:	89 04 24             	mov    %eax,(%esp)
  8004b9:	e8 6b 00 00 00       	call   800529 <vcprintf>
	cprintf("\n");
  8004be:	c7 04 24 9f 14 80 00 	movl   $0x80149f,(%esp)
  8004c5:	e8 c3 00 00 00       	call   80058d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004ca:	cc                   	int3   
  8004cb:	eb fd                	jmp    8004ca <_panic+0x58>

008004cd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004cd:	55                   	push   %ebp
  8004ce:	89 e5                	mov    %esp,%ebp
  8004d0:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8004d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d6:	8b 00                	mov    (%eax),%eax
  8004d8:	8d 48 01             	lea    0x1(%eax),%ecx
  8004db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004de:	89 0a                	mov    %ecx,(%edx)
  8004e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8004e3:	89 d1                	mov    %edx,%ecx
  8004e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004e8:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8004ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ef:	8b 00                	mov    (%eax),%eax
  8004f1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004f6:	75 20                	jne    800518 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8004f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004fb:	8b 00                	mov    (%eax),%eax
  8004fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800500:	83 c2 08             	add    $0x8,%edx
  800503:	89 44 24 04          	mov    %eax,0x4(%esp)
  800507:	89 14 24             	mov    %edx,(%esp)
  80050a:	e8 ff fb ff ff       	call   80010e <sys_cputs>
		b->idx = 0;
  80050f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800512:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800518:	8b 45 0c             	mov    0xc(%ebp),%eax
  80051b:	8b 40 04             	mov    0x4(%eax),%eax
  80051e:	8d 50 01             	lea    0x1(%eax),%edx
  800521:	8b 45 0c             	mov    0xc(%ebp),%eax
  800524:	89 50 04             	mov    %edx,0x4(%eax)
}
  800527:	c9                   	leave  
  800528:	c3                   	ret    

00800529 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800529:	55                   	push   %ebp
  80052a:	89 e5                	mov    %esp,%ebp
  80052c:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800532:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800539:	00 00 00 
	b.cnt = 0;
  80053c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800543:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800546:	8b 45 0c             	mov    0xc(%ebp),%eax
  800549:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80054d:	8b 45 08             	mov    0x8(%ebp),%eax
  800550:	89 44 24 08          	mov    %eax,0x8(%esp)
  800554:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80055a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055e:	c7 04 24 cd 04 80 00 	movl   $0x8004cd,(%esp)
  800565:	e8 bd 01 00 00       	call   800727 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80056a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800570:	89 44 24 04          	mov    %eax,0x4(%esp)
  800574:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80057a:	83 c0 08             	add    $0x8,%eax
  80057d:	89 04 24             	mov    %eax,(%esp)
  800580:	e8 89 fb ff ff       	call   80010e <sys_cputs>

	return b.cnt;
  800585:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80058b:	c9                   	leave  
  80058c:	c3                   	ret    

0080058d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80058d:	55                   	push   %ebp
  80058e:	89 e5                	mov    %esp,%ebp
  800590:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800593:	8d 45 0c             	lea    0xc(%ebp),%eax
  800596:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800599:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80059c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a3:	89 04 24             	mov    %eax,(%esp)
  8005a6:	e8 7e ff ff ff       	call   800529 <vcprintf>
  8005ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8005ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8005b1:	c9                   	leave  
  8005b2:	c3                   	ret    

008005b3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005b3:	55                   	push   %ebp
  8005b4:	89 e5                	mov    %esp,%ebp
  8005b6:	53                   	push   %ebx
  8005b7:	83 ec 34             	sub    $0x34,%esp
  8005ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8005bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005c6:	8b 45 18             	mov    0x18(%ebp),%eax
  8005c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ce:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005d1:	77 72                	ja     800645 <printnum+0x92>
  8005d3:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005d6:	72 05                	jb     8005dd <printnum+0x2a>
  8005d8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8005db:	77 68                	ja     800645 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005dd:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8005e0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8005e3:	8b 45 18             	mov    0x18(%ebp),%eax
  8005e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8005eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005ef:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005f9:	89 04 24             	mov    %eax,(%esp)
  8005fc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800600:	e8 9b 0b 00 00       	call   8011a0 <__udivdi3>
  800605:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800608:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  80060c:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800610:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800613:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800617:	89 44 24 08          	mov    %eax,0x8(%esp)
  80061b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80061f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800622:	89 44 24 04          	mov    %eax,0x4(%esp)
  800626:	8b 45 08             	mov    0x8(%ebp),%eax
  800629:	89 04 24             	mov    %eax,(%esp)
  80062c:	e8 82 ff ff ff       	call   8005b3 <printnum>
  800631:	eb 1c                	jmp    80064f <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800633:	8b 45 0c             	mov    0xc(%ebp),%eax
  800636:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063a:	8b 45 20             	mov    0x20(%ebp),%eax
  80063d:	89 04 24             	mov    %eax,(%esp)
  800640:	8b 45 08             	mov    0x8(%ebp),%eax
  800643:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800645:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800649:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  80064d:	7f e4                	jg     800633 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80064f:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800652:	bb 00 00 00 00       	mov    $0x0,%ebx
  800657:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80065d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800661:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800665:	89 04 24             	mov    %eax,(%esp)
  800668:	89 54 24 04          	mov    %edx,0x4(%esp)
  80066c:	e8 5f 0c 00 00       	call   8012d0 <__umoddi3>
  800671:	05 88 15 80 00       	add    $0x801588,%eax
  800676:	0f b6 00             	movzbl (%eax),%eax
  800679:	0f be c0             	movsbl %al,%eax
  80067c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80067f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800683:	89 04 24             	mov    %eax,(%esp)
  800686:	8b 45 08             	mov    0x8(%ebp),%eax
  800689:	ff d0                	call   *%eax
}
  80068b:	83 c4 34             	add    $0x34,%esp
  80068e:	5b                   	pop    %ebx
  80068f:	5d                   	pop    %ebp
  800690:	c3                   	ret    

00800691 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800691:	55                   	push   %ebp
  800692:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800694:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800698:	7e 14                	jle    8006ae <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80069a:	8b 45 08             	mov    0x8(%ebp),%eax
  80069d:	8b 00                	mov    (%eax),%eax
  80069f:	8d 48 08             	lea    0x8(%eax),%ecx
  8006a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8006a5:	89 0a                	mov    %ecx,(%edx)
  8006a7:	8b 50 04             	mov    0x4(%eax),%edx
  8006aa:	8b 00                	mov    (%eax),%eax
  8006ac:	eb 30                	jmp    8006de <getuint+0x4d>
	else if (lflag)
  8006ae:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006b2:	74 16                	je     8006ca <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8006b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b7:	8b 00                	mov    (%eax),%eax
  8006b9:	8d 48 04             	lea    0x4(%eax),%ecx
  8006bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8006bf:	89 0a                	mov    %ecx,(%edx)
  8006c1:	8b 00                	mov    (%eax),%eax
  8006c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c8:	eb 14                	jmp    8006de <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8006ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cd:	8b 00                	mov    (%eax),%eax
  8006cf:	8d 48 04             	lea    0x4(%eax),%ecx
  8006d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d5:	89 0a                	mov    %ecx,(%edx)
  8006d7:	8b 00                	mov    (%eax),%eax
  8006d9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006de:	5d                   	pop    %ebp
  8006df:	c3                   	ret    

008006e0 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006e3:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8006e7:	7e 14                	jle    8006fd <getint+0x1d>
		return va_arg(*ap, long long);
  8006e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ec:	8b 00                	mov    (%eax),%eax
  8006ee:	8d 48 08             	lea    0x8(%eax),%ecx
  8006f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8006f4:	89 0a                	mov    %ecx,(%edx)
  8006f6:	8b 50 04             	mov    0x4(%eax),%edx
  8006f9:	8b 00                	mov    (%eax),%eax
  8006fb:	eb 28                	jmp    800725 <getint+0x45>
	else if (lflag)
  8006fd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800701:	74 12                	je     800715 <getint+0x35>
		return va_arg(*ap, long);
  800703:	8b 45 08             	mov    0x8(%ebp),%eax
  800706:	8b 00                	mov    (%eax),%eax
  800708:	8d 48 04             	lea    0x4(%eax),%ecx
  80070b:	8b 55 08             	mov    0x8(%ebp),%edx
  80070e:	89 0a                	mov    %ecx,(%edx)
  800710:	8b 00                	mov    (%eax),%eax
  800712:	99                   	cltd   
  800713:	eb 10                	jmp    800725 <getint+0x45>
	else
		return va_arg(*ap, int);
  800715:	8b 45 08             	mov    0x8(%ebp),%eax
  800718:	8b 00                	mov    (%eax),%eax
  80071a:	8d 48 04             	lea    0x4(%eax),%ecx
  80071d:	8b 55 08             	mov    0x8(%ebp),%edx
  800720:	89 0a                	mov    %ecx,(%edx)
  800722:	8b 00                	mov    (%eax),%eax
  800724:	99                   	cltd   
}
  800725:	5d                   	pop    %ebp
  800726:	c3                   	ret    

00800727 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	56                   	push   %esi
  80072b:	53                   	push   %ebx
  80072c:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80072f:	eb 18                	jmp    800749 <vprintfmt+0x22>
			if (ch == '\0')
  800731:	85 db                	test   %ebx,%ebx
  800733:	75 05                	jne    80073a <vprintfmt+0x13>
				return;
  800735:	e9 cc 03 00 00       	jmp    800b06 <vprintfmt+0x3df>
			putch(ch, putdat);
  80073a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800741:	89 1c 24             	mov    %ebx,(%esp)
  800744:	8b 45 08             	mov    0x8(%ebp),%eax
  800747:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800749:	8b 45 10             	mov    0x10(%ebp),%eax
  80074c:	8d 50 01             	lea    0x1(%eax),%edx
  80074f:	89 55 10             	mov    %edx,0x10(%ebp)
  800752:	0f b6 00             	movzbl (%eax),%eax
  800755:	0f b6 d8             	movzbl %al,%ebx
  800758:	83 fb 25             	cmp    $0x25,%ebx
  80075b:	75 d4                	jne    800731 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  80075d:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800761:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800768:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80076f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800776:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077d:	8b 45 10             	mov    0x10(%ebp),%eax
  800780:	8d 50 01             	lea    0x1(%eax),%edx
  800783:	89 55 10             	mov    %edx,0x10(%ebp)
  800786:	0f b6 00             	movzbl (%eax),%eax
  800789:	0f b6 d8             	movzbl %al,%ebx
  80078c:	8d 43 dd             	lea    -0x23(%ebx),%eax
  80078f:	83 f8 55             	cmp    $0x55,%eax
  800792:	0f 87 3d 03 00 00    	ja     800ad5 <vprintfmt+0x3ae>
  800798:	8b 04 85 ac 15 80 00 	mov    0x8015ac(,%eax,4),%eax
  80079f:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8007a1:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8007a5:	eb d6                	jmp    80077d <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8007a7:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8007ab:	eb d0                	jmp    80077d <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007ad:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8007b4:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007b7:	89 d0                	mov    %edx,%eax
  8007b9:	c1 e0 02             	shl    $0x2,%eax
  8007bc:	01 d0                	add    %edx,%eax
  8007be:	01 c0                	add    %eax,%eax
  8007c0:	01 d8                	add    %ebx,%eax
  8007c2:	83 e8 30             	sub    $0x30,%eax
  8007c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8007c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8007cb:	0f b6 00             	movzbl (%eax),%eax
  8007ce:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8007d1:	83 fb 2f             	cmp    $0x2f,%ebx
  8007d4:	7e 0b                	jle    8007e1 <vprintfmt+0xba>
  8007d6:	83 fb 39             	cmp    $0x39,%ebx
  8007d9:	7f 06                	jg     8007e1 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007db:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8007df:	eb d3                	jmp    8007b4 <vprintfmt+0x8d>
			goto process_precision;
  8007e1:	eb 33                	jmp    800816 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8007e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e6:	8d 50 04             	lea    0x4(%eax),%edx
  8007e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ec:	8b 00                	mov    (%eax),%eax
  8007ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8007f1:	eb 23                	jmp    800816 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8007f3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007f7:	79 0c                	jns    800805 <vprintfmt+0xde>
				width = 0;
  8007f9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800800:	e9 78 ff ff ff       	jmp    80077d <vprintfmt+0x56>
  800805:	e9 73 ff ff ff       	jmp    80077d <vprintfmt+0x56>

		case '#':
			altflag = 1;
  80080a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800811:	e9 67 ff ff ff       	jmp    80077d <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800816:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80081a:	79 12                	jns    80082e <vprintfmt+0x107>
				width = precision, precision = -1;
  80081c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80081f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800822:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800829:	e9 4f ff ff ff       	jmp    80077d <vprintfmt+0x56>
  80082e:	e9 4a ff ff ff       	jmp    80077d <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800833:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800837:	e9 41 ff ff ff       	jmp    80077d <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80083c:	8b 45 14             	mov    0x14(%ebp),%eax
  80083f:	8d 50 04             	lea    0x4(%eax),%edx
  800842:	89 55 14             	mov    %edx,0x14(%ebp)
  800845:	8b 00                	mov    (%eax),%eax
  800847:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80084e:	89 04 24             	mov    %eax,(%esp)
  800851:	8b 45 08             	mov    0x8(%ebp),%eax
  800854:	ff d0                	call   *%eax
			break;
  800856:	e9 a5 02 00 00       	jmp    800b00 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80085b:	8b 45 14             	mov    0x14(%ebp),%eax
  80085e:	8d 50 04             	lea    0x4(%eax),%edx
  800861:	89 55 14             	mov    %edx,0x14(%ebp)
  800864:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800866:	85 db                	test   %ebx,%ebx
  800868:	79 02                	jns    80086c <vprintfmt+0x145>
				err = -err;
  80086a:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80086c:	83 fb 09             	cmp    $0x9,%ebx
  80086f:	7f 0b                	jg     80087c <vprintfmt+0x155>
  800871:	8b 34 9d 60 15 80 00 	mov    0x801560(,%ebx,4),%esi
  800878:	85 f6                	test   %esi,%esi
  80087a:	75 23                	jne    80089f <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  80087c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800880:	c7 44 24 08 99 15 80 	movl   $0x801599,0x8(%esp)
  800887:	00 
  800888:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	89 04 24             	mov    %eax,(%esp)
  800895:	e8 73 02 00 00       	call   800b0d <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80089a:	e9 61 02 00 00       	jmp    800b00 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80089f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008a3:	c7 44 24 08 a2 15 80 	movl   $0x8015a2,0x8(%esp)
  8008aa:	00 
  8008ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b5:	89 04 24             	mov    %eax,(%esp)
  8008b8:	e8 50 02 00 00       	call   800b0d <printfmt>
			break;
  8008bd:	e9 3e 02 00 00       	jmp    800b00 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c5:	8d 50 04             	lea    0x4(%eax),%edx
  8008c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8008cb:	8b 30                	mov    (%eax),%esi
  8008cd:	85 f6                	test   %esi,%esi
  8008cf:	75 05                	jne    8008d6 <vprintfmt+0x1af>
				p = "(null)";
  8008d1:	be a5 15 80 00       	mov    $0x8015a5,%esi
			if (width > 0 && padc != '-')
  8008d6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008da:	7e 37                	jle    800913 <vprintfmt+0x1ec>
  8008dc:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8008e0:	74 31                	je     800913 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e9:	89 34 24             	mov    %esi,(%esp)
  8008ec:	e8 39 03 00 00       	call   800c2a <strnlen>
  8008f1:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8008f4:	eb 17                	jmp    80090d <vprintfmt+0x1e6>
					putch(padc, putdat);
  8008f6:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8008fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800901:	89 04 24             	mov    %eax,(%esp)
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800909:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80090d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800911:	7f e3                	jg     8008f6 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800913:	eb 38                	jmp    80094d <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800915:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800919:	74 1f                	je     80093a <vprintfmt+0x213>
  80091b:	83 fb 1f             	cmp    $0x1f,%ebx
  80091e:	7e 05                	jle    800925 <vprintfmt+0x1fe>
  800920:	83 fb 7e             	cmp    $0x7e,%ebx
  800923:	7e 15                	jle    80093a <vprintfmt+0x213>
					putch('?', putdat);
  800925:	8b 45 0c             	mov    0xc(%ebp),%eax
  800928:	89 44 24 04          	mov    %eax,0x4(%esp)
  80092c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
  800936:	ff d0                	call   *%eax
  800938:	eb 0f                	jmp    800949 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  80093a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800941:	89 1c 24             	mov    %ebx,(%esp)
  800944:	8b 45 08             	mov    0x8(%ebp),%eax
  800947:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800949:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80094d:	89 f0                	mov    %esi,%eax
  80094f:	8d 70 01             	lea    0x1(%eax),%esi
  800952:	0f b6 00             	movzbl (%eax),%eax
  800955:	0f be d8             	movsbl %al,%ebx
  800958:	85 db                	test   %ebx,%ebx
  80095a:	74 10                	je     80096c <vprintfmt+0x245>
  80095c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800960:	78 b3                	js     800915 <vprintfmt+0x1ee>
  800962:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800966:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80096a:	79 a9                	jns    800915 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80096c:	eb 17                	jmp    800985 <vprintfmt+0x25e>
				putch(' ', putdat);
  80096e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800971:	89 44 24 04          	mov    %eax,0x4(%esp)
  800975:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800981:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800985:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800989:	7f e3                	jg     80096e <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  80098b:	e9 70 01 00 00       	jmp    800b00 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800990:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800993:	89 44 24 04          	mov    %eax,0x4(%esp)
  800997:	8d 45 14             	lea    0x14(%ebp),%eax
  80099a:	89 04 24             	mov    %eax,(%esp)
  80099d:	e8 3e fd ff ff       	call   8006e0 <getint>
  8009a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8009a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009ae:	85 d2                	test   %edx,%edx
  8009b0:	79 26                	jns    8009d8 <vprintfmt+0x2b1>
				putch('-', putdat);
  8009b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b9:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	ff d0                	call   *%eax
				num = -(long long) num;
  8009c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009cb:	f7 d8                	neg    %eax
  8009cd:	83 d2 00             	adc    $0x0,%edx
  8009d0:	f7 da                	neg    %edx
  8009d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009d5:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8009d8:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009df:	e9 a8 00 00 00       	jmp    800a8c <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ee:	89 04 24             	mov    %eax,(%esp)
  8009f1:	e8 9b fc ff ff       	call   800691 <getuint>
  8009f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009f9:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8009fc:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a03:	e9 84 00 00 00       	jmp    800a8c <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a08:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0f:	8d 45 14             	lea    0x14(%ebp),%eax
  800a12:	89 04 24             	mov    %eax,(%esp)
  800a15:	e8 77 fc ff ff       	call   800691 <getuint>
  800a1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a1d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800a20:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800a27:	eb 63                	jmp    800a8c <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a30:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a37:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3a:	ff d0                	call   *%eax
			putch('x', putdat);
  800a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a43:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4d:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a4f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a52:	8d 50 04             	lea    0x4(%eax),%edx
  800a55:	89 55 14             	mov    %edx,0x14(%ebp)
  800a58:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a5d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a64:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a6b:	eb 1f                	jmp    800a8c <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a6d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a70:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a74:	8d 45 14             	lea    0x14(%ebp),%eax
  800a77:	89 04 24             	mov    %eax,(%esp)
  800a7a:	e8 12 fc ff ff       	call   800691 <getuint>
  800a7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a82:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800a85:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a8c:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800a90:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a93:	89 54 24 18          	mov    %edx,0x18(%esp)
  800a97:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a9a:	89 54 24 14          	mov    %edx,0x14(%esp)
  800a9e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800aa5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800aa8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ab0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aba:	89 04 24             	mov    %eax,(%esp)
  800abd:	e8 f1 fa ff ff       	call   8005b3 <printnum>
			break;
  800ac2:	eb 3c                	jmp    800b00 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ac4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800acb:	89 1c 24             	mov    %ebx,(%esp)
  800ace:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad1:	ff d0                	call   *%eax
			break;
  800ad3:	eb 2b                	jmp    800b00 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ad5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800adc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ae3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae6:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ae8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800aec:	eb 04                	jmp    800af2 <vprintfmt+0x3cb>
  800aee:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800af2:	8b 45 10             	mov    0x10(%ebp),%eax
  800af5:	83 e8 01             	sub    $0x1,%eax
  800af8:	0f b6 00             	movzbl (%eax),%eax
  800afb:	3c 25                	cmp    $0x25,%al
  800afd:	75 ef                	jne    800aee <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800aff:	90                   	nop
		}
	}
  800b00:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b01:	e9 43 fc ff ff       	jmp    800749 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800b06:	83 c4 40             	add    $0x40,%esp
  800b09:	5b                   	pop    %ebx
  800b0a:	5e                   	pop    %esi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b13:	8d 45 14             	lea    0x14(%ebp),%eax
  800b16:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b1c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b20:	8b 45 10             	mov    0x10(%ebp),%eax
  800b23:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b31:	89 04 24             	mov    %eax,(%esp)
  800b34:	e8 ee fb ff ff       	call   800727 <vprintfmt>
	va_end(ap);
}
  800b39:	c9                   	leave  
  800b3a:	c3                   	ret    

00800b3b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800b3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b41:	8b 40 08             	mov    0x8(%eax),%eax
  800b44:	8d 50 01             	lea    0x1(%eax),%edx
  800b47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4a:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b50:	8b 10                	mov    (%eax),%edx
  800b52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b55:	8b 40 04             	mov    0x4(%eax),%eax
  800b58:	39 c2                	cmp    %eax,%edx
  800b5a:	73 12                	jae    800b6e <sprintputch+0x33>
		*b->buf++ = ch;
  800b5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5f:	8b 00                	mov    (%eax),%eax
  800b61:	8d 48 01             	lea    0x1(%eax),%ecx
  800b64:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b67:	89 0a                	mov    %ecx,(%edx)
  800b69:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6c:	88 10                	mov    %dl,(%eax)
}
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    

00800b70 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b76:	8b 45 08             	mov    0x8(%ebp),%eax
  800b79:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7f:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b82:	8b 45 08             	mov    0x8(%ebp),%eax
  800b85:	01 d0                	add    %edx,%eax
  800b87:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b8a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b91:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b95:	74 06                	je     800b9d <vsnprintf+0x2d>
  800b97:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b9b:	7f 07                	jg     800ba4 <vsnprintf+0x34>
		return -E_INVAL;
  800b9d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ba2:	eb 2a                	jmp    800bce <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ba4:	8b 45 14             	mov    0x14(%ebp),%eax
  800ba7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bab:	8b 45 10             	mov    0x10(%ebp),%eax
  800bae:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bb2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bb5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bb9:	c7 04 24 3b 0b 80 00 	movl   $0x800b3b,(%esp)
  800bc0:	e8 62 fb ff ff       	call   800727 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bc8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bce:	c9                   	leave  
  800bcf:	c3                   	ret    

00800bd0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bd6:	8d 45 14             	lea    0x14(%ebp),%eax
  800bd9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800bdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bdf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800be3:	8b 45 10             	mov    0x10(%ebp),%eax
  800be6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bed:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bf1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf4:	89 04 24             	mov    %eax,(%esp)
  800bf7:	e8 74 ff ff ff       	call   800b70 <vsnprintf>
  800bfc:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800bff:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c02:	c9                   	leave  
  800c03:	c3                   	ret    

00800c04 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800c0a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c11:	eb 08                	jmp    800c1b <strlen+0x17>
		n++;
  800c13:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c17:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1e:	0f b6 00             	movzbl (%eax),%eax
  800c21:	84 c0                	test   %al,%al
  800c23:	75 ee                	jne    800c13 <strlen+0xf>
		n++;
	return n;
  800c25:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c28:	c9                   	leave  
  800c29:	c3                   	ret    

00800c2a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c30:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c37:	eb 0c                	jmp    800c45 <strnlen+0x1b>
		n++;
  800c39:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c3d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c41:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800c45:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c49:	74 0a                	je     800c55 <strnlen+0x2b>
  800c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4e:	0f b6 00             	movzbl (%eax),%eax
  800c51:	84 c0                	test   %al,%al
  800c53:	75 e4                	jne    800c39 <strnlen+0xf>
		n++;
	return n;
  800c55:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c58:	c9                   	leave  
  800c59:	c3                   	ret    

00800c5a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c60:	8b 45 08             	mov    0x8(%ebp),%eax
  800c63:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c66:	90                   	nop
  800c67:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6a:	8d 50 01             	lea    0x1(%eax),%edx
  800c6d:	89 55 08             	mov    %edx,0x8(%ebp)
  800c70:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c73:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c76:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800c79:	0f b6 12             	movzbl (%edx),%edx
  800c7c:	88 10                	mov    %dl,(%eax)
  800c7e:	0f b6 00             	movzbl (%eax),%eax
  800c81:	84 c0                	test   %al,%al
  800c83:	75 e2                	jne    800c67 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800c85:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c88:	c9                   	leave  
  800c89:	c3                   	ret    

00800c8a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800c90:	8b 45 08             	mov    0x8(%ebp),%eax
  800c93:	89 04 24             	mov    %eax,(%esp)
  800c96:	e8 69 ff ff ff       	call   800c04 <strlen>
  800c9b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800c9e:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800ca1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca4:	01 c2                	add    %eax,%edx
  800ca6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cad:	89 14 24             	mov    %edx,(%esp)
  800cb0:	e8 a5 ff ff ff       	call   800c5a <strcpy>
	return dst;
  800cb5:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cb8:	c9                   	leave  
  800cb9:	c3                   	ret    

00800cba <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800cc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc3:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800cc6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800ccd:	eb 23                	jmp    800cf2 <strncpy+0x38>
		*dst++ = *src;
  800ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd2:	8d 50 01             	lea    0x1(%eax),%edx
  800cd5:	89 55 08             	mov    %edx,0x8(%ebp)
  800cd8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cdb:	0f b6 12             	movzbl (%edx),%edx
  800cde:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800ce0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce3:	0f b6 00             	movzbl (%eax),%eax
  800ce6:	84 c0                	test   %al,%al
  800ce8:	74 04                	je     800cee <strncpy+0x34>
			src++;
  800cea:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cee:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800cf2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cf5:	3b 45 10             	cmp    0x10(%ebp),%eax
  800cf8:	72 d5                	jb     800ccf <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800cfa:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800cfd:	c9                   	leave  
  800cfe:	c3                   	ret    

00800cff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800d05:	8b 45 08             	mov    0x8(%ebp),%eax
  800d08:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800d0b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d0f:	74 33                	je     800d44 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d11:	eb 17                	jmp    800d2a <strlcpy+0x2b>
			*dst++ = *src++;
  800d13:	8b 45 08             	mov    0x8(%ebp),%eax
  800d16:	8d 50 01             	lea    0x1(%eax),%edx
  800d19:	89 55 08             	mov    %edx,0x8(%ebp)
  800d1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d1f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d22:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d25:	0f b6 12             	movzbl (%edx),%edx
  800d28:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d2a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d2e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d32:	74 0a                	je     800d3e <strlcpy+0x3f>
  800d34:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d37:	0f b6 00             	movzbl (%eax),%eax
  800d3a:	84 c0                	test   %al,%al
  800d3c:	75 d5                	jne    800d13 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800d3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d41:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d44:	8b 55 08             	mov    0x8(%ebp),%edx
  800d47:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d4a:	29 c2                	sub    %eax,%edx
  800d4c:	89 d0                	mov    %edx,%eax
}
  800d4e:	c9                   	leave  
  800d4f:	c3                   	ret    

00800d50 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d53:	eb 08                	jmp    800d5d <strcmp+0xd>
		p++, q++;
  800d55:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d59:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d60:	0f b6 00             	movzbl (%eax),%eax
  800d63:	84 c0                	test   %al,%al
  800d65:	74 10                	je     800d77 <strcmp+0x27>
  800d67:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6a:	0f b6 10             	movzbl (%eax),%edx
  800d6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d70:	0f b6 00             	movzbl (%eax),%eax
  800d73:	38 c2                	cmp    %al,%dl
  800d75:	74 de                	je     800d55 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d77:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7a:	0f b6 00             	movzbl (%eax),%eax
  800d7d:	0f b6 d0             	movzbl %al,%edx
  800d80:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d83:	0f b6 00             	movzbl (%eax),%eax
  800d86:	0f b6 c0             	movzbl %al,%eax
  800d89:	29 c2                	sub    %eax,%edx
  800d8b:	89 d0                	mov    %edx,%eax
}
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800d92:	eb 0c                	jmp    800da0 <strncmp+0x11>
		n--, p++, q++;
  800d94:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d98:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d9c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800da0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800da4:	74 1a                	je     800dc0 <strncmp+0x31>
  800da6:	8b 45 08             	mov    0x8(%ebp),%eax
  800da9:	0f b6 00             	movzbl (%eax),%eax
  800dac:	84 c0                	test   %al,%al
  800dae:	74 10                	je     800dc0 <strncmp+0x31>
  800db0:	8b 45 08             	mov    0x8(%ebp),%eax
  800db3:	0f b6 10             	movzbl (%eax),%edx
  800db6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db9:	0f b6 00             	movzbl (%eax),%eax
  800dbc:	38 c2                	cmp    %al,%dl
  800dbe:	74 d4                	je     800d94 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800dc0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dc4:	75 07                	jne    800dcd <strncmp+0x3e>
		return 0;
  800dc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800dcb:	eb 16                	jmp    800de3 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dcd:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd0:	0f b6 00             	movzbl (%eax),%eax
  800dd3:	0f b6 d0             	movzbl %al,%edx
  800dd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd9:	0f b6 00             	movzbl (%eax),%eax
  800ddc:	0f b6 c0             	movzbl %al,%eax
  800ddf:	29 c2                	sub    %eax,%edx
  800de1:	89 d0                	mov    %edx,%eax
}
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    

00800de5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	83 ec 04             	sub    $0x4,%esp
  800deb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dee:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800df1:	eb 14                	jmp    800e07 <strchr+0x22>
		if (*s == c)
  800df3:	8b 45 08             	mov    0x8(%ebp),%eax
  800df6:	0f b6 00             	movzbl (%eax),%eax
  800df9:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800dfc:	75 05                	jne    800e03 <strchr+0x1e>
			return (char *) s;
  800dfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800e01:	eb 13                	jmp    800e16 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e03:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e07:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0a:	0f b6 00             	movzbl (%eax),%eax
  800e0d:	84 c0                	test   %al,%al
  800e0f:	75 e2                	jne    800df3 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e11:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e16:	c9                   	leave  
  800e17:	c3                   	ret    

00800e18 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	83 ec 04             	sub    $0x4,%esp
  800e1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e21:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e24:	eb 11                	jmp    800e37 <strfind+0x1f>
		if (*s == c)
  800e26:	8b 45 08             	mov    0x8(%ebp),%eax
  800e29:	0f b6 00             	movzbl (%eax),%eax
  800e2c:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e2f:	75 02                	jne    800e33 <strfind+0x1b>
			break;
  800e31:	eb 0e                	jmp    800e41 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e33:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e37:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3a:	0f b6 00             	movzbl (%eax),%eax
  800e3d:	84 c0                	test   %al,%al
  800e3f:	75 e5                	jne    800e26 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800e41:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e44:	c9                   	leave  
  800e45:	c3                   	ret    

00800e46 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e4a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e4e:	75 05                	jne    800e55 <memset+0xf>
		return v;
  800e50:	8b 45 08             	mov    0x8(%ebp),%eax
  800e53:	eb 5c                	jmp    800eb1 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e55:	8b 45 08             	mov    0x8(%ebp),%eax
  800e58:	83 e0 03             	and    $0x3,%eax
  800e5b:	85 c0                	test   %eax,%eax
  800e5d:	75 41                	jne    800ea0 <memset+0x5a>
  800e5f:	8b 45 10             	mov    0x10(%ebp),%eax
  800e62:	83 e0 03             	and    $0x3,%eax
  800e65:	85 c0                	test   %eax,%eax
  800e67:	75 37                	jne    800ea0 <memset+0x5a>
		c &= 0xFF;
  800e69:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e70:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e73:	c1 e0 18             	shl    $0x18,%eax
  800e76:	89 c2                	mov    %eax,%edx
  800e78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7b:	c1 e0 10             	shl    $0x10,%eax
  800e7e:	09 c2                	or     %eax,%edx
  800e80:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e83:	c1 e0 08             	shl    $0x8,%eax
  800e86:	09 d0                	or     %edx,%eax
  800e88:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e8b:	8b 45 10             	mov    0x10(%ebp),%eax
  800e8e:	c1 e8 02             	shr    $0x2,%eax
  800e91:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e93:	8b 55 08             	mov    0x8(%ebp),%edx
  800e96:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e99:	89 d7                	mov    %edx,%edi
  800e9b:	fc                   	cld    
  800e9c:	f3 ab                	rep stos %eax,%es:(%edi)
  800e9e:	eb 0e                	jmp    800eae <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ea0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ea9:	89 d7                	mov    %edx,%edi
  800eab:	fc                   	cld    
  800eac:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800eae:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800eb1:	5f                   	pop    %edi
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    

00800eb4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	57                   	push   %edi
  800eb8:	56                   	push   %esi
  800eb9:	53                   	push   %ebx
  800eba:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800ebd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec0:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800ec3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec6:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800ec9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ecc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ecf:	73 6d                	jae    800f3e <memmove+0x8a>
  800ed1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ed4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ed7:	01 d0                	add    %edx,%eax
  800ed9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800edc:	76 60                	jbe    800f3e <memmove+0x8a>
		s += n;
  800ede:	8b 45 10             	mov    0x10(%ebp),%eax
  800ee1:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800ee4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ee7:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eed:	83 e0 03             	and    $0x3,%eax
  800ef0:	85 c0                	test   %eax,%eax
  800ef2:	75 2f                	jne    800f23 <memmove+0x6f>
  800ef4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ef7:	83 e0 03             	and    $0x3,%eax
  800efa:	85 c0                	test   %eax,%eax
  800efc:	75 25                	jne    800f23 <memmove+0x6f>
  800efe:	8b 45 10             	mov    0x10(%ebp),%eax
  800f01:	83 e0 03             	and    $0x3,%eax
  800f04:	85 c0                	test   %eax,%eax
  800f06:	75 1b                	jne    800f23 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f08:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f0b:	83 e8 04             	sub    $0x4,%eax
  800f0e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f11:	83 ea 04             	sub    $0x4,%edx
  800f14:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f17:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f1a:	89 c7                	mov    %eax,%edi
  800f1c:	89 d6                	mov    %edx,%esi
  800f1e:	fd                   	std    
  800f1f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f21:	eb 18                	jmp    800f3b <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f23:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f26:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f2c:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f2f:	8b 45 10             	mov    0x10(%ebp),%eax
  800f32:	89 d7                	mov    %edx,%edi
  800f34:	89 de                	mov    %ebx,%esi
  800f36:	89 c1                	mov    %eax,%ecx
  800f38:	fd                   	std    
  800f39:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f3b:	fc                   	cld    
  800f3c:	eb 45                	jmp    800f83 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f41:	83 e0 03             	and    $0x3,%eax
  800f44:	85 c0                	test   %eax,%eax
  800f46:	75 2b                	jne    800f73 <memmove+0xbf>
  800f48:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f4b:	83 e0 03             	and    $0x3,%eax
  800f4e:	85 c0                	test   %eax,%eax
  800f50:	75 21                	jne    800f73 <memmove+0xbf>
  800f52:	8b 45 10             	mov    0x10(%ebp),%eax
  800f55:	83 e0 03             	and    $0x3,%eax
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	75 17                	jne    800f73 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f5c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f5f:	c1 e8 02             	shr    $0x2,%eax
  800f62:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f64:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f67:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f6a:	89 c7                	mov    %eax,%edi
  800f6c:	89 d6                	mov    %edx,%esi
  800f6e:	fc                   	cld    
  800f6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f71:	eb 10                	jmp    800f83 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f73:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f76:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f79:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f7c:	89 c7                	mov    %eax,%edi
  800f7e:	89 d6                	mov    %edx,%esi
  800f80:	fc                   	cld    
  800f81:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800f83:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f86:	83 c4 10             	add    $0x10,%esp
  800f89:	5b                   	pop    %ebx
  800f8a:	5e                   	pop    %esi
  800f8b:	5f                   	pop    %edi
  800f8c:	5d                   	pop    %ebp
  800f8d:	c3                   	ret    

00800f8e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f8e:	55                   	push   %ebp
  800f8f:	89 e5                	mov    %esp,%ebp
  800f91:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f94:	8b 45 10             	mov    0x10(%ebp),%eax
  800f97:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fa2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa5:	89 04 24             	mov    %eax,(%esp)
  800fa8:	e8 07 ff ff ff       	call   800eb4 <memmove>
}
  800fad:	c9                   	leave  
  800fae:	c3                   	ret    

00800faf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800faf:	55                   	push   %ebp
  800fb0:	89 e5                	mov    %esp,%ebp
  800fb2:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800fb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb8:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800fbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fbe:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800fc1:	eb 30                	jmp    800ff3 <memcmp+0x44>
		if (*s1 != *s2)
  800fc3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fc6:	0f b6 10             	movzbl (%eax),%edx
  800fc9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fcc:	0f b6 00             	movzbl (%eax),%eax
  800fcf:	38 c2                	cmp    %al,%dl
  800fd1:	74 18                	je     800feb <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800fd3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fd6:	0f b6 00             	movzbl (%eax),%eax
  800fd9:	0f b6 d0             	movzbl %al,%edx
  800fdc:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fdf:	0f b6 00             	movzbl (%eax),%eax
  800fe2:	0f b6 c0             	movzbl %al,%eax
  800fe5:	29 c2                	sub    %eax,%edx
  800fe7:	89 d0                	mov    %edx,%eax
  800fe9:	eb 1a                	jmp    801005 <memcmp+0x56>
		s1++, s2++;
  800feb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800fef:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ff3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ff6:	8d 50 ff             	lea    -0x1(%eax),%edx
  800ff9:	89 55 10             	mov    %edx,0x10(%ebp)
  800ffc:	85 c0                	test   %eax,%eax
  800ffe:	75 c3                	jne    800fc3 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801000:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801005:	c9                   	leave  
  801006:	c3                   	ret    

00801007 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  80100d:	8b 45 10             	mov    0x10(%ebp),%eax
  801010:	8b 55 08             	mov    0x8(%ebp),%edx
  801013:	01 d0                	add    %edx,%eax
  801015:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801018:	eb 13                	jmp    80102d <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  80101a:	8b 45 08             	mov    0x8(%ebp),%eax
  80101d:	0f b6 10             	movzbl (%eax),%edx
  801020:	8b 45 0c             	mov    0xc(%ebp),%eax
  801023:	38 c2                	cmp    %al,%dl
  801025:	75 02                	jne    801029 <memfind+0x22>
			break;
  801027:	eb 0c                	jmp    801035 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801029:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80102d:	8b 45 08             	mov    0x8(%ebp),%eax
  801030:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  801033:	72 e5                	jb     80101a <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  801035:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801038:	c9                   	leave  
  801039:	c3                   	ret    

0080103a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  801040:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  801047:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80104e:	eb 04                	jmp    801054 <strtol+0x1a>
		s++;
  801050:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801054:	8b 45 08             	mov    0x8(%ebp),%eax
  801057:	0f b6 00             	movzbl (%eax),%eax
  80105a:	3c 20                	cmp    $0x20,%al
  80105c:	74 f2                	je     801050 <strtol+0x16>
  80105e:	8b 45 08             	mov    0x8(%ebp),%eax
  801061:	0f b6 00             	movzbl (%eax),%eax
  801064:	3c 09                	cmp    $0x9,%al
  801066:	74 e8                	je     801050 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  801068:	8b 45 08             	mov    0x8(%ebp),%eax
  80106b:	0f b6 00             	movzbl (%eax),%eax
  80106e:	3c 2b                	cmp    $0x2b,%al
  801070:	75 06                	jne    801078 <strtol+0x3e>
		s++;
  801072:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801076:	eb 15                	jmp    80108d <strtol+0x53>
	else if (*s == '-')
  801078:	8b 45 08             	mov    0x8(%ebp),%eax
  80107b:	0f b6 00             	movzbl (%eax),%eax
  80107e:	3c 2d                	cmp    $0x2d,%al
  801080:	75 0b                	jne    80108d <strtol+0x53>
		s++, neg = 1;
  801082:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801086:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80108d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801091:	74 06                	je     801099 <strtol+0x5f>
  801093:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  801097:	75 24                	jne    8010bd <strtol+0x83>
  801099:	8b 45 08             	mov    0x8(%ebp),%eax
  80109c:	0f b6 00             	movzbl (%eax),%eax
  80109f:	3c 30                	cmp    $0x30,%al
  8010a1:	75 1a                	jne    8010bd <strtol+0x83>
  8010a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a6:	83 c0 01             	add    $0x1,%eax
  8010a9:	0f b6 00             	movzbl (%eax),%eax
  8010ac:	3c 78                	cmp    $0x78,%al
  8010ae:	75 0d                	jne    8010bd <strtol+0x83>
		s += 2, base = 16;
  8010b0:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8010b4:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8010bb:	eb 2a                	jmp    8010e7 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  8010bd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010c1:	75 17                	jne    8010da <strtol+0xa0>
  8010c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c6:	0f b6 00             	movzbl (%eax),%eax
  8010c9:	3c 30                	cmp    $0x30,%al
  8010cb:	75 0d                	jne    8010da <strtol+0xa0>
		s++, base = 8;
  8010cd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010d1:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8010d8:	eb 0d                	jmp    8010e7 <strtol+0xad>
	else if (base == 0)
  8010da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010de:	75 07                	jne    8010e7 <strtol+0xad>
		base = 10;
  8010e0:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ea:	0f b6 00             	movzbl (%eax),%eax
  8010ed:	3c 2f                	cmp    $0x2f,%al
  8010ef:	7e 1b                	jle    80110c <strtol+0xd2>
  8010f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f4:	0f b6 00             	movzbl (%eax),%eax
  8010f7:	3c 39                	cmp    $0x39,%al
  8010f9:	7f 11                	jg     80110c <strtol+0xd2>
			dig = *s - '0';
  8010fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fe:	0f b6 00             	movzbl (%eax),%eax
  801101:	0f be c0             	movsbl %al,%eax
  801104:	83 e8 30             	sub    $0x30,%eax
  801107:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80110a:	eb 48                	jmp    801154 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  80110c:	8b 45 08             	mov    0x8(%ebp),%eax
  80110f:	0f b6 00             	movzbl (%eax),%eax
  801112:	3c 60                	cmp    $0x60,%al
  801114:	7e 1b                	jle    801131 <strtol+0xf7>
  801116:	8b 45 08             	mov    0x8(%ebp),%eax
  801119:	0f b6 00             	movzbl (%eax),%eax
  80111c:	3c 7a                	cmp    $0x7a,%al
  80111e:	7f 11                	jg     801131 <strtol+0xf7>
			dig = *s - 'a' + 10;
  801120:	8b 45 08             	mov    0x8(%ebp),%eax
  801123:	0f b6 00             	movzbl (%eax),%eax
  801126:	0f be c0             	movsbl %al,%eax
  801129:	83 e8 57             	sub    $0x57,%eax
  80112c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80112f:	eb 23                	jmp    801154 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  801131:	8b 45 08             	mov    0x8(%ebp),%eax
  801134:	0f b6 00             	movzbl (%eax),%eax
  801137:	3c 40                	cmp    $0x40,%al
  801139:	7e 3d                	jle    801178 <strtol+0x13e>
  80113b:	8b 45 08             	mov    0x8(%ebp),%eax
  80113e:	0f b6 00             	movzbl (%eax),%eax
  801141:	3c 5a                	cmp    $0x5a,%al
  801143:	7f 33                	jg     801178 <strtol+0x13e>
			dig = *s - 'A' + 10;
  801145:	8b 45 08             	mov    0x8(%ebp),%eax
  801148:	0f b6 00             	movzbl (%eax),%eax
  80114b:	0f be c0             	movsbl %al,%eax
  80114e:	83 e8 37             	sub    $0x37,%eax
  801151:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  801154:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801157:	3b 45 10             	cmp    0x10(%ebp),%eax
  80115a:	7c 02                	jl     80115e <strtol+0x124>
			break;
  80115c:	eb 1a                	jmp    801178 <strtol+0x13e>
		s++, val = (val * base) + dig;
  80115e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801162:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801165:	0f af 45 10          	imul   0x10(%ebp),%eax
  801169:	89 c2                	mov    %eax,%edx
  80116b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80116e:	01 d0                	add    %edx,%eax
  801170:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  801173:	e9 6f ff ff ff       	jmp    8010e7 <strtol+0xad>

	if (endptr)
  801178:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80117c:	74 08                	je     801186 <strtol+0x14c>
		*endptr = (char *) s;
  80117e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801181:	8b 55 08             	mov    0x8(%ebp),%edx
  801184:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801186:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  80118a:	74 07                	je     801193 <strtol+0x159>
  80118c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80118f:	f7 d8                	neg    %eax
  801191:	eb 03                	jmp    801196 <strtol+0x15c>
  801193:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  801196:	c9                   	leave  
  801197:	c3                   	ret    
  801198:	66 90                	xchg   %ax,%ax
  80119a:	66 90                	xchg   %ax,%ax
  80119c:	66 90                	xchg   %ax,%ax
  80119e:	66 90                	xchg   %ax,%ax

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
