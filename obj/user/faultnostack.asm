
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
  800039:	c7 44 24 04 3f 04 80 	movl   $0x80043f,0x4(%esp)
  800040:	00 
  800041:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800048:	e8 2d 03 00 00       	call   80037a <sys_env_set_pgfault_upcall>
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
  800060:	e8 82 01 00 00       	call   8001e7 <sys_getenvid>
  800065:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006a:	c1 e0 02             	shl    $0x2,%eax
  80006d:	89 c2                	mov    %eax,%edx
  80006f:	c1 e2 05             	shl    $0x5,%edx
  800072:	29 c2                	sub    %eax,%edx
  800074:	89 d0                	mov    %edx,%eax
  800076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800084:	7e 0a                	jle    800090 <libmain+0x36>
		binaryname = argv[0];
  800086:	8b 45 0c             	mov    0xc(%ebp),%eax
  800089:	8b 00                	mov    (%eax),%eax
  80008b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800090:	8b 45 0c             	mov    0xc(%ebp),%eax
  800093:	89 44 24 04          	mov    %eax,0x4(%esp)
  800097:	8b 45 08             	mov    0x8(%ebp),%eax
  80009a:	89 04 24             	mov    %eax,(%esp)
  80009d:	e8 91 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a2:	e8 02 00 00 00       	call   8000a9 <exit>
}
  8000a7:	c9                   	leave  
  8000a8:	c3                   	ret    

008000a9 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a9:	55                   	push   %ebp
  8000aa:	89 e5                	mov    %esp,%ebp
  8000ac:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b6:	e8 e9 00 00 00       	call   8001a4 <sys_env_destroy>
}
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    

008000bd <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	57                   	push   %edi
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
  8000c3:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8000c9:	8b 55 10             	mov    0x10(%ebp),%edx
  8000cc:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8000cf:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8000d2:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  8000d5:	8b 75 20             	mov    0x20(%ebp),%esi
  8000d8:	cd 30                	int    $0x30
  8000da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000dd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8000e1:	74 30                	je     800113 <syscall+0x56>
  8000e3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000e7:	7e 2a                	jle    800113 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000ec:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8000f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f7:	c7 44 24 08 aa 14 80 	movl   $0x8014aa,0x8(%esp)
  8000fe:	00 
  8000ff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800106:	00 
  800107:	c7 04 24 c7 14 80 00 	movl   $0x8014c7,(%esp)
  80010e:	e8 50 03 00 00       	call   800463 <_panic>

	return ret;
  800113:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800116:	83 c4 3c             	add    $0x3c,%esp
  800119:	5b                   	pop    %ebx
  80011a:	5e                   	pop    %esi
  80011b:	5f                   	pop    %edi
  80011c:	5d                   	pop    %ebp
  80011d:	c3                   	ret    

0080011e <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800124:	8b 45 08             	mov    0x8(%ebp),%eax
  800127:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80012e:	00 
  80012f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800136:	00 
  800137:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80013e:	00 
  80013f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800142:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800146:	89 44 24 08          	mov    %eax,0x8(%esp)
  80014a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800151:	00 
  800152:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800159:	e8 5f ff ff ff       	call   8000bd <syscall>
}
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <sys_cgetc>:

int
sys_cgetc(void)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800166:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80016d:	00 
  80016e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800175:	00 
  800176:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80017d:	00 
  80017e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800185:	00 
  800186:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80018d:	00 
  80018e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800195:	00 
  800196:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80019d:	e8 1b ff ff ff       	call   8000bd <syscall>
}
  8001a2:	c9                   	leave  
  8001a3:	c3                   	ret    

008001a4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8001aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ad:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001b4:	00 
  8001b5:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001bc:	00 
  8001bd:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001c4:	00 
  8001c5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001cc:	00 
  8001cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001d8:	00 
  8001d9:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8001e0:	e8 d8 fe ff ff       	call   8000bd <syscall>
}
  8001e5:	c9                   	leave  
  8001e6:	c3                   	ret    

008001e7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8001ed:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001f4:	00 
  8001f5:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001fc:	00 
  8001fd:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800204:	00 
  800205:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80020c:	00 
  80020d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800214:	00 
  800215:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80021c:	00 
  80021d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800224:	e8 94 fe ff ff       	call   8000bd <syscall>
}
  800229:	c9                   	leave  
  80022a:	c3                   	ret    

0080022b <sys_yield>:

void
sys_yield(void)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800231:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800238:	00 
  800239:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800240:	00 
  800241:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800248:	00 
  800249:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800250:	00 
  800251:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800258:	00 
  800259:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800260:	00 
  800261:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800268:	e8 50 fe ff ff       	call   8000bd <syscall>
}
  80026d:	c9                   	leave  
  80026e:	c3                   	ret    

0080026f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800275:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800278:	8b 55 0c             	mov    0xc(%ebp),%edx
  80027b:	8b 45 08             	mov    0x8(%ebp),%eax
  80027e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800285:	00 
  800286:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80028d:	00 
  80028e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800292:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800296:	89 44 24 08          	mov    %eax,0x8(%esp)
  80029a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002a1:	00 
  8002a2:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  8002a9:	e8 0f fe ff ff       	call   8000bd <syscall>
}
  8002ae:	c9                   	leave  
  8002af:	c3                   	ret    

008002b0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	56                   	push   %esi
  8002b4:	53                   	push   %ebx
  8002b5:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8002b8:	8b 75 18             	mov    0x18(%ebp),%esi
  8002bb:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002be:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c7:	89 74 24 18          	mov    %esi,0x18(%esp)
  8002cb:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002cf:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002d3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002db:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002e2:	00 
  8002e3:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8002ea:	e8 ce fd ff ff       	call   8000bd <syscall>
}
  8002ef:	83 c4 20             	add    $0x20,%esp
  8002f2:	5b                   	pop    %ebx
  8002f3:	5e                   	pop    %esi
  8002f4:	5d                   	pop    %ebp
  8002f5:	c3                   	ret    

008002f6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
  8002f9:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8002fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800302:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800309:	00 
  80030a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800311:	00 
  800312:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800319:	00 
  80031a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80031e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800322:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800329:	00 
  80032a:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  800331:	e8 87 fd ff ff       	call   8000bd <syscall>
}
  800336:	c9                   	leave  
  800337:	c3                   	ret    

00800338 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
  80033b:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80033e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800341:	8b 45 08             	mov    0x8(%ebp),%eax
  800344:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80034b:	00 
  80034c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800353:	00 
  800354:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80035b:	00 
  80035c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800360:	89 44 24 08          	mov    %eax,0x8(%esp)
  800364:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80036b:	00 
  80036c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800373:	e8 45 fd ff ff       	call   8000bd <syscall>
}
  800378:	c9                   	leave  
  800379:	c3                   	ret    

0080037a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800380:	8b 55 0c             	mov    0xc(%ebp),%edx
  800383:	8b 45 08             	mov    0x8(%ebp),%eax
  800386:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80038d:	00 
  80038e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800395:	00 
  800396:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80039d:	00 
  80039e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8003ad:	00 
  8003ae:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8003b5:	e8 03 fd ff ff       	call   8000bd <syscall>
}
  8003ba:	c9                   	leave  
  8003bb:	c3                   	ret    

008003bc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8003c2:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003c5:	8b 55 10             	mov    0x10(%ebp),%edx
  8003c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cb:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003d2:	00 
  8003d3:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8003d7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003de:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003e6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003ed:	00 
  8003ee:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8003f5:	e8 c3 fc ff ff       	call   8000bd <syscall>
}
  8003fa:	c9                   	leave  
  8003fb:	c3                   	ret    

008003fc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
  8003ff:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800402:	8b 45 08             	mov    0x8(%ebp),%eax
  800405:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80040c:	00 
  80040d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800414:	00 
  800415:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80041c:	00 
  80041d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800424:	00 
  800425:	89 44 24 08          	mov    %eax,0x8(%esp)
  800429:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800430:	00 
  800431:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  800438:	e8 80 fc ff ff       	call   8000bd <syscall>
}
  80043d:	c9                   	leave  
  80043e:	c3                   	ret    

0080043f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80043f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800440:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800445:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800447:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 40(%esp) , %eax 		//store trap-time eip in eax
  80044a:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %esp , %ebp 			// save current stack location
  80044e:	89 e5                	mov    %esp,%ebp
	movl 48(%esp) , %esp 		// switch to trap time stack
  800450:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 					// push eip, esp gets changed
  800454:	50                   	push   %eax
	movl %esp , 48(%ebp) 		// save current esp to update the trap time esp
  800455:	89 65 30             	mov    %esp,0x30(%ebp)
	movl %ebp , %esp 			// move to user stack
  800458:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	popl %eax 					// pop fault_va
  80045a:	58                   	pop    %eax
	popl %eax 					// pop tf_err
  80045b:	58                   	pop    %eax
	popal 						// pop all the registers
  80045c:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4 , %esp
  80045d:	83 c4 04             	add    $0x4,%esp
	popfl
  800460:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp
  800461:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  800462:	c3                   	ret    

00800463 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800463:	55                   	push   %ebp
  800464:	89 e5                	mov    %esp,%ebp
  800466:	53                   	push   %ebx
  800467:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80046a:	8d 45 14             	lea    0x14(%ebp),%eax
  80046d:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800470:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800476:	e8 6c fd ff ff       	call   8001e7 <sys_getenvid>
  80047b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80047e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800482:	8b 55 08             	mov    0x8(%ebp),%edx
  800485:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800489:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80048d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800491:	c7 04 24 d8 14 80 00 	movl   $0x8014d8,(%esp)
  800498:	e8 e1 00 00 00       	call   80057e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80049d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8004a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8004a7:	89 04 24             	mov    %eax,(%esp)
  8004aa:	e8 6b 00 00 00       	call   80051a <vcprintf>
	cprintf("\n");
  8004af:	c7 04 24 fb 14 80 00 	movl   $0x8014fb,(%esp)
  8004b6:	e8 c3 00 00 00       	call   80057e <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004bb:	cc                   	int3   
  8004bc:	eb fd                	jmp    8004bb <_panic+0x58>

008004be <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004be:	55                   	push   %ebp
  8004bf:	89 e5                	mov    %esp,%ebp
  8004c1:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8004c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c7:	8b 00                	mov    (%eax),%eax
  8004c9:	8d 48 01             	lea    0x1(%eax),%ecx
  8004cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004cf:	89 0a                	mov    %ecx,(%edx)
  8004d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8004d4:	89 d1                	mov    %edx,%ecx
  8004d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004d9:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8004dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e0:	8b 00                	mov    (%eax),%eax
  8004e2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004e7:	75 20                	jne    800509 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8004e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ec:	8b 00                	mov    (%eax),%eax
  8004ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004f1:	83 c2 08             	add    $0x8,%edx
  8004f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f8:	89 14 24             	mov    %edx,(%esp)
  8004fb:	e8 1e fc ff ff       	call   80011e <sys_cputs>
		b->idx = 0;
  800500:	8b 45 0c             	mov    0xc(%ebp),%eax
  800503:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800509:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050c:	8b 40 04             	mov    0x4(%eax),%eax
  80050f:	8d 50 01             	lea    0x1(%eax),%edx
  800512:	8b 45 0c             	mov    0xc(%ebp),%eax
  800515:	89 50 04             	mov    %edx,0x4(%eax)
}
  800518:	c9                   	leave  
  800519:	c3                   	ret    

0080051a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80051a:	55                   	push   %ebp
  80051b:	89 e5                	mov    %esp,%ebp
  80051d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800523:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80052a:	00 00 00 
	b.cnt = 0;
  80052d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800534:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800537:	8b 45 0c             	mov    0xc(%ebp),%eax
  80053a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80053e:	8b 45 08             	mov    0x8(%ebp),%eax
  800541:	89 44 24 08          	mov    %eax,0x8(%esp)
  800545:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80054b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054f:	c7 04 24 be 04 80 00 	movl   $0x8004be,(%esp)
  800556:	e8 bd 01 00 00       	call   800718 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80055b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800561:	89 44 24 04          	mov    %eax,0x4(%esp)
  800565:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80056b:	83 c0 08             	add    $0x8,%eax
  80056e:	89 04 24             	mov    %eax,(%esp)
  800571:	e8 a8 fb ff ff       	call   80011e <sys_cputs>

	return b.cnt;
  800576:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80057c:	c9                   	leave  
  80057d:	c3                   	ret    

0080057e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80057e:	55                   	push   %ebp
  80057f:	89 e5                	mov    %esp,%ebp
  800581:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800584:	8d 45 0c             	lea    0xc(%ebp),%eax
  800587:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  80058a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80058d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800591:	8b 45 08             	mov    0x8(%ebp),%eax
  800594:	89 04 24             	mov    %eax,(%esp)
  800597:	e8 7e ff ff ff       	call   80051a <vcprintf>
  80059c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  80059f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8005a2:	c9                   	leave  
  8005a3:	c3                   	ret    

008005a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005a4:	55                   	push   %ebp
  8005a5:	89 e5                	mov    %esp,%ebp
  8005a7:	53                   	push   %ebx
  8005a8:	83 ec 34             	sub    $0x34,%esp
  8005ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8005ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005b7:	8b 45 18             	mov    0x18(%ebp),%eax
  8005ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8005bf:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005c2:	77 72                	ja     800636 <printnum+0x92>
  8005c4:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005c7:	72 05                	jb     8005ce <printnum+0x2a>
  8005c9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8005cc:	77 68                	ja     800636 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005ce:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8005d1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8005d4:	8b 45 18             	mov    0x18(%ebp),%eax
  8005d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8005dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005e0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005ea:	89 04 24             	mov    %eax,(%esp)
  8005ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005f1:	e8 0a 0c 00 00       	call   801200 <__udivdi3>
  8005f6:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8005f9:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8005fd:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800601:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800604:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800608:	89 44 24 08          	mov    %eax,0x8(%esp)
  80060c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800610:	8b 45 0c             	mov    0xc(%ebp),%eax
  800613:	89 44 24 04          	mov    %eax,0x4(%esp)
  800617:	8b 45 08             	mov    0x8(%ebp),%eax
  80061a:	89 04 24             	mov    %eax,(%esp)
  80061d:	e8 82 ff ff ff       	call   8005a4 <printnum>
  800622:	eb 1c                	jmp    800640 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800624:	8b 45 0c             	mov    0xc(%ebp),%eax
  800627:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062b:	8b 45 20             	mov    0x20(%ebp),%eax
  80062e:	89 04 24             	mov    %eax,(%esp)
  800631:	8b 45 08             	mov    0x8(%ebp),%eax
  800634:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800636:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  80063a:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  80063e:	7f e4                	jg     800624 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800640:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800643:	bb 00 00 00 00       	mov    $0x0,%ebx
  800648:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80064b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80064e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800652:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800656:	89 04 24             	mov    %eax,(%esp)
  800659:	89 54 24 04          	mov    %edx,0x4(%esp)
  80065d:	e8 ce 0c 00 00       	call   801330 <__umoddi3>
  800662:	05 c8 15 80 00       	add    $0x8015c8,%eax
  800667:	0f b6 00             	movzbl (%eax),%eax
  80066a:	0f be c0             	movsbl %al,%eax
  80066d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800670:	89 54 24 04          	mov    %edx,0x4(%esp)
  800674:	89 04 24             	mov    %eax,(%esp)
  800677:	8b 45 08             	mov    0x8(%ebp),%eax
  80067a:	ff d0                	call   *%eax
}
  80067c:	83 c4 34             	add    $0x34,%esp
  80067f:	5b                   	pop    %ebx
  800680:	5d                   	pop    %ebp
  800681:	c3                   	ret    

00800682 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800682:	55                   	push   %ebp
  800683:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800685:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800689:	7e 14                	jle    80069f <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80068b:	8b 45 08             	mov    0x8(%ebp),%eax
  80068e:	8b 00                	mov    (%eax),%eax
  800690:	8d 48 08             	lea    0x8(%eax),%ecx
  800693:	8b 55 08             	mov    0x8(%ebp),%edx
  800696:	89 0a                	mov    %ecx,(%edx)
  800698:	8b 50 04             	mov    0x4(%eax),%edx
  80069b:	8b 00                	mov    (%eax),%eax
  80069d:	eb 30                	jmp    8006cf <getuint+0x4d>
	else if (lflag)
  80069f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006a3:	74 16                	je     8006bb <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8006a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a8:	8b 00                	mov    (%eax),%eax
  8006aa:	8d 48 04             	lea    0x4(%eax),%ecx
  8006ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8006b0:	89 0a                	mov    %ecx,(%edx)
  8006b2:	8b 00                	mov    (%eax),%eax
  8006b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8006b9:	eb 14                	jmp    8006cf <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8006bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006be:	8b 00                	mov    (%eax),%eax
  8006c0:	8d 48 04             	lea    0x4(%eax),%ecx
  8006c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8006c6:	89 0a                	mov    %ecx,(%edx)
  8006c8:	8b 00                	mov    (%eax),%eax
  8006ca:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006cf:	5d                   	pop    %ebp
  8006d0:	c3                   	ret    

008006d1 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8006d1:	55                   	push   %ebp
  8006d2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006d4:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8006d8:	7e 14                	jle    8006ee <getint+0x1d>
		return va_arg(*ap, long long);
  8006da:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dd:	8b 00                	mov    (%eax),%eax
  8006df:	8d 48 08             	lea    0x8(%eax),%ecx
  8006e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e5:	89 0a                	mov    %ecx,(%edx)
  8006e7:	8b 50 04             	mov    0x4(%eax),%edx
  8006ea:	8b 00                	mov    (%eax),%eax
  8006ec:	eb 28                	jmp    800716 <getint+0x45>
	else if (lflag)
  8006ee:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006f2:	74 12                	je     800706 <getint+0x35>
		return va_arg(*ap, long);
  8006f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f7:	8b 00                	mov    (%eax),%eax
  8006f9:	8d 48 04             	lea    0x4(%eax),%ecx
  8006fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8006ff:	89 0a                	mov    %ecx,(%edx)
  800701:	8b 00                	mov    (%eax),%eax
  800703:	99                   	cltd   
  800704:	eb 10                	jmp    800716 <getint+0x45>
	else
		return va_arg(*ap, int);
  800706:	8b 45 08             	mov    0x8(%ebp),%eax
  800709:	8b 00                	mov    (%eax),%eax
  80070b:	8d 48 04             	lea    0x4(%eax),%ecx
  80070e:	8b 55 08             	mov    0x8(%ebp),%edx
  800711:	89 0a                	mov    %ecx,(%edx)
  800713:	8b 00                	mov    (%eax),%eax
  800715:	99                   	cltd   
}
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	56                   	push   %esi
  80071c:	53                   	push   %ebx
  80071d:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800720:	eb 18                	jmp    80073a <vprintfmt+0x22>
			if (ch == '\0')
  800722:	85 db                	test   %ebx,%ebx
  800724:	75 05                	jne    80072b <vprintfmt+0x13>
				return;
  800726:	e9 cc 03 00 00       	jmp    800af7 <vprintfmt+0x3df>
			putch(ch, putdat);
  80072b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80072e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800732:	89 1c 24             	mov    %ebx,(%esp)
  800735:	8b 45 08             	mov    0x8(%ebp),%eax
  800738:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80073a:	8b 45 10             	mov    0x10(%ebp),%eax
  80073d:	8d 50 01             	lea    0x1(%eax),%edx
  800740:	89 55 10             	mov    %edx,0x10(%ebp)
  800743:	0f b6 00             	movzbl (%eax),%eax
  800746:	0f b6 d8             	movzbl %al,%ebx
  800749:	83 fb 25             	cmp    $0x25,%ebx
  80074c:	75 d4                	jne    800722 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  80074e:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800752:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800759:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800760:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800767:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076e:	8b 45 10             	mov    0x10(%ebp),%eax
  800771:	8d 50 01             	lea    0x1(%eax),%edx
  800774:	89 55 10             	mov    %edx,0x10(%ebp)
  800777:	0f b6 00             	movzbl (%eax),%eax
  80077a:	0f b6 d8             	movzbl %al,%ebx
  80077d:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800780:	83 f8 55             	cmp    $0x55,%eax
  800783:	0f 87 3d 03 00 00    	ja     800ac6 <vprintfmt+0x3ae>
  800789:	8b 04 85 ec 15 80 00 	mov    0x8015ec(,%eax,4),%eax
  800790:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800792:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800796:	eb d6                	jmp    80076e <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800798:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  80079c:	eb d0                	jmp    80076e <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80079e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8007a5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007a8:	89 d0                	mov    %edx,%eax
  8007aa:	c1 e0 02             	shl    $0x2,%eax
  8007ad:	01 d0                	add    %edx,%eax
  8007af:	01 c0                	add    %eax,%eax
  8007b1:	01 d8                	add    %ebx,%eax
  8007b3:	83 e8 30             	sub    $0x30,%eax
  8007b6:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8007b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8007bc:	0f b6 00             	movzbl (%eax),%eax
  8007bf:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8007c2:	83 fb 2f             	cmp    $0x2f,%ebx
  8007c5:	7e 0b                	jle    8007d2 <vprintfmt+0xba>
  8007c7:	83 fb 39             	cmp    $0x39,%ebx
  8007ca:	7f 06                	jg     8007d2 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007cc:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8007d0:	eb d3                	jmp    8007a5 <vprintfmt+0x8d>
			goto process_precision;
  8007d2:	eb 33                	jmp    800807 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8007d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d7:	8d 50 04             	lea    0x4(%eax),%edx
  8007da:	89 55 14             	mov    %edx,0x14(%ebp)
  8007dd:	8b 00                	mov    (%eax),%eax
  8007df:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8007e2:	eb 23                	jmp    800807 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8007e4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007e8:	79 0c                	jns    8007f6 <vprintfmt+0xde>
				width = 0;
  8007ea:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8007f1:	e9 78 ff ff ff       	jmp    80076e <vprintfmt+0x56>
  8007f6:	e9 73 ff ff ff       	jmp    80076e <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8007fb:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800802:	e9 67 ff ff ff       	jmp    80076e <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800807:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80080b:	79 12                	jns    80081f <vprintfmt+0x107>
				width = precision, precision = -1;
  80080d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800810:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800813:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  80081a:	e9 4f ff ff ff       	jmp    80076e <vprintfmt+0x56>
  80081f:	e9 4a ff ff ff       	jmp    80076e <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800824:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800828:	e9 41 ff ff ff       	jmp    80076e <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80082d:	8b 45 14             	mov    0x14(%ebp),%eax
  800830:	8d 50 04             	lea    0x4(%eax),%edx
  800833:	89 55 14             	mov    %edx,0x14(%ebp)
  800836:	8b 00                	mov    (%eax),%eax
  800838:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80083f:	89 04 24             	mov    %eax,(%esp)
  800842:	8b 45 08             	mov    0x8(%ebp),%eax
  800845:	ff d0                	call   *%eax
			break;
  800847:	e9 a5 02 00 00       	jmp    800af1 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80084c:	8b 45 14             	mov    0x14(%ebp),%eax
  80084f:	8d 50 04             	lea    0x4(%eax),%edx
  800852:	89 55 14             	mov    %edx,0x14(%ebp)
  800855:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800857:	85 db                	test   %ebx,%ebx
  800859:	79 02                	jns    80085d <vprintfmt+0x145>
				err = -err;
  80085b:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80085d:	83 fb 09             	cmp    $0x9,%ebx
  800860:	7f 0b                	jg     80086d <vprintfmt+0x155>
  800862:	8b 34 9d a0 15 80 00 	mov    0x8015a0(,%ebx,4),%esi
  800869:	85 f6                	test   %esi,%esi
  80086b:	75 23                	jne    800890 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  80086d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800871:	c7 44 24 08 d9 15 80 	movl   $0x8015d9,0x8(%esp)
  800878:	00 
  800879:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	89 04 24             	mov    %eax,(%esp)
  800886:	e8 73 02 00 00       	call   800afe <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80088b:	e9 61 02 00 00       	jmp    800af1 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800890:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800894:	c7 44 24 08 e2 15 80 	movl   $0x8015e2,0x8(%esp)
  80089b:	00 
  80089c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a6:	89 04 24             	mov    %eax,(%esp)
  8008a9:	e8 50 02 00 00       	call   800afe <printfmt>
			break;
  8008ae:	e9 3e 02 00 00       	jmp    800af1 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b6:	8d 50 04             	lea    0x4(%eax),%edx
  8008b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8008bc:	8b 30                	mov    (%eax),%esi
  8008be:	85 f6                	test   %esi,%esi
  8008c0:	75 05                	jne    8008c7 <vprintfmt+0x1af>
				p = "(null)";
  8008c2:	be e5 15 80 00       	mov    $0x8015e5,%esi
			if (width > 0 && padc != '-')
  8008c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008cb:	7e 37                	jle    800904 <vprintfmt+0x1ec>
  8008cd:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8008d1:	74 31                	je     800904 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008da:	89 34 24             	mov    %esi,(%esp)
  8008dd:	e8 39 03 00 00       	call   800c1b <strnlen>
  8008e2:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8008e5:	eb 17                	jmp    8008fe <vprintfmt+0x1e6>
					putch(padc, putdat);
  8008e7:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8008eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008f2:	89 04 24             	mov    %eax,(%esp)
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008fa:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008fe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800902:	7f e3                	jg     8008e7 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800904:	eb 38                	jmp    80093e <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800906:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80090a:	74 1f                	je     80092b <vprintfmt+0x213>
  80090c:	83 fb 1f             	cmp    $0x1f,%ebx
  80090f:	7e 05                	jle    800916 <vprintfmt+0x1fe>
  800911:	83 fb 7e             	cmp    $0x7e,%ebx
  800914:	7e 15                	jle    80092b <vprintfmt+0x213>
					putch('?', putdat);
  800916:	8b 45 0c             	mov    0xc(%ebp),%eax
  800919:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800924:	8b 45 08             	mov    0x8(%ebp),%eax
  800927:	ff d0                	call   *%eax
  800929:	eb 0f                	jmp    80093a <vprintfmt+0x222>
				else
					putch(ch, putdat);
  80092b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800932:	89 1c 24             	mov    %ebx,(%esp)
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80093a:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80093e:	89 f0                	mov    %esi,%eax
  800940:	8d 70 01             	lea    0x1(%eax),%esi
  800943:	0f b6 00             	movzbl (%eax),%eax
  800946:	0f be d8             	movsbl %al,%ebx
  800949:	85 db                	test   %ebx,%ebx
  80094b:	74 10                	je     80095d <vprintfmt+0x245>
  80094d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800951:	78 b3                	js     800906 <vprintfmt+0x1ee>
  800953:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800957:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80095b:	79 a9                	jns    800906 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80095d:	eb 17                	jmp    800976 <vprintfmt+0x25e>
				putch(' ', putdat);
  80095f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800962:	89 44 24 04          	mov    %eax,0x4(%esp)
  800966:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800972:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800976:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80097a:	7f e3                	jg     80095f <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  80097c:	e9 70 01 00 00       	jmp    800af1 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800981:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800984:	89 44 24 04          	mov    %eax,0x4(%esp)
  800988:	8d 45 14             	lea    0x14(%ebp),%eax
  80098b:	89 04 24             	mov    %eax,(%esp)
  80098e:	e8 3e fd ff ff       	call   8006d1 <getint>
  800993:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800996:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800999:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80099c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80099f:	85 d2                	test   %edx,%edx
  8009a1:	79 26                	jns    8009c9 <vprintfmt+0x2b1>
				putch('-', putdat);
  8009a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009aa:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	ff d0                	call   *%eax
				num = -(long long) num;
  8009b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009bc:	f7 d8                	neg    %eax
  8009be:	83 d2 00             	adc    $0x0,%edx
  8009c1:	f7 da                	neg    %edx
  8009c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009c6:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8009c9:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009d0:	e9 a8 00 00 00       	jmp    800a7d <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009dc:	8d 45 14             	lea    0x14(%ebp),%eax
  8009df:	89 04 24             	mov    %eax,(%esp)
  8009e2:	e8 9b fc ff ff       	call   800682 <getuint>
  8009e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009ea:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8009ed:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009f4:	e9 84 00 00 00       	jmp    800a7d <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8009f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a00:	8d 45 14             	lea    0x14(%ebp),%eax
  800a03:	89 04 24             	mov    %eax,(%esp)
  800a06:	e8 77 fc ff ff       	call   800682 <getuint>
  800a0b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a0e:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800a11:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800a18:	eb 63                	jmp    800a7d <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a21:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a28:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2b:	ff d0                	call   *%eax
			putch('x', putdat);
  800a2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a30:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a34:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3e:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a40:	8b 45 14             	mov    0x14(%ebp),%eax
  800a43:	8d 50 04             	lea    0x4(%eax),%edx
  800a46:	89 55 14             	mov    %edx,0x14(%ebp)
  800a49:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a4e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a55:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a5c:	eb 1f                	jmp    800a7d <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a5e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a61:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a65:	8d 45 14             	lea    0x14(%ebp),%eax
  800a68:	89 04 24             	mov    %eax,(%esp)
  800a6b:	e8 12 fc ff ff       	call   800682 <getuint>
  800a70:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a73:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800a76:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a7d:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800a81:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a84:	89 54 24 18          	mov    %edx,0x18(%esp)
  800a88:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a8b:	89 54 24 14          	mov    %edx,0x14(%esp)
  800a8f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a96:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a99:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a9d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800aa1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aab:	89 04 24             	mov    %eax,(%esp)
  800aae:	e8 f1 fa ff ff       	call   8005a4 <printnum>
			break;
  800ab3:	eb 3c                	jmp    800af1 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ab5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800abc:	89 1c 24             	mov    %ebx,(%esp)
  800abf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac2:	ff d0                	call   *%eax
			break;
  800ac4:	eb 2b                	jmp    800af1 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ac6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800acd:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad7:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ad9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800add:	eb 04                	jmp    800ae3 <vprintfmt+0x3cb>
  800adf:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ae3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ae6:	83 e8 01             	sub    $0x1,%eax
  800ae9:	0f b6 00             	movzbl (%eax),%eax
  800aec:	3c 25                	cmp    $0x25,%al
  800aee:	75 ef                	jne    800adf <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800af0:	90                   	nop
		}
	}
  800af1:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800af2:	e9 43 fc ff ff       	jmp    80073a <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800af7:	83 c4 40             	add    $0x40,%esp
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b04:	8d 45 14             	lea    0x14(%ebp),%eax
  800b07:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b0d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b11:	8b 45 10             	mov    0x10(%ebp),%eax
  800b14:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b22:	89 04 24             	mov    %eax,(%esp)
  800b25:	e8 ee fb ff ff       	call   800718 <vprintfmt>
	va_end(ap);
}
  800b2a:	c9                   	leave  
  800b2b:	c3                   	ret    

00800b2c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800b2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b32:	8b 40 08             	mov    0x8(%eax),%eax
  800b35:	8d 50 01             	lea    0x1(%eax),%edx
  800b38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3b:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b41:	8b 10                	mov    (%eax),%edx
  800b43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b46:	8b 40 04             	mov    0x4(%eax),%eax
  800b49:	39 c2                	cmp    %eax,%edx
  800b4b:	73 12                	jae    800b5f <sprintputch+0x33>
		*b->buf++ = ch;
  800b4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b50:	8b 00                	mov    (%eax),%eax
  800b52:	8d 48 01             	lea    0x1(%eax),%ecx
  800b55:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b58:	89 0a                	mov    %ecx,(%edx)
  800b5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5d:	88 10                	mov    %dl,(%eax)
}
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    

00800b61 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b67:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b70:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b73:	8b 45 08             	mov    0x8(%ebp),%eax
  800b76:	01 d0                	add    %edx,%eax
  800b78:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b7b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b82:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b86:	74 06                	je     800b8e <vsnprintf+0x2d>
  800b88:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b8c:	7f 07                	jg     800b95 <vsnprintf+0x34>
		return -E_INVAL;
  800b8e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b93:	eb 2a                	jmp    800bbf <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b95:	8b 45 14             	mov    0x14(%ebp),%eax
  800b98:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b9c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b9f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ba3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ba6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800baa:	c7 04 24 2c 0b 80 00 	movl   $0x800b2c,(%esp)
  800bb1:	e8 62 fb ff ff       	call   800718 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bb6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bb9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bbf:	c9                   	leave  
  800bc0:	c3                   	ret    

00800bc1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bc7:	8d 45 14             	lea    0x14(%ebp),%eax
  800bca:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800bcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bd0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bd4:	8b 45 10             	mov    0x10(%ebp),%eax
  800bd7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bde:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be2:	8b 45 08             	mov    0x8(%ebp),%eax
  800be5:	89 04 24             	mov    %eax,(%esp)
  800be8:	e8 74 ff ff ff       	call   800b61 <vsnprintf>
  800bed:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bf3:	c9                   	leave  
  800bf4:	c3                   	ret    

00800bf5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800bfb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c02:	eb 08                	jmp    800c0c <strlen+0x17>
		n++;
  800c04:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c08:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0f:	0f b6 00             	movzbl (%eax),%eax
  800c12:	84 c0                	test   %al,%al
  800c14:	75 ee                	jne    800c04 <strlen+0xf>
		n++;
	return n;
  800c16:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c19:	c9                   	leave  
  800c1a:	c3                   	ret    

00800c1b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c21:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c28:	eb 0c                	jmp    800c36 <strnlen+0x1b>
		n++;
  800c2a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c2e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c32:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800c36:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c3a:	74 0a                	je     800c46 <strnlen+0x2b>
  800c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3f:	0f b6 00             	movzbl (%eax),%eax
  800c42:	84 c0                	test   %al,%al
  800c44:	75 e4                	jne    800c2a <strnlen+0xf>
		n++;
	return n;
  800c46:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c49:	c9                   	leave  
  800c4a:	c3                   	ret    

00800c4b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c51:	8b 45 08             	mov    0x8(%ebp),%eax
  800c54:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c57:	90                   	nop
  800c58:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5b:	8d 50 01             	lea    0x1(%eax),%edx
  800c5e:	89 55 08             	mov    %edx,0x8(%ebp)
  800c61:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c64:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c67:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800c6a:	0f b6 12             	movzbl (%edx),%edx
  800c6d:	88 10                	mov    %dl,(%eax)
  800c6f:	0f b6 00             	movzbl (%eax),%eax
  800c72:	84 c0                	test   %al,%al
  800c74:	75 e2                	jne    800c58 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800c76:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c79:	c9                   	leave  
  800c7a:	c3                   	ret    

00800c7b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800c81:	8b 45 08             	mov    0x8(%ebp),%eax
  800c84:	89 04 24             	mov    %eax,(%esp)
  800c87:	e8 69 ff ff ff       	call   800bf5 <strlen>
  800c8c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800c8f:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800c92:	8b 45 08             	mov    0x8(%ebp),%eax
  800c95:	01 c2                	add    %eax,%edx
  800c97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c9e:	89 14 24             	mov    %edx,(%esp)
  800ca1:	e8 a5 ff ff ff       	call   800c4b <strcpy>
	return dst;
  800ca6:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ca9:	c9                   	leave  
  800caa:	c3                   	ret    

00800cab <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800cb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb4:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800cb7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800cbe:	eb 23                	jmp    800ce3 <strncpy+0x38>
		*dst++ = *src;
  800cc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc3:	8d 50 01             	lea    0x1(%eax),%edx
  800cc6:	89 55 08             	mov    %edx,0x8(%ebp)
  800cc9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ccc:	0f b6 12             	movzbl (%edx),%edx
  800ccf:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800cd1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd4:	0f b6 00             	movzbl (%eax),%eax
  800cd7:	84 c0                	test   %al,%al
  800cd9:	74 04                	je     800cdf <strncpy+0x34>
			src++;
  800cdb:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cdf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800ce3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ce6:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ce9:	72 d5                	jb     800cc0 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800ceb:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800cee:	c9                   	leave  
  800cef:	c3                   	ret    

00800cf0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800cf6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf9:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800cfc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d00:	74 33                	je     800d35 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d02:	eb 17                	jmp    800d1b <strlcpy+0x2b>
			*dst++ = *src++;
  800d04:	8b 45 08             	mov    0x8(%ebp),%eax
  800d07:	8d 50 01             	lea    0x1(%eax),%edx
  800d0a:	89 55 08             	mov    %edx,0x8(%ebp)
  800d0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d10:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d13:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d16:	0f b6 12             	movzbl (%edx),%edx
  800d19:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d1b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d1f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d23:	74 0a                	je     800d2f <strlcpy+0x3f>
  800d25:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d28:	0f b6 00             	movzbl (%eax),%eax
  800d2b:	84 c0                	test   %al,%al
  800d2d:	75 d5                	jne    800d04 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800d2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d32:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d35:	8b 55 08             	mov    0x8(%ebp),%edx
  800d38:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d3b:	29 c2                	sub    %eax,%edx
  800d3d:	89 d0                	mov    %edx,%eax
}
  800d3f:	c9                   	leave  
  800d40:	c3                   	ret    

00800d41 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d44:	eb 08                	jmp    800d4e <strcmp+0xd>
		p++, q++;
  800d46:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d4a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d51:	0f b6 00             	movzbl (%eax),%eax
  800d54:	84 c0                	test   %al,%al
  800d56:	74 10                	je     800d68 <strcmp+0x27>
  800d58:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5b:	0f b6 10             	movzbl (%eax),%edx
  800d5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d61:	0f b6 00             	movzbl (%eax),%eax
  800d64:	38 c2                	cmp    %al,%dl
  800d66:	74 de                	je     800d46 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d68:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6b:	0f b6 00             	movzbl (%eax),%eax
  800d6e:	0f b6 d0             	movzbl %al,%edx
  800d71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d74:	0f b6 00             	movzbl (%eax),%eax
  800d77:	0f b6 c0             	movzbl %al,%eax
  800d7a:	29 c2                	sub    %eax,%edx
  800d7c:	89 d0                	mov    %edx,%eax
}
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    

00800d80 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800d83:	eb 0c                	jmp    800d91 <strncmp+0x11>
		n--, p++, q++;
  800d85:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d89:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d8d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d91:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d95:	74 1a                	je     800db1 <strncmp+0x31>
  800d97:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9a:	0f b6 00             	movzbl (%eax),%eax
  800d9d:	84 c0                	test   %al,%al
  800d9f:	74 10                	je     800db1 <strncmp+0x31>
  800da1:	8b 45 08             	mov    0x8(%ebp),%eax
  800da4:	0f b6 10             	movzbl (%eax),%edx
  800da7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800daa:	0f b6 00             	movzbl (%eax),%eax
  800dad:	38 c2                	cmp    %al,%dl
  800daf:	74 d4                	je     800d85 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800db1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800db5:	75 07                	jne    800dbe <strncmp+0x3e>
		return 0;
  800db7:	b8 00 00 00 00       	mov    $0x0,%eax
  800dbc:	eb 16                	jmp    800dd4 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc1:	0f b6 00             	movzbl (%eax),%eax
  800dc4:	0f b6 d0             	movzbl %al,%edx
  800dc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dca:	0f b6 00             	movzbl (%eax),%eax
  800dcd:	0f b6 c0             	movzbl %al,%eax
  800dd0:	29 c2                	sub    %eax,%edx
  800dd2:	89 d0                	mov    %edx,%eax
}
  800dd4:	5d                   	pop    %ebp
  800dd5:	c3                   	ret    

00800dd6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
  800dd9:	83 ec 04             	sub    $0x4,%esp
  800ddc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ddf:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800de2:	eb 14                	jmp    800df8 <strchr+0x22>
		if (*s == c)
  800de4:	8b 45 08             	mov    0x8(%ebp),%eax
  800de7:	0f b6 00             	movzbl (%eax),%eax
  800dea:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800ded:	75 05                	jne    800df4 <strchr+0x1e>
			return (char *) s;
  800def:	8b 45 08             	mov    0x8(%ebp),%eax
  800df2:	eb 13                	jmp    800e07 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800df4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800df8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfb:	0f b6 00             	movzbl (%eax),%eax
  800dfe:	84 c0                	test   %al,%al
  800e00:	75 e2                	jne    800de4 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e02:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e07:	c9                   	leave  
  800e08:	c3                   	ret    

00800e09 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	83 ec 04             	sub    $0x4,%esp
  800e0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e12:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e15:	eb 11                	jmp    800e28 <strfind+0x1f>
		if (*s == c)
  800e17:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1a:	0f b6 00             	movzbl (%eax),%eax
  800e1d:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e20:	75 02                	jne    800e24 <strfind+0x1b>
			break;
  800e22:	eb 0e                	jmp    800e32 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e24:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e28:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2b:	0f b6 00             	movzbl (%eax),%eax
  800e2e:	84 c0                	test   %al,%al
  800e30:	75 e5                	jne    800e17 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800e32:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e35:	c9                   	leave  
  800e36:	c3                   	ret    

00800e37 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e3b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e3f:	75 05                	jne    800e46 <memset+0xf>
		return v;
  800e41:	8b 45 08             	mov    0x8(%ebp),%eax
  800e44:	eb 5c                	jmp    800ea2 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e46:	8b 45 08             	mov    0x8(%ebp),%eax
  800e49:	83 e0 03             	and    $0x3,%eax
  800e4c:	85 c0                	test   %eax,%eax
  800e4e:	75 41                	jne    800e91 <memset+0x5a>
  800e50:	8b 45 10             	mov    0x10(%ebp),%eax
  800e53:	83 e0 03             	and    $0x3,%eax
  800e56:	85 c0                	test   %eax,%eax
  800e58:	75 37                	jne    800e91 <memset+0x5a>
		c &= 0xFF;
  800e5a:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e64:	c1 e0 18             	shl    $0x18,%eax
  800e67:	89 c2                	mov    %eax,%edx
  800e69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6c:	c1 e0 10             	shl    $0x10,%eax
  800e6f:	09 c2                	or     %eax,%edx
  800e71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e74:	c1 e0 08             	shl    $0x8,%eax
  800e77:	09 d0                	or     %edx,%eax
  800e79:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e7c:	8b 45 10             	mov    0x10(%ebp),%eax
  800e7f:	c1 e8 02             	shr    $0x2,%eax
  800e82:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e84:	8b 55 08             	mov    0x8(%ebp),%edx
  800e87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8a:	89 d7                	mov    %edx,%edi
  800e8c:	fc                   	cld    
  800e8d:	f3 ab                	rep stos %eax,%es:(%edi)
  800e8f:	eb 0e                	jmp    800e9f <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e91:	8b 55 08             	mov    0x8(%ebp),%edx
  800e94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e97:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e9a:	89 d7                	mov    %edx,%edi
  800e9c:	fc                   	cld    
  800e9d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800e9f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ea2:	5f                   	pop    %edi
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    

00800ea5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	57                   	push   %edi
  800ea9:	56                   	push   %esi
  800eaa:	53                   	push   %ebx
  800eab:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800eae:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eb1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800eb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb7:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800eba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ebd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ec0:	73 6d                	jae    800f2f <memmove+0x8a>
  800ec2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ec5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ec8:	01 d0                	add    %edx,%eax
  800eca:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ecd:	76 60                	jbe    800f2f <memmove+0x8a>
		s += n;
  800ecf:	8b 45 10             	mov    0x10(%ebp),%eax
  800ed2:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800ed5:	8b 45 10             	mov    0x10(%ebp),%eax
  800ed8:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800edb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ede:	83 e0 03             	and    $0x3,%eax
  800ee1:	85 c0                	test   %eax,%eax
  800ee3:	75 2f                	jne    800f14 <memmove+0x6f>
  800ee5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ee8:	83 e0 03             	and    $0x3,%eax
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	75 25                	jne    800f14 <memmove+0x6f>
  800eef:	8b 45 10             	mov    0x10(%ebp),%eax
  800ef2:	83 e0 03             	and    $0x3,%eax
  800ef5:	85 c0                	test   %eax,%eax
  800ef7:	75 1b                	jne    800f14 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ef9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800efc:	83 e8 04             	sub    $0x4,%eax
  800eff:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f02:	83 ea 04             	sub    $0x4,%edx
  800f05:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f08:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f0b:	89 c7                	mov    %eax,%edi
  800f0d:	89 d6                	mov    %edx,%esi
  800f0f:	fd                   	std    
  800f10:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f12:	eb 18                	jmp    800f2c <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f14:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f17:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f1d:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f20:	8b 45 10             	mov    0x10(%ebp),%eax
  800f23:	89 d7                	mov    %edx,%edi
  800f25:	89 de                	mov    %ebx,%esi
  800f27:	89 c1                	mov    %eax,%ecx
  800f29:	fd                   	std    
  800f2a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f2c:	fc                   	cld    
  800f2d:	eb 45                	jmp    800f74 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f32:	83 e0 03             	and    $0x3,%eax
  800f35:	85 c0                	test   %eax,%eax
  800f37:	75 2b                	jne    800f64 <memmove+0xbf>
  800f39:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f3c:	83 e0 03             	and    $0x3,%eax
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	75 21                	jne    800f64 <memmove+0xbf>
  800f43:	8b 45 10             	mov    0x10(%ebp),%eax
  800f46:	83 e0 03             	and    $0x3,%eax
  800f49:	85 c0                	test   %eax,%eax
  800f4b:	75 17                	jne    800f64 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f4d:	8b 45 10             	mov    0x10(%ebp),%eax
  800f50:	c1 e8 02             	shr    $0x2,%eax
  800f53:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f55:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f58:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f5b:	89 c7                	mov    %eax,%edi
  800f5d:	89 d6                	mov    %edx,%esi
  800f5f:	fc                   	cld    
  800f60:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f62:	eb 10                	jmp    800f74 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f64:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f67:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f6a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f6d:	89 c7                	mov    %eax,%edi
  800f6f:	89 d6                	mov    %edx,%esi
  800f71:	fc                   	cld    
  800f72:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800f74:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f77:	83 c4 10             	add    $0x10,%esp
  800f7a:	5b                   	pop    %ebx
  800f7b:	5e                   	pop    %esi
  800f7c:	5f                   	pop    %edi
  800f7d:	5d                   	pop    %ebp
  800f7e:	c3                   	ret    

00800f7f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f85:	8b 45 10             	mov    0x10(%ebp),%eax
  800f88:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f93:	8b 45 08             	mov    0x8(%ebp),%eax
  800f96:	89 04 24             	mov    %eax,(%esp)
  800f99:	e8 07 ff ff ff       	call   800ea5 <memmove>
}
  800f9e:	c9                   	leave  
  800f9f:	c3                   	ret    

00800fa0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800fa6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa9:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800fac:	8b 45 0c             	mov    0xc(%ebp),%eax
  800faf:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800fb2:	eb 30                	jmp    800fe4 <memcmp+0x44>
		if (*s1 != *s2)
  800fb4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fb7:	0f b6 10             	movzbl (%eax),%edx
  800fba:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fbd:	0f b6 00             	movzbl (%eax),%eax
  800fc0:	38 c2                	cmp    %al,%dl
  800fc2:	74 18                	je     800fdc <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800fc4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fc7:	0f b6 00             	movzbl (%eax),%eax
  800fca:	0f b6 d0             	movzbl %al,%edx
  800fcd:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fd0:	0f b6 00             	movzbl (%eax),%eax
  800fd3:	0f b6 c0             	movzbl %al,%eax
  800fd6:	29 c2                	sub    %eax,%edx
  800fd8:	89 d0                	mov    %edx,%eax
  800fda:	eb 1a                	jmp    800ff6 <memcmp+0x56>
		s1++, s2++;
  800fdc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800fe0:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fe4:	8b 45 10             	mov    0x10(%ebp),%eax
  800fe7:	8d 50 ff             	lea    -0x1(%eax),%edx
  800fea:	89 55 10             	mov    %edx,0x10(%ebp)
  800fed:	85 c0                	test   %eax,%eax
  800fef:	75 c3                	jne    800fb4 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ff1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ff6:	c9                   	leave  
  800ff7:	c3                   	ret    

00800ff8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800ffe:	8b 45 10             	mov    0x10(%ebp),%eax
  801001:	8b 55 08             	mov    0x8(%ebp),%edx
  801004:	01 d0                	add    %edx,%eax
  801006:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801009:	eb 13                	jmp    80101e <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  80100b:	8b 45 08             	mov    0x8(%ebp),%eax
  80100e:	0f b6 10             	movzbl (%eax),%edx
  801011:	8b 45 0c             	mov    0xc(%ebp),%eax
  801014:	38 c2                	cmp    %al,%dl
  801016:	75 02                	jne    80101a <memfind+0x22>
			break;
  801018:	eb 0c                	jmp    801026 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80101a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80101e:	8b 45 08             	mov    0x8(%ebp),%eax
  801021:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  801024:	72 e5                	jb     80100b <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  801026:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801029:	c9                   	leave  
  80102a:	c3                   	ret    

0080102b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  801031:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  801038:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80103f:	eb 04                	jmp    801045 <strtol+0x1a>
		s++;
  801041:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801045:	8b 45 08             	mov    0x8(%ebp),%eax
  801048:	0f b6 00             	movzbl (%eax),%eax
  80104b:	3c 20                	cmp    $0x20,%al
  80104d:	74 f2                	je     801041 <strtol+0x16>
  80104f:	8b 45 08             	mov    0x8(%ebp),%eax
  801052:	0f b6 00             	movzbl (%eax),%eax
  801055:	3c 09                	cmp    $0x9,%al
  801057:	74 e8                	je     801041 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  801059:	8b 45 08             	mov    0x8(%ebp),%eax
  80105c:	0f b6 00             	movzbl (%eax),%eax
  80105f:	3c 2b                	cmp    $0x2b,%al
  801061:	75 06                	jne    801069 <strtol+0x3e>
		s++;
  801063:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801067:	eb 15                	jmp    80107e <strtol+0x53>
	else if (*s == '-')
  801069:	8b 45 08             	mov    0x8(%ebp),%eax
  80106c:	0f b6 00             	movzbl (%eax),%eax
  80106f:	3c 2d                	cmp    $0x2d,%al
  801071:	75 0b                	jne    80107e <strtol+0x53>
		s++, neg = 1;
  801073:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801077:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80107e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801082:	74 06                	je     80108a <strtol+0x5f>
  801084:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  801088:	75 24                	jne    8010ae <strtol+0x83>
  80108a:	8b 45 08             	mov    0x8(%ebp),%eax
  80108d:	0f b6 00             	movzbl (%eax),%eax
  801090:	3c 30                	cmp    $0x30,%al
  801092:	75 1a                	jne    8010ae <strtol+0x83>
  801094:	8b 45 08             	mov    0x8(%ebp),%eax
  801097:	83 c0 01             	add    $0x1,%eax
  80109a:	0f b6 00             	movzbl (%eax),%eax
  80109d:	3c 78                	cmp    $0x78,%al
  80109f:	75 0d                	jne    8010ae <strtol+0x83>
		s += 2, base = 16;
  8010a1:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8010a5:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8010ac:	eb 2a                	jmp    8010d8 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  8010ae:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010b2:	75 17                	jne    8010cb <strtol+0xa0>
  8010b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b7:	0f b6 00             	movzbl (%eax),%eax
  8010ba:	3c 30                	cmp    $0x30,%al
  8010bc:	75 0d                	jne    8010cb <strtol+0xa0>
		s++, base = 8;
  8010be:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010c2:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8010c9:	eb 0d                	jmp    8010d8 <strtol+0xad>
	else if (base == 0)
  8010cb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010cf:	75 07                	jne    8010d8 <strtol+0xad>
		base = 10;
  8010d1:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010db:	0f b6 00             	movzbl (%eax),%eax
  8010de:	3c 2f                	cmp    $0x2f,%al
  8010e0:	7e 1b                	jle    8010fd <strtol+0xd2>
  8010e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e5:	0f b6 00             	movzbl (%eax),%eax
  8010e8:	3c 39                	cmp    $0x39,%al
  8010ea:	7f 11                	jg     8010fd <strtol+0xd2>
			dig = *s - '0';
  8010ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ef:	0f b6 00             	movzbl (%eax),%eax
  8010f2:	0f be c0             	movsbl %al,%eax
  8010f5:	83 e8 30             	sub    $0x30,%eax
  8010f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8010fb:	eb 48                	jmp    801145 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  8010fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801100:	0f b6 00             	movzbl (%eax),%eax
  801103:	3c 60                	cmp    $0x60,%al
  801105:	7e 1b                	jle    801122 <strtol+0xf7>
  801107:	8b 45 08             	mov    0x8(%ebp),%eax
  80110a:	0f b6 00             	movzbl (%eax),%eax
  80110d:	3c 7a                	cmp    $0x7a,%al
  80110f:	7f 11                	jg     801122 <strtol+0xf7>
			dig = *s - 'a' + 10;
  801111:	8b 45 08             	mov    0x8(%ebp),%eax
  801114:	0f b6 00             	movzbl (%eax),%eax
  801117:	0f be c0             	movsbl %al,%eax
  80111a:	83 e8 57             	sub    $0x57,%eax
  80111d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801120:	eb 23                	jmp    801145 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  801122:	8b 45 08             	mov    0x8(%ebp),%eax
  801125:	0f b6 00             	movzbl (%eax),%eax
  801128:	3c 40                	cmp    $0x40,%al
  80112a:	7e 3d                	jle    801169 <strtol+0x13e>
  80112c:	8b 45 08             	mov    0x8(%ebp),%eax
  80112f:	0f b6 00             	movzbl (%eax),%eax
  801132:	3c 5a                	cmp    $0x5a,%al
  801134:	7f 33                	jg     801169 <strtol+0x13e>
			dig = *s - 'A' + 10;
  801136:	8b 45 08             	mov    0x8(%ebp),%eax
  801139:	0f b6 00             	movzbl (%eax),%eax
  80113c:	0f be c0             	movsbl %al,%eax
  80113f:	83 e8 37             	sub    $0x37,%eax
  801142:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  801145:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801148:	3b 45 10             	cmp    0x10(%ebp),%eax
  80114b:	7c 02                	jl     80114f <strtol+0x124>
			break;
  80114d:	eb 1a                	jmp    801169 <strtol+0x13e>
		s++, val = (val * base) + dig;
  80114f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801153:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801156:	0f af 45 10          	imul   0x10(%ebp),%eax
  80115a:	89 c2                	mov    %eax,%edx
  80115c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115f:	01 d0                	add    %edx,%eax
  801161:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  801164:	e9 6f ff ff ff       	jmp    8010d8 <strtol+0xad>

	if (endptr)
  801169:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80116d:	74 08                	je     801177 <strtol+0x14c>
		*endptr = (char *) s;
  80116f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801172:	8b 55 08             	mov    0x8(%ebp),%edx
  801175:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801177:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  80117b:	74 07                	je     801184 <strtol+0x159>
  80117d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801180:	f7 d8                	neg    %eax
  801182:	eb 03                	jmp    801187 <strtol+0x15c>
  801184:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  801187:	c9                   	leave  
  801188:	c3                   	ret    

00801189 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801189:	55                   	push   %ebp
  80118a:	89 e5                	mov    %esp,%ebp
  80118c:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  80118f:	a1 08 20 80 00       	mov    0x802008,%eax
  801194:	85 c0                	test   %eax,%eax
  801196:	75 5d                	jne    8011f5 <set_pgfault_handler+0x6c>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(thisenv->env_id, (void *)UXSTACKTOP-PGSIZE, PTE_U | PTE_W | PTE_P)) < 0) panic("set_pgfault_handler unable to allocate page");
  801198:	a1 04 20 80 00       	mov    0x802004,%eax
  80119d:	8b 40 48             	mov    0x48(%eax),%eax
  8011a0:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011a7:	00 
  8011a8:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011af:	ee 
  8011b0:	89 04 24             	mov    %eax,(%esp)
  8011b3:	e8 b7 f0 ff ff       	call   80026f <sys_page_alloc>
  8011b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8011bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8011bf:	79 1c                	jns    8011dd <set_pgfault_handler+0x54>
  8011c1:	c7 44 24 08 44 17 80 	movl   $0x801744,0x8(%esp)
  8011c8:	00 
  8011c9:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8011d0:	00 
  8011d1:	c7 04 24 70 17 80 00 	movl   $0x801770,(%esp)
  8011d8:	e8 86 f2 ff ff       	call   800463 <_panic>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8011dd:	a1 04 20 80 00       	mov    0x802004,%eax
  8011e2:	8b 40 48             	mov    0x48(%eax),%eax
  8011e5:	c7 44 24 04 3f 04 80 	movl   $0x80043f,0x4(%esp)
  8011ec:	00 
  8011ed:	89 04 24             	mov    %eax,(%esp)
  8011f0:	e8 85 f1 ff ff       	call   80037a <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8011f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f8:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8011fd:	c9                   	leave  
  8011fe:	c3                   	ret    
  8011ff:	90                   	nop

00801200 <__udivdi3>:
  801200:	55                   	push   %ebp
  801201:	57                   	push   %edi
  801202:	56                   	push   %esi
  801203:	83 ec 0c             	sub    $0xc,%esp
  801206:	8b 44 24 28          	mov    0x28(%esp),%eax
  80120a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80120e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801212:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801216:	85 c0                	test   %eax,%eax
  801218:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80121c:	89 ea                	mov    %ebp,%edx
  80121e:	89 0c 24             	mov    %ecx,(%esp)
  801221:	75 2d                	jne    801250 <__udivdi3+0x50>
  801223:	39 e9                	cmp    %ebp,%ecx
  801225:	77 61                	ja     801288 <__udivdi3+0x88>
  801227:	85 c9                	test   %ecx,%ecx
  801229:	89 ce                	mov    %ecx,%esi
  80122b:	75 0b                	jne    801238 <__udivdi3+0x38>
  80122d:	b8 01 00 00 00       	mov    $0x1,%eax
  801232:	31 d2                	xor    %edx,%edx
  801234:	f7 f1                	div    %ecx
  801236:	89 c6                	mov    %eax,%esi
  801238:	31 d2                	xor    %edx,%edx
  80123a:	89 e8                	mov    %ebp,%eax
  80123c:	f7 f6                	div    %esi
  80123e:	89 c5                	mov    %eax,%ebp
  801240:	89 f8                	mov    %edi,%eax
  801242:	f7 f6                	div    %esi
  801244:	89 ea                	mov    %ebp,%edx
  801246:	83 c4 0c             	add    $0xc,%esp
  801249:	5e                   	pop    %esi
  80124a:	5f                   	pop    %edi
  80124b:	5d                   	pop    %ebp
  80124c:	c3                   	ret    
  80124d:	8d 76 00             	lea    0x0(%esi),%esi
  801250:	39 e8                	cmp    %ebp,%eax
  801252:	77 24                	ja     801278 <__udivdi3+0x78>
  801254:	0f bd e8             	bsr    %eax,%ebp
  801257:	83 f5 1f             	xor    $0x1f,%ebp
  80125a:	75 3c                	jne    801298 <__udivdi3+0x98>
  80125c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801260:	39 34 24             	cmp    %esi,(%esp)
  801263:	0f 86 9f 00 00 00    	jbe    801308 <__udivdi3+0x108>
  801269:	39 d0                	cmp    %edx,%eax
  80126b:	0f 82 97 00 00 00    	jb     801308 <__udivdi3+0x108>
  801271:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801278:	31 d2                	xor    %edx,%edx
  80127a:	31 c0                	xor    %eax,%eax
  80127c:	83 c4 0c             	add    $0xc,%esp
  80127f:	5e                   	pop    %esi
  801280:	5f                   	pop    %edi
  801281:	5d                   	pop    %ebp
  801282:	c3                   	ret    
  801283:	90                   	nop
  801284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801288:	89 f8                	mov    %edi,%eax
  80128a:	f7 f1                	div    %ecx
  80128c:	31 d2                	xor    %edx,%edx
  80128e:	83 c4 0c             	add    $0xc,%esp
  801291:	5e                   	pop    %esi
  801292:	5f                   	pop    %edi
  801293:	5d                   	pop    %ebp
  801294:	c3                   	ret    
  801295:	8d 76 00             	lea    0x0(%esi),%esi
  801298:	89 e9                	mov    %ebp,%ecx
  80129a:	8b 3c 24             	mov    (%esp),%edi
  80129d:	d3 e0                	shl    %cl,%eax
  80129f:	89 c6                	mov    %eax,%esi
  8012a1:	b8 20 00 00 00       	mov    $0x20,%eax
  8012a6:	29 e8                	sub    %ebp,%eax
  8012a8:	89 c1                	mov    %eax,%ecx
  8012aa:	d3 ef                	shr    %cl,%edi
  8012ac:	89 e9                	mov    %ebp,%ecx
  8012ae:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8012b2:	8b 3c 24             	mov    (%esp),%edi
  8012b5:	09 74 24 08          	or     %esi,0x8(%esp)
  8012b9:	89 d6                	mov    %edx,%esi
  8012bb:	d3 e7                	shl    %cl,%edi
  8012bd:	89 c1                	mov    %eax,%ecx
  8012bf:	89 3c 24             	mov    %edi,(%esp)
  8012c2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012c6:	d3 ee                	shr    %cl,%esi
  8012c8:	89 e9                	mov    %ebp,%ecx
  8012ca:	d3 e2                	shl    %cl,%edx
  8012cc:	89 c1                	mov    %eax,%ecx
  8012ce:	d3 ef                	shr    %cl,%edi
  8012d0:	09 d7                	or     %edx,%edi
  8012d2:	89 f2                	mov    %esi,%edx
  8012d4:	89 f8                	mov    %edi,%eax
  8012d6:	f7 74 24 08          	divl   0x8(%esp)
  8012da:	89 d6                	mov    %edx,%esi
  8012dc:	89 c7                	mov    %eax,%edi
  8012de:	f7 24 24             	mull   (%esp)
  8012e1:	39 d6                	cmp    %edx,%esi
  8012e3:	89 14 24             	mov    %edx,(%esp)
  8012e6:	72 30                	jb     801318 <__udivdi3+0x118>
  8012e8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012ec:	89 e9                	mov    %ebp,%ecx
  8012ee:	d3 e2                	shl    %cl,%edx
  8012f0:	39 c2                	cmp    %eax,%edx
  8012f2:	73 05                	jae    8012f9 <__udivdi3+0xf9>
  8012f4:	3b 34 24             	cmp    (%esp),%esi
  8012f7:	74 1f                	je     801318 <__udivdi3+0x118>
  8012f9:	89 f8                	mov    %edi,%eax
  8012fb:	31 d2                	xor    %edx,%edx
  8012fd:	e9 7a ff ff ff       	jmp    80127c <__udivdi3+0x7c>
  801302:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801308:	31 d2                	xor    %edx,%edx
  80130a:	b8 01 00 00 00       	mov    $0x1,%eax
  80130f:	e9 68 ff ff ff       	jmp    80127c <__udivdi3+0x7c>
  801314:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801318:	8d 47 ff             	lea    -0x1(%edi),%eax
  80131b:	31 d2                	xor    %edx,%edx
  80131d:	83 c4 0c             	add    $0xc,%esp
  801320:	5e                   	pop    %esi
  801321:	5f                   	pop    %edi
  801322:	5d                   	pop    %ebp
  801323:	c3                   	ret    
  801324:	66 90                	xchg   %ax,%ax
  801326:	66 90                	xchg   %ax,%ax
  801328:	66 90                	xchg   %ax,%ax
  80132a:	66 90                	xchg   %ax,%ax
  80132c:	66 90                	xchg   %ax,%ax
  80132e:	66 90                	xchg   %ax,%ax

00801330 <__umoddi3>:
  801330:	55                   	push   %ebp
  801331:	57                   	push   %edi
  801332:	56                   	push   %esi
  801333:	83 ec 14             	sub    $0x14,%esp
  801336:	8b 44 24 28          	mov    0x28(%esp),%eax
  80133a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80133e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801342:	89 c7                	mov    %eax,%edi
  801344:	89 44 24 04          	mov    %eax,0x4(%esp)
  801348:	8b 44 24 30          	mov    0x30(%esp),%eax
  80134c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801350:	89 34 24             	mov    %esi,(%esp)
  801353:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801357:	85 c0                	test   %eax,%eax
  801359:	89 c2                	mov    %eax,%edx
  80135b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80135f:	75 17                	jne    801378 <__umoddi3+0x48>
  801361:	39 fe                	cmp    %edi,%esi
  801363:	76 4b                	jbe    8013b0 <__umoddi3+0x80>
  801365:	89 c8                	mov    %ecx,%eax
  801367:	89 fa                	mov    %edi,%edx
  801369:	f7 f6                	div    %esi
  80136b:	89 d0                	mov    %edx,%eax
  80136d:	31 d2                	xor    %edx,%edx
  80136f:	83 c4 14             	add    $0x14,%esp
  801372:	5e                   	pop    %esi
  801373:	5f                   	pop    %edi
  801374:	5d                   	pop    %ebp
  801375:	c3                   	ret    
  801376:	66 90                	xchg   %ax,%ax
  801378:	39 f8                	cmp    %edi,%eax
  80137a:	77 54                	ja     8013d0 <__umoddi3+0xa0>
  80137c:	0f bd e8             	bsr    %eax,%ebp
  80137f:	83 f5 1f             	xor    $0x1f,%ebp
  801382:	75 5c                	jne    8013e0 <__umoddi3+0xb0>
  801384:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801388:	39 3c 24             	cmp    %edi,(%esp)
  80138b:	0f 87 e7 00 00 00    	ja     801478 <__umoddi3+0x148>
  801391:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801395:	29 f1                	sub    %esi,%ecx
  801397:	19 c7                	sbb    %eax,%edi
  801399:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80139d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013a1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8013a5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8013a9:	83 c4 14             	add    $0x14,%esp
  8013ac:	5e                   	pop    %esi
  8013ad:	5f                   	pop    %edi
  8013ae:	5d                   	pop    %ebp
  8013af:	c3                   	ret    
  8013b0:	85 f6                	test   %esi,%esi
  8013b2:	89 f5                	mov    %esi,%ebp
  8013b4:	75 0b                	jne    8013c1 <__umoddi3+0x91>
  8013b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013bb:	31 d2                	xor    %edx,%edx
  8013bd:	f7 f6                	div    %esi
  8013bf:	89 c5                	mov    %eax,%ebp
  8013c1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8013c5:	31 d2                	xor    %edx,%edx
  8013c7:	f7 f5                	div    %ebp
  8013c9:	89 c8                	mov    %ecx,%eax
  8013cb:	f7 f5                	div    %ebp
  8013cd:	eb 9c                	jmp    80136b <__umoddi3+0x3b>
  8013cf:	90                   	nop
  8013d0:	89 c8                	mov    %ecx,%eax
  8013d2:	89 fa                	mov    %edi,%edx
  8013d4:	83 c4 14             	add    $0x14,%esp
  8013d7:	5e                   	pop    %esi
  8013d8:	5f                   	pop    %edi
  8013d9:	5d                   	pop    %ebp
  8013da:	c3                   	ret    
  8013db:	90                   	nop
  8013dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013e0:	8b 04 24             	mov    (%esp),%eax
  8013e3:	be 20 00 00 00       	mov    $0x20,%esi
  8013e8:	89 e9                	mov    %ebp,%ecx
  8013ea:	29 ee                	sub    %ebp,%esi
  8013ec:	d3 e2                	shl    %cl,%edx
  8013ee:	89 f1                	mov    %esi,%ecx
  8013f0:	d3 e8                	shr    %cl,%eax
  8013f2:	89 e9                	mov    %ebp,%ecx
  8013f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f8:	8b 04 24             	mov    (%esp),%eax
  8013fb:	09 54 24 04          	or     %edx,0x4(%esp)
  8013ff:	89 fa                	mov    %edi,%edx
  801401:	d3 e0                	shl    %cl,%eax
  801403:	89 f1                	mov    %esi,%ecx
  801405:	89 44 24 08          	mov    %eax,0x8(%esp)
  801409:	8b 44 24 10          	mov    0x10(%esp),%eax
  80140d:	d3 ea                	shr    %cl,%edx
  80140f:	89 e9                	mov    %ebp,%ecx
  801411:	d3 e7                	shl    %cl,%edi
  801413:	89 f1                	mov    %esi,%ecx
  801415:	d3 e8                	shr    %cl,%eax
  801417:	89 e9                	mov    %ebp,%ecx
  801419:	09 f8                	or     %edi,%eax
  80141b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80141f:	f7 74 24 04          	divl   0x4(%esp)
  801423:	d3 e7                	shl    %cl,%edi
  801425:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801429:	89 d7                	mov    %edx,%edi
  80142b:	f7 64 24 08          	mull   0x8(%esp)
  80142f:	39 d7                	cmp    %edx,%edi
  801431:	89 c1                	mov    %eax,%ecx
  801433:	89 14 24             	mov    %edx,(%esp)
  801436:	72 2c                	jb     801464 <__umoddi3+0x134>
  801438:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80143c:	72 22                	jb     801460 <__umoddi3+0x130>
  80143e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801442:	29 c8                	sub    %ecx,%eax
  801444:	19 d7                	sbb    %edx,%edi
  801446:	89 e9                	mov    %ebp,%ecx
  801448:	89 fa                	mov    %edi,%edx
  80144a:	d3 e8                	shr    %cl,%eax
  80144c:	89 f1                	mov    %esi,%ecx
  80144e:	d3 e2                	shl    %cl,%edx
  801450:	89 e9                	mov    %ebp,%ecx
  801452:	d3 ef                	shr    %cl,%edi
  801454:	09 d0                	or     %edx,%eax
  801456:	89 fa                	mov    %edi,%edx
  801458:	83 c4 14             	add    $0x14,%esp
  80145b:	5e                   	pop    %esi
  80145c:	5f                   	pop    %edi
  80145d:	5d                   	pop    %ebp
  80145e:	c3                   	ret    
  80145f:	90                   	nop
  801460:	39 d7                	cmp    %edx,%edi
  801462:	75 da                	jne    80143e <__umoddi3+0x10e>
  801464:	8b 14 24             	mov    (%esp),%edx
  801467:	89 c1                	mov    %eax,%ecx
  801469:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80146d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801471:	eb cb                	jmp    80143e <__umoddi3+0x10e>
  801473:	90                   	nop
  801474:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801478:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80147c:	0f 82 0f ff ff ff    	jb     801391 <__umoddi3+0x61>
  801482:	e9 1a ff ff ff       	jmp    8013a1 <__umoddi3+0x71>
