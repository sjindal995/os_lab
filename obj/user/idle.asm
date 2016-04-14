
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
  800039:	c7 05 00 20 80 00 00 	movl   $0x801400,0x802000
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
  8000e7:	c7 44 24 08 0f 14 80 	movl   $0x80140f,0x8(%esp)
  8000ee:	00 
  8000ef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000f6:	00 
  8000f7:	c7 04 24 2c 14 80 00 	movl   $0x80142c,(%esp)
  8000fe:	e8 2c 03 00 00       	call   80042f <_panic>

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

0080042f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80042f:	55                   	push   %ebp
  800430:	89 e5                	mov    %esp,%ebp
  800432:	53                   	push   %ebx
  800433:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  800436:	8d 45 14             	lea    0x14(%ebp),%eax
  800439:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80043c:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800442:	e8 90 fd ff ff       	call   8001d7 <sys_getenvid>
  800447:	8b 55 0c             	mov    0xc(%ebp),%edx
  80044a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80044e:	8b 55 08             	mov    0x8(%ebp),%edx
  800451:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800455:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800459:	89 44 24 04          	mov    %eax,0x4(%esp)
  80045d:	c7 04 24 3c 14 80 00 	movl   $0x80143c,(%esp)
  800464:	e8 e1 00 00 00       	call   80054a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800469:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80046c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800470:	8b 45 10             	mov    0x10(%ebp),%eax
  800473:	89 04 24             	mov    %eax,(%esp)
  800476:	e8 6b 00 00 00       	call   8004e6 <vcprintf>
	cprintf("\n");
  80047b:	c7 04 24 5f 14 80 00 	movl   $0x80145f,(%esp)
  800482:	e8 c3 00 00 00       	call   80054a <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800487:	cc                   	int3   
  800488:	eb fd                	jmp    800487 <_panic+0x58>

0080048a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80048a:	55                   	push   %ebp
  80048b:	89 e5                	mov    %esp,%ebp
  80048d:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800490:	8b 45 0c             	mov    0xc(%ebp),%eax
  800493:	8b 00                	mov    (%eax),%eax
  800495:	8d 48 01             	lea    0x1(%eax),%ecx
  800498:	8b 55 0c             	mov    0xc(%ebp),%edx
  80049b:	89 0a                	mov    %ecx,(%edx)
  80049d:	8b 55 08             	mov    0x8(%ebp),%edx
  8004a0:	89 d1                	mov    %edx,%ecx
  8004a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004a5:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8004a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ac:	8b 00                	mov    (%eax),%eax
  8004ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004b3:	75 20                	jne    8004d5 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8004b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b8:	8b 00                	mov    (%eax),%eax
  8004ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004bd:	83 c2 08             	add    $0x8,%edx
  8004c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c4:	89 14 24             	mov    %edx,(%esp)
  8004c7:	e8 42 fc ff ff       	call   80010e <sys_cputs>
		b->idx = 0;
  8004cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004cf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8004d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d8:	8b 40 04             	mov    0x4(%eax),%eax
  8004db:	8d 50 01             	lea    0x1(%eax),%edx
  8004de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e1:	89 50 04             	mov    %edx,0x4(%eax)
}
  8004e4:	c9                   	leave  
  8004e5:	c3                   	ret    

008004e6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004e6:	55                   	push   %ebp
  8004e7:	89 e5                	mov    %esp,%ebp
  8004e9:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004ef:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004f6:	00 00 00 
	b.cnt = 0;
  8004f9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800500:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800503:	8b 45 0c             	mov    0xc(%ebp),%eax
  800506:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80050a:	8b 45 08             	mov    0x8(%ebp),%eax
  80050d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800511:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800517:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051b:	c7 04 24 8a 04 80 00 	movl   $0x80048a,(%esp)
  800522:	e8 bd 01 00 00       	call   8006e4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800527:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80052d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800531:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800537:	83 c0 08             	add    $0x8,%eax
  80053a:	89 04 24             	mov    %eax,(%esp)
  80053d:	e8 cc fb ff ff       	call   80010e <sys_cputs>

	return b.cnt;
  800542:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800548:	c9                   	leave  
  800549:	c3                   	ret    

0080054a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80054a:	55                   	push   %ebp
  80054b:	89 e5                	mov    %esp,%ebp
  80054d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800550:	8d 45 0c             	lea    0xc(%ebp),%eax
  800553:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800556:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800559:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055d:	8b 45 08             	mov    0x8(%ebp),%eax
  800560:	89 04 24             	mov    %eax,(%esp)
  800563:	e8 7e ff ff ff       	call   8004e6 <vcprintf>
  800568:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  80056b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80056e:	c9                   	leave  
  80056f:	c3                   	ret    

00800570 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800570:	55                   	push   %ebp
  800571:	89 e5                	mov    %esp,%ebp
  800573:	53                   	push   %ebx
  800574:	83 ec 34             	sub    $0x34,%esp
  800577:	8b 45 10             	mov    0x10(%ebp),%eax
  80057a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800583:	8b 45 18             	mov    0x18(%ebp),%eax
  800586:	ba 00 00 00 00       	mov    $0x0,%edx
  80058b:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80058e:	77 72                	ja     800602 <printnum+0x92>
  800590:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800593:	72 05                	jb     80059a <printnum+0x2a>
  800595:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800598:	77 68                	ja     800602 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80059a:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80059d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8005a0:	8b 45 18             	mov    0x18(%ebp),%eax
  8005a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005b6:	89 04 24             	mov    %eax,(%esp)
  8005b9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005bd:	e8 9e 0b 00 00       	call   801160 <__udivdi3>
  8005c2:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8005c5:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8005c9:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8005cd:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8005d0:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8005d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005d8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e6:	89 04 24             	mov    %eax,(%esp)
  8005e9:	e8 82 ff ff ff       	call   800570 <printnum>
  8005ee:	eb 1c                	jmp    80060c <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f7:	8b 45 20             	mov    0x20(%ebp),%eax
  8005fa:	89 04 24             	mov    %eax,(%esp)
  8005fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800600:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800602:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800606:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  80060a:	7f e4                	jg     8005f0 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80060c:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80060f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800614:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800617:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80061a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80061e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800622:	89 04 24             	mov    %eax,(%esp)
  800625:	89 54 24 04          	mov    %edx,0x4(%esp)
  800629:	e8 62 0c 00 00       	call   801290 <__umoddi3>
  80062e:	05 48 15 80 00       	add    $0x801548,%eax
  800633:	0f b6 00             	movzbl (%eax),%eax
  800636:	0f be c0             	movsbl %al,%eax
  800639:	8b 55 0c             	mov    0xc(%ebp),%edx
  80063c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800640:	89 04 24             	mov    %eax,(%esp)
  800643:	8b 45 08             	mov    0x8(%ebp),%eax
  800646:	ff d0                	call   *%eax
}
  800648:	83 c4 34             	add    $0x34,%esp
  80064b:	5b                   	pop    %ebx
  80064c:	5d                   	pop    %ebp
  80064d:	c3                   	ret    

0080064e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80064e:	55                   	push   %ebp
  80064f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800651:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800655:	7e 14                	jle    80066b <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800657:	8b 45 08             	mov    0x8(%ebp),%eax
  80065a:	8b 00                	mov    (%eax),%eax
  80065c:	8d 48 08             	lea    0x8(%eax),%ecx
  80065f:	8b 55 08             	mov    0x8(%ebp),%edx
  800662:	89 0a                	mov    %ecx,(%edx)
  800664:	8b 50 04             	mov    0x4(%eax),%edx
  800667:	8b 00                	mov    (%eax),%eax
  800669:	eb 30                	jmp    80069b <getuint+0x4d>
	else if (lflag)
  80066b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80066f:	74 16                	je     800687 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800671:	8b 45 08             	mov    0x8(%ebp),%eax
  800674:	8b 00                	mov    (%eax),%eax
  800676:	8d 48 04             	lea    0x4(%eax),%ecx
  800679:	8b 55 08             	mov    0x8(%ebp),%edx
  80067c:	89 0a                	mov    %ecx,(%edx)
  80067e:	8b 00                	mov    (%eax),%eax
  800680:	ba 00 00 00 00       	mov    $0x0,%edx
  800685:	eb 14                	jmp    80069b <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800687:	8b 45 08             	mov    0x8(%ebp),%eax
  80068a:	8b 00                	mov    (%eax),%eax
  80068c:	8d 48 04             	lea    0x4(%eax),%ecx
  80068f:	8b 55 08             	mov    0x8(%ebp),%edx
  800692:	89 0a                	mov    %ecx,(%edx)
  800694:	8b 00                	mov    (%eax),%eax
  800696:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80069b:	5d                   	pop    %ebp
  80069c:	c3                   	ret    

0080069d <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80069d:	55                   	push   %ebp
  80069e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006a0:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8006a4:	7e 14                	jle    8006ba <getint+0x1d>
		return va_arg(*ap, long long);
  8006a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a9:	8b 00                	mov    (%eax),%eax
  8006ab:	8d 48 08             	lea    0x8(%eax),%ecx
  8006ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8006b1:	89 0a                	mov    %ecx,(%edx)
  8006b3:	8b 50 04             	mov    0x4(%eax),%edx
  8006b6:	8b 00                	mov    (%eax),%eax
  8006b8:	eb 28                	jmp    8006e2 <getint+0x45>
	else if (lflag)
  8006ba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006be:	74 12                	je     8006d2 <getint+0x35>
		return va_arg(*ap, long);
  8006c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c3:	8b 00                	mov    (%eax),%eax
  8006c5:	8d 48 04             	lea    0x4(%eax),%ecx
  8006c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8006cb:	89 0a                	mov    %ecx,(%edx)
  8006cd:	8b 00                	mov    (%eax),%eax
  8006cf:	99                   	cltd   
  8006d0:	eb 10                	jmp    8006e2 <getint+0x45>
	else
		return va_arg(*ap, int);
  8006d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d5:	8b 00                	mov    (%eax),%eax
  8006d7:	8d 48 04             	lea    0x4(%eax),%ecx
  8006da:	8b 55 08             	mov    0x8(%ebp),%edx
  8006dd:	89 0a                	mov    %ecx,(%edx)
  8006df:	8b 00                	mov    (%eax),%eax
  8006e1:	99                   	cltd   
}
  8006e2:	5d                   	pop    %ebp
  8006e3:	c3                   	ret    

008006e4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	56                   	push   %esi
  8006e8:	53                   	push   %ebx
  8006e9:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006ec:	eb 18                	jmp    800706 <vprintfmt+0x22>
			if (ch == '\0')
  8006ee:	85 db                	test   %ebx,%ebx
  8006f0:	75 05                	jne    8006f7 <vprintfmt+0x13>
				return;
  8006f2:	e9 cc 03 00 00       	jmp    800ac3 <vprintfmt+0x3df>
			putch(ch, putdat);
  8006f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fe:	89 1c 24             	mov    %ebx,(%esp)
  800701:	8b 45 08             	mov    0x8(%ebp),%eax
  800704:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800706:	8b 45 10             	mov    0x10(%ebp),%eax
  800709:	8d 50 01             	lea    0x1(%eax),%edx
  80070c:	89 55 10             	mov    %edx,0x10(%ebp)
  80070f:	0f b6 00             	movzbl (%eax),%eax
  800712:	0f b6 d8             	movzbl %al,%ebx
  800715:	83 fb 25             	cmp    $0x25,%ebx
  800718:	75 d4                	jne    8006ee <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  80071a:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80071e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800725:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80072c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800733:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073a:	8b 45 10             	mov    0x10(%ebp),%eax
  80073d:	8d 50 01             	lea    0x1(%eax),%edx
  800740:	89 55 10             	mov    %edx,0x10(%ebp)
  800743:	0f b6 00             	movzbl (%eax),%eax
  800746:	0f b6 d8             	movzbl %al,%ebx
  800749:	8d 43 dd             	lea    -0x23(%ebx),%eax
  80074c:	83 f8 55             	cmp    $0x55,%eax
  80074f:	0f 87 3d 03 00 00    	ja     800a92 <vprintfmt+0x3ae>
  800755:	8b 04 85 6c 15 80 00 	mov    0x80156c(,%eax,4),%eax
  80075c:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  80075e:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800762:	eb d6                	jmp    80073a <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800764:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800768:	eb d0                	jmp    80073a <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80076a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800771:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800774:	89 d0                	mov    %edx,%eax
  800776:	c1 e0 02             	shl    $0x2,%eax
  800779:	01 d0                	add    %edx,%eax
  80077b:	01 c0                	add    %eax,%eax
  80077d:	01 d8                	add    %ebx,%eax
  80077f:	83 e8 30             	sub    $0x30,%eax
  800782:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800785:	8b 45 10             	mov    0x10(%ebp),%eax
  800788:	0f b6 00             	movzbl (%eax),%eax
  80078b:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  80078e:	83 fb 2f             	cmp    $0x2f,%ebx
  800791:	7e 0b                	jle    80079e <vprintfmt+0xba>
  800793:	83 fb 39             	cmp    $0x39,%ebx
  800796:	7f 06                	jg     80079e <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800798:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80079c:	eb d3                	jmp    800771 <vprintfmt+0x8d>
			goto process_precision;
  80079e:	eb 33                	jmp    8007d3 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8007a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a3:	8d 50 04             	lea    0x4(%eax),%edx
  8007a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a9:	8b 00                	mov    (%eax),%eax
  8007ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8007ae:	eb 23                	jmp    8007d3 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8007b0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007b4:	79 0c                	jns    8007c2 <vprintfmt+0xde>
				width = 0;
  8007b6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8007bd:	e9 78 ff ff ff       	jmp    80073a <vprintfmt+0x56>
  8007c2:	e9 73 ff ff ff       	jmp    80073a <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8007c7:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8007ce:	e9 67 ff ff ff       	jmp    80073a <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  8007d3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007d7:	79 12                	jns    8007eb <vprintfmt+0x107>
				width = precision, precision = -1;
  8007d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007df:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8007e6:	e9 4f ff ff ff       	jmp    80073a <vprintfmt+0x56>
  8007eb:	e9 4a ff ff ff       	jmp    80073a <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007f0:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8007f4:	e9 41 ff ff ff       	jmp    80073a <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fc:	8d 50 04             	lea    0x4(%eax),%edx
  8007ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800802:	8b 00                	mov    (%eax),%eax
  800804:	8b 55 0c             	mov    0xc(%ebp),%edx
  800807:	89 54 24 04          	mov    %edx,0x4(%esp)
  80080b:	89 04 24             	mov    %eax,(%esp)
  80080e:	8b 45 08             	mov    0x8(%ebp),%eax
  800811:	ff d0                	call   *%eax
			break;
  800813:	e9 a5 02 00 00       	jmp    800abd <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800818:	8b 45 14             	mov    0x14(%ebp),%eax
  80081b:	8d 50 04             	lea    0x4(%eax),%edx
  80081e:	89 55 14             	mov    %edx,0x14(%ebp)
  800821:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800823:	85 db                	test   %ebx,%ebx
  800825:	79 02                	jns    800829 <vprintfmt+0x145>
				err = -err;
  800827:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800829:	83 fb 09             	cmp    $0x9,%ebx
  80082c:	7f 0b                	jg     800839 <vprintfmt+0x155>
  80082e:	8b 34 9d 20 15 80 00 	mov    0x801520(,%ebx,4),%esi
  800835:	85 f6                	test   %esi,%esi
  800837:	75 23                	jne    80085c <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800839:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80083d:	c7 44 24 08 59 15 80 	movl   $0x801559,0x8(%esp)
  800844:	00 
  800845:	8b 45 0c             	mov    0xc(%ebp),%eax
  800848:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084c:	8b 45 08             	mov    0x8(%ebp),%eax
  80084f:	89 04 24             	mov    %eax,(%esp)
  800852:	e8 73 02 00 00       	call   800aca <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800857:	e9 61 02 00 00       	jmp    800abd <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80085c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800860:	c7 44 24 08 62 15 80 	movl   $0x801562,0x8(%esp)
  800867:	00 
  800868:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80086f:	8b 45 08             	mov    0x8(%ebp),%eax
  800872:	89 04 24             	mov    %eax,(%esp)
  800875:	e8 50 02 00 00       	call   800aca <printfmt>
			break;
  80087a:	e9 3e 02 00 00       	jmp    800abd <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80087f:	8b 45 14             	mov    0x14(%ebp),%eax
  800882:	8d 50 04             	lea    0x4(%eax),%edx
  800885:	89 55 14             	mov    %edx,0x14(%ebp)
  800888:	8b 30                	mov    (%eax),%esi
  80088a:	85 f6                	test   %esi,%esi
  80088c:	75 05                	jne    800893 <vprintfmt+0x1af>
				p = "(null)";
  80088e:	be 65 15 80 00       	mov    $0x801565,%esi
			if (width > 0 && padc != '-')
  800893:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800897:	7e 37                	jle    8008d0 <vprintfmt+0x1ec>
  800899:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  80089d:	74 31                	je     8008d0 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  80089f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a6:	89 34 24             	mov    %esi,(%esp)
  8008a9:	e8 39 03 00 00       	call   800be7 <strnlen>
  8008ae:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8008b1:	eb 17                	jmp    8008ca <vprintfmt+0x1e6>
					putch(padc, putdat);
  8008b3:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8008b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ba:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008be:	89 04 24             	mov    %eax,(%esp)
  8008c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c4:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008c6:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008ca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008ce:	7f e3                	jg     8008b3 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008d0:	eb 38                	jmp    80090a <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8008d2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008d6:	74 1f                	je     8008f7 <vprintfmt+0x213>
  8008d8:	83 fb 1f             	cmp    $0x1f,%ebx
  8008db:	7e 05                	jle    8008e2 <vprintfmt+0x1fe>
  8008dd:	83 fb 7e             	cmp    $0x7e,%ebx
  8008e0:	7e 15                	jle    8008f7 <vprintfmt+0x213>
					putch('?', putdat);
  8008e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e9:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f3:	ff d0                	call   *%eax
  8008f5:	eb 0f                	jmp    800906 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8008f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008fe:	89 1c 24             	mov    %ebx,(%esp)
  800901:	8b 45 08             	mov    0x8(%ebp),%eax
  800904:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800906:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80090a:	89 f0                	mov    %esi,%eax
  80090c:	8d 70 01             	lea    0x1(%eax),%esi
  80090f:	0f b6 00             	movzbl (%eax),%eax
  800912:	0f be d8             	movsbl %al,%ebx
  800915:	85 db                	test   %ebx,%ebx
  800917:	74 10                	je     800929 <vprintfmt+0x245>
  800919:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80091d:	78 b3                	js     8008d2 <vprintfmt+0x1ee>
  80091f:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800923:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800927:	79 a9                	jns    8008d2 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800929:	eb 17                	jmp    800942 <vprintfmt+0x25e>
				putch(' ', putdat);
  80092b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800932:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80093e:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800942:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800946:	7f e3                	jg     80092b <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800948:	e9 70 01 00 00       	jmp    800abd <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80094d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800950:	89 44 24 04          	mov    %eax,0x4(%esp)
  800954:	8d 45 14             	lea    0x14(%ebp),%eax
  800957:	89 04 24             	mov    %eax,(%esp)
  80095a:	e8 3e fd ff ff       	call   80069d <getint>
  80095f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800962:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800965:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800968:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80096b:	85 d2                	test   %edx,%edx
  80096d:	79 26                	jns    800995 <vprintfmt+0x2b1>
				putch('-', putdat);
  80096f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800972:	89 44 24 04          	mov    %eax,0x4(%esp)
  800976:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	ff d0                	call   *%eax
				num = -(long long) num;
  800982:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800985:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800988:	f7 d8                	neg    %eax
  80098a:	83 d2 00             	adc    $0x0,%edx
  80098d:	f7 da                	neg    %edx
  80098f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800992:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800995:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80099c:	e9 a8 00 00 00       	jmp    800a49 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a8:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ab:	89 04 24             	mov    %eax,(%esp)
  8009ae:	e8 9b fc ff ff       	call   80064e <getuint>
  8009b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8009b9:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009c0:	e9 84 00 00 00       	jmp    800a49 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8009c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009cc:	8d 45 14             	lea    0x14(%ebp),%eax
  8009cf:	89 04 24             	mov    %eax,(%esp)
  8009d2:	e8 77 fc ff ff       	call   80064e <getuint>
  8009d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009da:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  8009dd:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  8009e4:	eb 63                	jmp    800a49 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8009e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ed:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f7:	ff d0                	call   *%eax
			putch('x', putdat);
  8009f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a00:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a07:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0a:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a0c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a0f:	8d 50 04             	lea    0x4(%eax),%edx
  800a12:	89 55 14             	mov    %edx,0x14(%ebp)
  800a15:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a17:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a1a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a21:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a28:	eb 1f                	jmp    800a49 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a2a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a31:	8d 45 14             	lea    0x14(%ebp),%eax
  800a34:	89 04 24             	mov    %eax,(%esp)
  800a37:	e8 12 fc ff ff       	call   80064e <getuint>
  800a3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a3f:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800a42:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a49:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800a4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a50:	89 54 24 18          	mov    %edx,0x18(%esp)
  800a54:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a57:	89 54 24 14          	mov    %edx,0x14(%esp)
  800a5b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a62:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a65:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a69:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a70:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a74:	8b 45 08             	mov    0x8(%ebp),%eax
  800a77:	89 04 24             	mov    %eax,(%esp)
  800a7a:	e8 f1 fa ff ff       	call   800570 <printnum>
			break;
  800a7f:	eb 3c                	jmp    800abd <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a81:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a84:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a88:	89 1c 24             	mov    %ebx,(%esp)
  800a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8e:	ff d0                	call   *%eax
			break;
  800a90:	eb 2b                	jmp    800abd <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a92:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a95:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a99:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa3:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800aa5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800aa9:	eb 04                	jmp    800aaf <vprintfmt+0x3cb>
  800aab:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800aaf:	8b 45 10             	mov    0x10(%ebp),%eax
  800ab2:	83 e8 01             	sub    $0x1,%eax
  800ab5:	0f b6 00             	movzbl (%eax),%eax
  800ab8:	3c 25                	cmp    $0x25,%al
  800aba:	75 ef                	jne    800aab <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800abc:	90                   	nop
		}
	}
  800abd:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800abe:	e9 43 fc ff ff       	jmp    800706 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800ac3:	83 c4 40             	add    $0x40,%esp
  800ac6:	5b                   	pop    %ebx
  800ac7:	5e                   	pop    %esi
  800ac8:	5d                   	pop    %ebp
  800ac9:	c3                   	ret    

00800aca <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800aca:	55                   	push   %ebp
  800acb:	89 e5                	mov    %esp,%ebp
  800acd:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800ad0:	8d 45 14             	lea    0x14(%ebp),%eax
  800ad3:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ad9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800add:	8b 45 10             	mov    0x10(%ebp),%eax
  800ae0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ae4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  800aee:	89 04 24             	mov    %eax,(%esp)
  800af1:	e8 ee fb ff ff       	call   8006e4 <vprintfmt>
	va_end(ap);
}
  800af6:	c9                   	leave  
  800af7:	c3                   	ret    

00800af8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800afb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afe:	8b 40 08             	mov    0x8(%eax),%eax
  800b01:	8d 50 01             	lea    0x1(%eax),%edx
  800b04:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b07:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0d:	8b 10                	mov    (%eax),%edx
  800b0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b12:	8b 40 04             	mov    0x4(%eax),%eax
  800b15:	39 c2                	cmp    %eax,%edx
  800b17:	73 12                	jae    800b2b <sprintputch+0x33>
		*b->buf++ = ch;
  800b19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1c:	8b 00                	mov    (%eax),%eax
  800b1e:	8d 48 01             	lea    0x1(%eax),%ecx
  800b21:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b24:	89 0a                	mov    %ecx,(%edx)
  800b26:	8b 55 08             	mov    0x8(%ebp),%edx
  800b29:	88 10                	mov    %dl,(%eax)
}
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b33:	8b 45 08             	mov    0x8(%ebp),%eax
  800b36:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3c:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b42:	01 d0                	add    %edx,%eax
  800b44:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b47:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b4e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b52:	74 06                	je     800b5a <vsnprintf+0x2d>
  800b54:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b58:	7f 07                	jg     800b61 <vsnprintf+0x34>
		return -E_INVAL;
  800b5a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b5f:	eb 2a                	jmp    800b8b <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b61:	8b 45 14             	mov    0x14(%ebp),%eax
  800b64:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b68:	8b 45 10             	mov    0x10(%ebp),%eax
  800b6b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b6f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b72:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b76:	c7 04 24 f8 0a 80 00 	movl   $0x800af8,(%esp)
  800b7d:	e8 62 fb ff ff       	call   8006e4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b82:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b85:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800b8b:	c9                   	leave  
  800b8c:	c3                   	ret    

00800b8d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b93:	8d 45 14             	lea    0x14(%ebp),%eax
  800b96:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800b99:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b9c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ba0:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ba7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800baa:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bae:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb1:	89 04 24             	mov    %eax,(%esp)
  800bb4:	e8 74 ff ff ff       	call   800b2d <vsnprintf>
  800bb9:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bbf:	c9                   	leave  
  800bc0:	c3                   	ret    

00800bc1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800bc7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800bce:	eb 08                	jmp    800bd8 <strlen+0x17>
		n++;
  800bd0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800bd4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800bd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdb:	0f b6 00             	movzbl (%eax),%eax
  800bde:	84 c0                	test   %al,%al
  800be0:	75 ee                	jne    800bd0 <strlen+0xf>
		n++;
	return n;
  800be2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800be5:	c9                   	leave  
  800be6:	c3                   	ret    

00800be7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bed:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800bf4:	eb 0c                	jmp    800c02 <strnlen+0x1b>
		n++;
  800bf6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bfa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800bfe:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800c02:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c06:	74 0a                	je     800c12 <strnlen+0x2b>
  800c08:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0b:	0f b6 00             	movzbl (%eax),%eax
  800c0e:	84 c0                	test   %al,%al
  800c10:	75 e4                	jne    800bf6 <strnlen+0xf>
		n++;
	return n;
  800c12:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c15:	c9                   	leave  
  800c16:	c3                   	ret    

00800c17 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c20:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c23:	90                   	nop
  800c24:	8b 45 08             	mov    0x8(%ebp),%eax
  800c27:	8d 50 01             	lea    0x1(%eax),%edx
  800c2a:	89 55 08             	mov    %edx,0x8(%ebp)
  800c2d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c30:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c33:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800c36:	0f b6 12             	movzbl (%edx),%edx
  800c39:	88 10                	mov    %dl,(%eax)
  800c3b:	0f b6 00             	movzbl (%eax),%eax
  800c3e:	84 c0                	test   %al,%al
  800c40:	75 e2                	jne    800c24 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800c42:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c45:	c9                   	leave  
  800c46:	c3                   	ret    

00800c47 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c50:	89 04 24             	mov    %eax,(%esp)
  800c53:	e8 69 ff ff ff       	call   800bc1 <strlen>
  800c58:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800c5b:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800c5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c61:	01 c2                	add    %eax,%edx
  800c63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c66:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c6a:	89 14 24             	mov    %edx,(%esp)
  800c6d:	e8 a5 ff ff ff       	call   800c17 <strcpy>
	return dst;
  800c72:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c75:	c9                   	leave  
  800c76:	c3                   	ret    

00800c77 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800c7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c80:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800c83:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c8a:	eb 23                	jmp    800caf <strncpy+0x38>
		*dst++ = *src;
  800c8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8f:	8d 50 01             	lea    0x1(%eax),%edx
  800c92:	89 55 08             	mov    %edx,0x8(%ebp)
  800c95:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c98:	0f b6 12             	movzbl (%edx),%edx
  800c9b:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800c9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca0:	0f b6 00             	movzbl (%eax),%eax
  800ca3:	84 c0                	test   %al,%al
  800ca5:	74 04                	je     800cab <strncpy+0x34>
			src++;
  800ca7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cab:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800caf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cb2:	3b 45 10             	cmp    0x10(%ebp),%eax
  800cb5:	72 d5                	jb     800c8c <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800cb7:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800cba:	c9                   	leave  
  800cbb:	c3                   	ret    

00800cbc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800cc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc5:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800cc8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ccc:	74 33                	je     800d01 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800cce:	eb 17                	jmp    800ce7 <strlcpy+0x2b>
			*dst++ = *src++;
  800cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd3:	8d 50 01             	lea    0x1(%eax),%edx
  800cd6:	89 55 08             	mov    %edx,0x8(%ebp)
  800cd9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cdc:	8d 4a 01             	lea    0x1(%edx),%ecx
  800cdf:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800ce2:	0f b6 12             	movzbl (%edx),%edx
  800ce5:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ce7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ceb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cef:	74 0a                	je     800cfb <strlcpy+0x3f>
  800cf1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf4:	0f b6 00             	movzbl (%eax),%eax
  800cf7:	84 c0                	test   %al,%al
  800cf9:	75 d5                	jne    800cd0 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfe:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d01:	8b 55 08             	mov    0x8(%ebp),%edx
  800d04:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d07:	29 c2                	sub    %eax,%edx
  800d09:	89 d0                	mov    %edx,%eax
}
  800d0b:	c9                   	leave  
  800d0c:	c3                   	ret    

00800d0d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d10:	eb 08                	jmp    800d1a <strcmp+0xd>
		p++, q++;
  800d12:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d16:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1d:	0f b6 00             	movzbl (%eax),%eax
  800d20:	84 c0                	test   %al,%al
  800d22:	74 10                	je     800d34 <strcmp+0x27>
  800d24:	8b 45 08             	mov    0x8(%ebp),%eax
  800d27:	0f b6 10             	movzbl (%eax),%edx
  800d2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d2d:	0f b6 00             	movzbl (%eax),%eax
  800d30:	38 c2                	cmp    %al,%dl
  800d32:	74 de                	je     800d12 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d34:	8b 45 08             	mov    0x8(%ebp),%eax
  800d37:	0f b6 00             	movzbl (%eax),%eax
  800d3a:	0f b6 d0             	movzbl %al,%edx
  800d3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d40:	0f b6 00             	movzbl (%eax),%eax
  800d43:	0f b6 c0             	movzbl %al,%eax
  800d46:	29 c2                	sub    %eax,%edx
  800d48:	89 d0                	mov    %edx,%eax
}
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800d4f:	eb 0c                	jmp    800d5d <strncmp+0x11>
		n--, p++, q++;
  800d51:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d55:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d59:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d5d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d61:	74 1a                	je     800d7d <strncmp+0x31>
  800d63:	8b 45 08             	mov    0x8(%ebp),%eax
  800d66:	0f b6 00             	movzbl (%eax),%eax
  800d69:	84 c0                	test   %al,%al
  800d6b:	74 10                	je     800d7d <strncmp+0x31>
  800d6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d70:	0f b6 10             	movzbl (%eax),%edx
  800d73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d76:	0f b6 00             	movzbl (%eax),%eax
  800d79:	38 c2                	cmp    %al,%dl
  800d7b:	74 d4                	je     800d51 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800d7d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d81:	75 07                	jne    800d8a <strncmp+0x3e>
		return 0;
  800d83:	b8 00 00 00 00       	mov    $0x0,%eax
  800d88:	eb 16                	jmp    800da0 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8d:	0f b6 00             	movzbl (%eax),%eax
  800d90:	0f b6 d0             	movzbl %al,%edx
  800d93:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d96:	0f b6 00             	movzbl (%eax),%eax
  800d99:	0f b6 c0             	movzbl %al,%eax
  800d9c:	29 c2                	sub    %eax,%edx
  800d9e:	89 d0                	mov    %edx,%eax
}
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    

00800da2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	83 ec 04             	sub    $0x4,%esp
  800da8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dab:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800dae:	eb 14                	jmp    800dc4 <strchr+0x22>
		if (*s == c)
  800db0:	8b 45 08             	mov    0x8(%ebp),%eax
  800db3:	0f b6 00             	movzbl (%eax),%eax
  800db6:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800db9:	75 05                	jne    800dc0 <strchr+0x1e>
			return (char *) s;
  800dbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbe:	eb 13                	jmp    800dd3 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dc0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc7:	0f b6 00             	movzbl (%eax),%eax
  800dca:	84 c0                	test   %al,%al
  800dcc:	75 e2                	jne    800db0 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800dce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dd3:	c9                   	leave  
  800dd4:	c3                   	ret    

00800dd5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800dd5:	55                   	push   %ebp
  800dd6:	89 e5                	mov    %esp,%ebp
  800dd8:	83 ec 04             	sub    $0x4,%esp
  800ddb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dde:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800de1:	eb 11                	jmp    800df4 <strfind+0x1f>
		if (*s == c)
  800de3:	8b 45 08             	mov    0x8(%ebp),%eax
  800de6:	0f b6 00             	movzbl (%eax),%eax
  800de9:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800dec:	75 02                	jne    800df0 <strfind+0x1b>
			break;
  800dee:	eb 0e                	jmp    800dfe <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800df0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800df4:	8b 45 08             	mov    0x8(%ebp),%eax
  800df7:	0f b6 00             	movzbl (%eax),%eax
  800dfa:	84 c0                	test   %al,%al
  800dfc:	75 e5                	jne    800de3 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800dfe:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e01:	c9                   	leave  
  800e02:	c3                   	ret    

00800e03 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e07:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e0b:	75 05                	jne    800e12 <memset+0xf>
		return v;
  800e0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e10:	eb 5c                	jmp    800e6e <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e12:	8b 45 08             	mov    0x8(%ebp),%eax
  800e15:	83 e0 03             	and    $0x3,%eax
  800e18:	85 c0                	test   %eax,%eax
  800e1a:	75 41                	jne    800e5d <memset+0x5a>
  800e1c:	8b 45 10             	mov    0x10(%ebp),%eax
  800e1f:	83 e0 03             	and    $0x3,%eax
  800e22:	85 c0                	test   %eax,%eax
  800e24:	75 37                	jne    800e5d <memset+0x5a>
		c &= 0xFF;
  800e26:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e30:	c1 e0 18             	shl    $0x18,%eax
  800e33:	89 c2                	mov    %eax,%edx
  800e35:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e38:	c1 e0 10             	shl    $0x10,%eax
  800e3b:	09 c2                	or     %eax,%edx
  800e3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e40:	c1 e0 08             	shl    $0x8,%eax
  800e43:	09 d0                	or     %edx,%eax
  800e45:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e48:	8b 45 10             	mov    0x10(%ebp),%eax
  800e4b:	c1 e8 02             	shr    $0x2,%eax
  800e4e:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e50:	8b 55 08             	mov    0x8(%ebp),%edx
  800e53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e56:	89 d7                	mov    %edx,%edi
  800e58:	fc                   	cld    
  800e59:	f3 ab                	rep stos %eax,%es:(%edi)
  800e5b:	eb 0e                	jmp    800e6b <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e60:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e63:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e66:	89 d7                	mov    %edx,%edi
  800e68:	fc                   	cld    
  800e69:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800e6b:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e6e:	5f                   	pop    %edi
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    

00800e71 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	57                   	push   %edi
  800e75:	56                   	push   %esi
  800e76:	53                   	push   %ebx
  800e77:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800e7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800e80:	8b 45 08             	mov    0x8(%ebp),%eax
  800e83:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800e86:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e89:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800e8c:	73 6d                	jae    800efb <memmove+0x8a>
  800e8e:	8b 45 10             	mov    0x10(%ebp),%eax
  800e91:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e94:	01 d0                	add    %edx,%eax
  800e96:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800e99:	76 60                	jbe    800efb <memmove+0x8a>
		s += n;
  800e9b:	8b 45 10             	mov    0x10(%ebp),%eax
  800e9e:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800ea1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ea4:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ea7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eaa:	83 e0 03             	and    $0x3,%eax
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	75 2f                	jne    800ee0 <memmove+0x6f>
  800eb1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800eb4:	83 e0 03             	and    $0x3,%eax
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	75 25                	jne    800ee0 <memmove+0x6f>
  800ebb:	8b 45 10             	mov    0x10(%ebp),%eax
  800ebe:	83 e0 03             	and    $0x3,%eax
  800ec1:	85 c0                	test   %eax,%eax
  800ec3:	75 1b                	jne    800ee0 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ec5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ec8:	83 e8 04             	sub    $0x4,%eax
  800ecb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ece:	83 ea 04             	sub    $0x4,%edx
  800ed1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ed4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ed7:	89 c7                	mov    %eax,%edi
  800ed9:	89 d6                	mov    %edx,%esi
  800edb:	fd                   	std    
  800edc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ede:	eb 18                	jmp    800ef8 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ee0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ee3:	8d 50 ff             	lea    -0x1(%eax),%edx
  800ee6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ee9:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800eec:	8b 45 10             	mov    0x10(%ebp),%eax
  800eef:	89 d7                	mov    %edx,%edi
  800ef1:	89 de                	mov    %ebx,%esi
  800ef3:	89 c1                	mov    %eax,%ecx
  800ef5:	fd                   	std    
  800ef6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ef8:	fc                   	cld    
  800ef9:	eb 45                	jmp    800f40 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800efb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800efe:	83 e0 03             	and    $0x3,%eax
  800f01:	85 c0                	test   %eax,%eax
  800f03:	75 2b                	jne    800f30 <memmove+0xbf>
  800f05:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f08:	83 e0 03             	and    $0x3,%eax
  800f0b:	85 c0                	test   %eax,%eax
  800f0d:	75 21                	jne    800f30 <memmove+0xbf>
  800f0f:	8b 45 10             	mov    0x10(%ebp),%eax
  800f12:	83 e0 03             	and    $0x3,%eax
  800f15:	85 c0                	test   %eax,%eax
  800f17:	75 17                	jne    800f30 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f19:	8b 45 10             	mov    0x10(%ebp),%eax
  800f1c:	c1 e8 02             	shr    $0x2,%eax
  800f1f:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f21:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f24:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f27:	89 c7                	mov    %eax,%edi
  800f29:	89 d6                	mov    %edx,%esi
  800f2b:	fc                   	cld    
  800f2c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f2e:	eb 10                	jmp    800f40 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f30:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f33:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f36:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f39:	89 c7                	mov    %eax,%edi
  800f3b:	89 d6                	mov    %edx,%esi
  800f3d:	fc                   	cld    
  800f3e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800f40:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f43:	83 c4 10             	add    $0x10,%esp
  800f46:	5b                   	pop    %ebx
  800f47:	5e                   	pop    %esi
  800f48:	5f                   	pop    %edi
  800f49:	5d                   	pop    %ebp
  800f4a:	c3                   	ret    

00800f4b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f51:	8b 45 10             	mov    0x10(%ebp),%eax
  800f54:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f62:	89 04 24             	mov    %eax,(%esp)
  800f65:	e8 07 ff ff ff       	call   800e71 <memmove>
}
  800f6a:	c9                   	leave  
  800f6b:	c3                   	ret    

00800f6c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800f72:	8b 45 08             	mov    0x8(%ebp),%eax
  800f75:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800f78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f7b:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800f7e:	eb 30                	jmp    800fb0 <memcmp+0x44>
		if (*s1 != *s2)
  800f80:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f83:	0f b6 10             	movzbl (%eax),%edx
  800f86:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f89:	0f b6 00             	movzbl (%eax),%eax
  800f8c:	38 c2                	cmp    %al,%dl
  800f8e:	74 18                	je     800fa8 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800f90:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f93:	0f b6 00             	movzbl (%eax),%eax
  800f96:	0f b6 d0             	movzbl %al,%edx
  800f99:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f9c:	0f b6 00             	movzbl (%eax),%eax
  800f9f:	0f b6 c0             	movzbl %al,%eax
  800fa2:	29 c2                	sub    %eax,%edx
  800fa4:	89 d0                	mov    %edx,%eax
  800fa6:	eb 1a                	jmp    800fc2 <memcmp+0x56>
		s1++, s2++;
  800fa8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800fac:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fb0:	8b 45 10             	mov    0x10(%ebp),%eax
  800fb3:	8d 50 ff             	lea    -0x1(%eax),%edx
  800fb6:	89 55 10             	mov    %edx,0x10(%ebp)
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	75 c3                	jne    800f80 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fc2:	c9                   	leave  
  800fc3:	c3                   	ret    

00800fc4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800fca:	8b 45 10             	mov    0x10(%ebp),%eax
  800fcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd0:	01 d0                	add    %edx,%eax
  800fd2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800fd5:	eb 13                	jmp    800fea <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fda:	0f b6 10             	movzbl (%eax),%edx
  800fdd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe0:	38 c2                	cmp    %al,%dl
  800fe2:	75 02                	jne    800fe6 <memfind+0x22>
			break;
  800fe4:	eb 0c                	jmp    800ff2 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fe6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800fea:	8b 45 08             	mov    0x8(%ebp),%eax
  800fed:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800ff0:	72 e5                	jb     800fd7 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800ff2:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ff5:	c9                   	leave  
  800ff6:	c3                   	ret    

00800ff7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800ffd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  801004:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80100b:	eb 04                	jmp    801011 <strtol+0x1a>
		s++;
  80100d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801011:	8b 45 08             	mov    0x8(%ebp),%eax
  801014:	0f b6 00             	movzbl (%eax),%eax
  801017:	3c 20                	cmp    $0x20,%al
  801019:	74 f2                	je     80100d <strtol+0x16>
  80101b:	8b 45 08             	mov    0x8(%ebp),%eax
  80101e:	0f b6 00             	movzbl (%eax),%eax
  801021:	3c 09                	cmp    $0x9,%al
  801023:	74 e8                	je     80100d <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  801025:	8b 45 08             	mov    0x8(%ebp),%eax
  801028:	0f b6 00             	movzbl (%eax),%eax
  80102b:	3c 2b                	cmp    $0x2b,%al
  80102d:	75 06                	jne    801035 <strtol+0x3e>
		s++;
  80102f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801033:	eb 15                	jmp    80104a <strtol+0x53>
	else if (*s == '-')
  801035:	8b 45 08             	mov    0x8(%ebp),%eax
  801038:	0f b6 00             	movzbl (%eax),%eax
  80103b:	3c 2d                	cmp    $0x2d,%al
  80103d:	75 0b                	jne    80104a <strtol+0x53>
		s++, neg = 1;
  80103f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801043:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80104a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80104e:	74 06                	je     801056 <strtol+0x5f>
  801050:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  801054:	75 24                	jne    80107a <strtol+0x83>
  801056:	8b 45 08             	mov    0x8(%ebp),%eax
  801059:	0f b6 00             	movzbl (%eax),%eax
  80105c:	3c 30                	cmp    $0x30,%al
  80105e:	75 1a                	jne    80107a <strtol+0x83>
  801060:	8b 45 08             	mov    0x8(%ebp),%eax
  801063:	83 c0 01             	add    $0x1,%eax
  801066:	0f b6 00             	movzbl (%eax),%eax
  801069:	3c 78                	cmp    $0x78,%al
  80106b:	75 0d                	jne    80107a <strtol+0x83>
		s += 2, base = 16;
  80106d:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  801071:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  801078:	eb 2a                	jmp    8010a4 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  80107a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80107e:	75 17                	jne    801097 <strtol+0xa0>
  801080:	8b 45 08             	mov    0x8(%ebp),%eax
  801083:	0f b6 00             	movzbl (%eax),%eax
  801086:	3c 30                	cmp    $0x30,%al
  801088:	75 0d                	jne    801097 <strtol+0xa0>
		s++, base = 8;
  80108a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80108e:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801095:	eb 0d                	jmp    8010a4 <strtol+0xad>
	else if (base == 0)
  801097:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80109b:	75 07                	jne    8010a4 <strtol+0xad>
		base = 10;
  80109d:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a7:	0f b6 00             	movzbl (%eax),%eax
  8010aa:	3c 2f                	cmp    $0x2f,%al
  8010ac:	7e 1b                	jle    8010c9 <strtol+0xd2>
  8010ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b1:	0f b6 00             	movzbl (%eax),%eax
  8010b4:	3c 39                	cmp    $0x39,%al
  8010b6:	7f 11                	jg     8010c9 <strtol+0xd2>
			dig = *s - '0';
  8010b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010bb:	0f b6 00             	movzbl (%eax),%eax
  8010be:	0f be c0             	movsbl %al,%eax
  8010c1:	83 e8 30             	sub    $0x30,%eax
  8010c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8010c7:	eb 48                	jmp    801111 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  8010c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cc:	0f b6 00             	movzbl (%eax),%eax
  8010cf:	3c 60                	cmp    $0x60,%al
  8010d1:	7e 1b                	jle    8010ee <strtol+0xf7>
  8010d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d6:	0f b6 00             	movzbl (%eax),%eax
  8010d9:	3c 7a                	cmp    $0x7a,%al
  8010db:	7f 11                	jg     8010ee <strtol+0xf7>
			dig = *s - 'a' + 10;
  8010dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e0:	0f b6 00             	movzbl (%eax),%eax
  8010e3:	0f be c0             	movsbl %al,%eax
  8010e6:	83 e8 57             	sub    $0x57,%eax
  8010e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8010ec:	eb 23                	jmp    801111 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  8010ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f1:	0f b6 00             	movzbl (%eax),%eax
  8010f4:	3c 40                	cmp    $0x40,%al
  8010f6:	7e 3d                	jle    801135 <strtol+0x13e>
  8010f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fb:	0f b6 00             	movzbl (%eax),%eax
  8010fe:	3c 5a                	cmp    $0x5a,%al
  801100:	7f 33                	jg     801135 <strtol+0x13e>
			dig = *s - 'A' + 10;
  801102:	8b 45 08             	mov    0x8(%ebp),%eax
  801105:	0f b6 00             	movzbl (%eax),%eax
  801108:	0f be c0             	movsbl %al,%eax
  80110b:	83 e8 37             	sub    $0x37,%eax
  80110e:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  801111:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801114:	3b 45 10             	cmp    0x10(%ebp),%eax
  801117:	7c 02                	jl     80111b <strtol+0x124>
			break;
  801119:	eb 1a                	jmp    801135 <strtol+0x13e>
		s++, val = (val * base) + dig;
  80111b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80111f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801122:	0f af 45 10          	imul   0x10(%ebp),%eax
  801126:	89 c2                	mov    %eax,%edx
  801128:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80112b:	01 d0                	add    %edx,%eax
  80112d:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  801130:	e9 6f ff ff ff       	jmp    8010a4 <strtol+0xad>

	if (endptr)
  801135:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801139:	74 08                	je     801143 <strtol+0x14c>
		*endptr = (char *) s;
  80113b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80113e:	8b 55 08             	mov    0x8(%ebp),%edx
  801141:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801143:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  801147:	74 07                	je     801150 <strtol+0x159>
  801149:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80114c:	f7 d8                	neg    %eax
  80114e:	eb 03                	jmp    801153 <strtol+0x15c>
  801150:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  801153:	c9                   	leave  
  801154:	c3                   	ret    
  801155:	66 90                	xchg   %ax,%ax
  801157:	66 90                	xchg   %ax,%ax
  801159:	66 90                	xchg   %ax,%ax
  80115b:	66 90                	xchg   %ax,%ax
  80115d:	66 90                	xchg   %ax,%ax
  80115f:	90                   	nop

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
