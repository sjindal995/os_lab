
obj/user/faultwritekernel:     file format elf32-i386


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
  80002c:	e8 12 00 00 00       	call   800043 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0xf0100000 = 0;
  800036:	b8 00 00 10 f0       	mov    $0xf0100000,%eax
  80003b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
  800041:	5d                   	pop    %ebp
  800042:	c3                   	ret    

00800043 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800043:	55                   	push   %ebp
  800044:	89 e5                	mov    %esp,%ebp
  800046:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800049:	e8 82 01 00 00       	call   8001d0 <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	c1 e0 02             	shl    $0x2,%eax
  800056:	89 c2                	mov    %eax,%edx
  800058:	c1 e2 05             	shl    $0x5,%edx
  80005b:	29 c2                	sub    %eax,%edx
  80005d:	89 d0                	mov    %edx,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80006d:	7e 0a                	jle    800079 <libmain+0x36>
		binaryname = argv[0];
  80006f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800072:	8b 00                	mov    (%eax),%eax
  800074:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800079:	8b 45 0c             	mov    0xc(%ebp),%eax
  80007c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800080:	8b 45 08             	mov    0x8(%ebp),%eax
  800083:	89 04 24             	mov    %eax,(%esp)
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 02 00 00 00       	call   800092 <exit>
}
  800090:	c9                   	leave  
  800091:	c3                   	ret    

00800092 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800098:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80009f:	e8 e9 00 00 00       	call   80018d <sys_env_destroy>
}
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	57                   	push   %edi
  8000aa:	56                   	push   %esi
  8000ab:	53                   	push   %ebx
  8000ac:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000af:	8b 45 08             	mov    0x8(%ebp),%eax
  8000b2:	8b 55 10             	mov    0x10(%ebp),%edx
  8000b5:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8000b8:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8000bb:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  8000be:	8b 75 20             	mov    0x20(%ebp),%esi
  8000c1:	cd 30                	int    $0x30
  8000c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000c6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8000ca:	74 30                	je     8000fc <syscall+0x56>
  8000cc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000d0:	7e 2a                	jle    8000fc <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000d5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8000dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000e0:	c7 44 24 08 ea 13 80 	movl   $0x8013ea,0x8(%esp)
  8000e7:	00 
  8000e8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000ef:	00 
  8000f0:	c7 04 24 07 14 80 00 	movl   $0x801407,(%esp)
  8000f7:	e8 2c 03 00 00       	call   800428 <_panic>

	return ret;
  8000fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8000ff:	83 c4 3c             	add    $0x3c,%esp
  800102:	5b                   	pop    %ebx
  800103:	5e                   	pop    %esi
  800104:	5f                   	pop    %edi
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80010d:	8b 45 08             	mov    0x8(%ebp),%eax
  800110:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800117:	00 
  800118:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80011f:	00 
  800120:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800127:	00 
  800128:	8b 55 0c             	mov    0xc(%ebp),%edx
  80012b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80012f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800133:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80013a:	00 
  80013b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800142:	e8 5f ff ff ff       	call   8000a6 <syscall>
}
  800147:	c9                   	leave  
  800148:	c3                   	ret    

00800149 <sys_cgetc>:

int
sys_cgetc(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80014f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800156:	00 
  800157:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80015e:	00 
  80015f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800166:	00 
  800167:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80016e:	00 
  80016f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800176:	00 
  800177:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80017e:	00 
  80017f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800186:	e8 1b ff ff ff       	call   8000a6 <syscall>
}
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    

0080018d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800193:	8b 45 08             	mov    0x8(%ebp),%eax
  800196:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80019d:	00 
  80019e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001a5:	00 
  8001a6:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001ad:	00 
  8001ae:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001b5:	00 
  8001b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ba:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001c1:	00 
  8001c2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8001c9:	e8 d8 fe ff ff       	call   8000a6 <syscall>
}
  8001ce:	c9                   	leave  
  8001cf:	c3                   	ret    

008001d0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8001d6:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001dd:	00 
  8001de:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001e5:	00 
  8001e6:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001ed:	00 
  8001ee:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001f5:	00 
  8001f6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001fd:	00 
  8001fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800205:	00 
  800206:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80020d:	e8 94 fe ff ff       	call   8000a6 <syscall>
}
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <sys_yield>:

void
sys_yield(void)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80021a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800221:	00 
  800222:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800229:	00 
  80022a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800231:	00 
  800232:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800239:	00 
  80023a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800241:	00 
  800242:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800249:	00 
  80024a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800251:	e8 50 fe ff ff       	call   8000a6 <syscall>
}
  800256:	c9                   	leave  
  800257:	c3                   	ret    

00800258 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
  80025b:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80025e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800261:	8b 55 0c             	mov    0xc(%ebp),%edx
  800264:	8b 45 08             	mov    0x8(%ebp),%eax
  800267:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80026e:	00 
  80026f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800276:	00 
  800277:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80027b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80027f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800283:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80028a:	00 
  80028b:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800292:	e8 0f fe ff ff       	call   8000a6 <syscall>
}
  800297:	c9                   	leave  
  800298:	c3                   	ret    

00800299 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8002a1:	8b 75 18             	mov    0x18(%ebp),%esi
  8002a4:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	89 74 24 18          	mov    %esi,0x18(%esp)
  8002b4:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002b8:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002bc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002cb:	00 
  8002cc:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8002d3:	e8 ce fd ff ff       	call   8000a6 <syscall>
}
  8002d8:	83 c4 20             	add    $0x20,%esp
  8002db:	5b                   	pop    %ebx
  8002dc:	5e                   	pop    %esi
  8002dd:	5d                   	pop    %ebp
  8002de:	c3                   	ret    

008002df <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8002e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002eb:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8002f2:	00 
  8002f3:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8002fa:	00 
  8002fb:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800302:	00 
  800303:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800307:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800312:	00 
  800313:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  80031a:	e8 87 fd ff ff       	call   8000a6 <syscall>
}
  80031f:	c9                   	leave  
  800320:	c3                   	ret    

00800321 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800321:	55                   	push   %ebp
  800322:	89 e5                	mov    %esp,%ebp
  800324:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800327:	8b 55 0c             	mov    0xc(%ebp),%edx
  80032a:	8b 45 08             	mov    0x8(%ebp),%eax
  80032d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800334:	00 
  800335:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80033c:	00 
  80033d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800344:	00 
  800345:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800349:	89 44 24 08          	mov    %eax,0x8(%esp)
  80034d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800354:	00 
  800355:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  80035c:	e8 45 fd ff ff       	call   8000a6 <syscall>
}
  800361:	c9                   	leave  
  800362:	c3                   	ret    

00800363 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800363:	55                   	push   %ebp
  800364:	89 e5                	mov    %esp,%ebp
  800366:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800369:	8b 55 0c             	mov    0xc(%ebp),%edx
  80036c:	8b 45 08             	mov    0x8(%ebp),%eax
  80036f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800376:	00 
  800377:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80037e:	00 
  80037f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800386:	00 
  800387:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80038b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80038f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800396:	00 
  800397:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  80039e:	e8 03 fd ff ff       	call   8000a6 <syscall>
}
  8003a3:	c9                   	leave  
  8003a4:	c3                   	ret    

008003a5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
  8003a8:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8003ab:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003ae:	8b 55 10             	mov    0x10(%ebp),%edx
  8003b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b4:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003bb:	00 
  8003bc:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8003c0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003c7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003cf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003d6:	00 
  8003d7:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8003de:	e8 c3 fc ff ff       	call   8000a6 <syscall>
}
  8003e3:	c9                   	leave  
  8003e4:	c3                   	ret    

008003e5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8003eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ee:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003f5:	00 
  8003f6:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8003fd:	00 
  8003fe:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800405:	00 
  800406:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80040d:	00 
  80040e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800412:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800419:	00 
  80041a:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  800421:	e8 80 fc ff ff       	call   8000a6 <syscall>
}
  800426:	c9                   	leave  
  800427:	c3                   	ret    

00800428 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	53                   	push   %ebx
  80042c:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80042f:	8d 45 14             	lea    0x14(%ebp),%eax
  800432:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800435:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80043b:	e8 90 fd ff ff       	call   8001d0 <sys_getenvid>
  800440:	8b 55 0c             	mov    0xc(%ebp),%edx
  800443:	89 54 24 10          	mov    %edx,0x10(%esp)
  800447:	8b 55 08             	mov    0x8(%ebp),%edx
  80044a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80044e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800452:	89 44 24 04          	mov    %eax,0x4(%esp)
  800456:	c7 04 24 18 14 80 00 	movl   $0x801418,(%esp)
  80045d:	e8 e1 00 00 00       	call   800543 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800462:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800465:	89 44 24 04          	mov    %eax,0x4(%esp)
  800469:	8b 45 10             	mov    0x10(%ebp),%eax
  80046c:	89 04 24             	mov    %eax,(%esp)
  80046f:	e8 6b 00 00 00       	call   8004df <vcprintf>
	cprintf("\n");
  800474:	c7 04 24 3b 14 80 00 	movl   $0x80143b,(%esp)
  80047b:	e8 c3 00 00 00       	call   800543 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800480:	cc                   	int3   
  800481:	eb fd                	jmp    800480 <_panic+0x58>

00800483 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800483:	55                   	push   %ebp
  800484:	89 e5                	mov    %esp,%ebp
  800486:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800489:	8b 45 0c             	mov    0xc(%ebp),%eax
  80048c:	8b 00                	mov    (%eax),%eax
  80048e:	8d 48 01             	lea    0x1(%eax),%ecx
  800491:	8b 55 0c             	mov    0xc(%ebp),%edx
  800494:	89 0a                	mov    %ecx,(%edx)
  800496:	8b 55 08             	mov    0x8(%ebp),%edx
  800499:	89 d1                	mov    %edx,%ecx
  80049b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80049e:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8004a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a5:	8b 00                	mov    (%eax),%eax
  8004a7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004ac:	75 20                	jne    8004ce <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8004ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b1:	8b 00                	mov    (%eax),%eax
  8004b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004b6:	83 c2 08             	add    $0x8,%edx
  8004b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004bd:	89 14 24             	mov    %edx,(%esp)
  8004c0:	e8 42 fc ff ff       	call   800107 <sys_cputs>
		b->idx = 0;
  8004c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8004ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d1:	8b 40 04             	mov    0x4(%eax),%eax
  8004d4:	8d 50 01             	lea    0x1(%eax),%edx
  8004d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004da:	89 50 04             	mov    %edx,0x4(%eax)
}
  8004dd:	c9                   	leave  
  8004de:	c3                   	ret    

008004df <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004df:	55                   	push   %ebp
  8004e0:	89 e5                	mov    %esp,%ebp
  8004e2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004e8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004ef:	00 00 00 
	b.cnt = 0;
  8004f2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004f9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800503:	8b 45 08             	mov    0x8(%ebp),%eax
  800506:	89 44 24 08          	mov    %eax,0x8(%esp)
  80050a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800510:	89 44 24 04          	mov    %eax,0x4(%esp)
  800514:	c7 04 24 83 04 80 00 	movl   $0x800483,(%esp)
  80051b:	e8 bd 01 00 00       	call   8006dd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800520:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800526:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800530:	83 c0 08             	add    $0x8,%eax
  800533:	89 04 24             	mov    %eax,(%esp)
  800536:	e8 cc fb ff ff       	call   800107 <sys_cputs>

	return b.cnt;
  80053b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800541:	c9                   	leave  
  800542:	c3                   	ret    

00800543 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800543:	55                   	push   %ebp
  800544:	89 e5                	mov    %esp,%ebp
  800546:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800549:	8d 45 0c             	lea    0xc(%ebp),%eax
  80054c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  80054f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800552:	89 44 24 04          	mov    %eax,0x4(%esp)
  800556:	8b 45 08             	mov    0x8(%ebp),%eax
  800559:	89 04 24             	mov    %eax,(%esp)
  80055c:	e8 7e ff ff ff       	call   8004df <vcprintf>
  800561:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800564:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800567:	c9                   	leave  
  800568:	c3                   	ret    

00800569 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800569:	55                   	push   %ebp
  80056a:	89 e5                	mov    %esp,%ebp
  80056c:	53                   	push   %ebx
  80056d:	83 ec 34             	sub    $0x34,%esp
  800570:	8b 45 10             	mov    0x10(%ebp),%eax
  800573:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80057c:	8b 45 18             	mov    0x18(%ebp),%eax
  80057f:	ba 00 00 00 00       	mov    $0x0,%edx
  800584:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800587:	77 72                	ja     8005fb <printnum+0x92>
  800589:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80058c:	72 05                	jb     800593 <printnum+0x2a>
  80058e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800591:	77 68                	ja     8005fb <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800593:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800596:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800599:	8b 45 18             	mov    0x18(%ebp),%eax
  80059c:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005a5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005af:	89 04 24             	mov    %eax,(%esp)
  8005b2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005b6:	e8 95 0b 00 00       	call   801150 <__udivdi3>
  8005bb:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8005be:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8005c2:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8005c6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8005c9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8005cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005d1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8005df:	89 04 24             	mov    %eax,(%esp)
  8005e2:	e8 82 ff ff ff       	call   800569 <printnum>
  8005e7:	eb 1c                	jmp    800605 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f0:	8b 45 20             	mov    0x20(%ebp),%eax
  8005f3:	89 04 24             	mov    %eax,(%esp)
  8005f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f9:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005fb:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8005ff:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800603:	7f e4                	jg     8005e9 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800605:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800608:	bb 00 00 00 00       	mov    $0x0,%ebx
  80060d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800610:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800613:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800617:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80061b:	89 04 24             	mov    %eax,(%esp)
  80061e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800622:	e8 59 0c 00 00       	call   801280 <__umoddi3>
  800627:	05 08 15 80 00       	add    $0x801508,%eax
  80062c:	0f b6 00             	movzbl (%eax),%eax
  80062f:	0f be c0             	movsbl %al,%eax
  800632:	8b 55 0c             	mov    0xc(%ebp),%edx
  800635:	89 54 24 04          	mov    %edx,0x4(%esp)
  800639:	89 04 24             	mov    %eax,(%esp)
  80063c:	8b 45 08             	mov    0x8(%ebp),%eax
  80063f:	ff d0                	call   *%eax
}
  800641:	83 c4 34             	add    $0x34,%esp
  800644:	5b                   	pop    %ebx
  800645:	5d                   	pop    %ebp
  800646:	c3                   	ret    

00800647 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800647:	55                   	push   %ebp
  800648:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80064a:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80064e:	7e 14                	jle    800664 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800650:	8b 45 08             	mov    0x8(%ebp),%eax
  800653:	8b 00                	mov    (%eax),%eax
  800655:	8d 48 08             	lea    0x8(%eax),%ecx
  800658:	8b 55 08             	mov    0x8(%ebp),%edx
  80065b:	89 0a                	mov    %ecx,(%edx)
  80065d:	8b 50 04             	mov    0x4(%eax),%edx
  800660:	8b 00                	mov    (%eax),%eax
  800662:	eb 30                	jmp    800694 <getuint+0x4d>
	else if (lflag)
  800664:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800668:	74 16                	je     800680 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  80066a:	8b 45 08             	mov    0x8(%ebp),%eax
  80066d:	8b 00                	mov    (%eax),%eax
  80066f:	8d 48 04             	lea    0x4(%eax),%ecx
  800672:	8b 55 08             	mov    0x8(%ebp),%edx
  800675:	89 0a                	mov    %ecx,(%edx)
  800677:	8b 00                	mov    (%eax),%eax
  800679:	ba 00 00 00 00       	mov    $0x0,%edx
  80067e:	eb 14                	jmp    800694 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800680:	8b 45 08             	mov    0x8(%ebp),%eax
  800683:	8b 00                	mov    (%eax),%eax
  800685:	8d 48 04             	lea    0x4(%eax),%ecx
  800688:	8b 55 08             	mov    0x8(%ebp),%edx
  80068b:	89 0a                	mov    %ecx,(%edx)
  80068d:	8b 00                	mov    (%eax),%eax
  80068f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800694:	5d                   	pop    %ebp
  800695:	c3                   	ret    

00800696 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800696:	55                   	push   %ebp
  800697:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800699:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80069d:	7e 14                	jle    8006b3 <getint+0x1d>
		return va_arg(*ap, long long);
  80069f:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a2:	8b 00                	mov    (%eax),%eax
  8006a4:	8d 48 08             	lea    0x8(%eax),%ecx
  8006a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8006aa:	89 0a                	mov    %ecx,(%edx)
  8006ac:	8b 50 04             	mov    0x4(%eax),%edx
  8006af:	8b 00                	mov    (%eax),%eax
  8006b1:	eb 28                	jmp    8006db <getint+0x45>
	else if (lflag)
  8006b3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006b7:	74 12                	je     8006cb <getint+0x35>
		return va_arg(*ap, long);
  8006b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bc:	8b 00                	mov    (%eax),%eax
  8006be:	8d 48 04             	lea    0x4(%eax),%ecx
  8006c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8006c4:	89 0a                	mov    %ecx,(%edx)
  8006c6:	8b 00                	mov    (%eax),%eax
  8006c8:	99                   	cltd   
  8006c9:	eb 10                	jmp    8006db <getint+0x45>
	else
		return va_arg(*ap, int);
  8006cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ce:	8b 00                	mov    (%eax),%eax
  8006d0:	8d 48 04             	lea    0x4(%eax),%ecx
  8006d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d6:	89 0a                	mov    %ecx,(%edx)
  8006d8:	8b 00                	mov    (%eax),%eax
  8006da:	99                   	cltd   
}
  8006db:	5d                   	pop    %ebp
  8006dc:	c3                   	ret    

008006dd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006dd:	55                   	push   %ebp
  8006de:	89 e5                	mov    %esp,%ebp
  8006e0:	56                   	push   %esi
  8006e1:	53                   	push   %ebx
  8006e2:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006e5:	eb 18                	jmp    8006ff <vprintfmt+0x22>
			if (ch == '\0')
  8006e7:	85 db                	test   %ebx,%ebx
  8006e9:	75 05                	jne    8006f0 <vprintfmt+0x13>
				return;
  8006eb:	e9 cc 03 00 00       	jmp    800abc <vprintfmt+0x3df>
			putch(ch, putdat);
  8006f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f7:	89 1c 24             	mov    %ebx,(%esp)
  8006fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fd:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006ff:	8b 45 10             	mov    0x10(%ebp),%eax
  800702:	8d 50 01             	lea    0x1(%eax),%edx
  800705:	89 55 10             	mov    %edx,0x10(%ebp)
  800708:	0f b6 00             	movzbl (%eax),%eax
  80070b:	0f b6 d8             	movzbl %al,%ebx
  80070e:	83 fb 25             	cmp    $0x25,%ebx
  800711:	75 d4                	jne    8006e7 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800713:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800717:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  80071e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800725:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80072c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800733:	8b 45 10             	mov    0x10(%ebp),%eax
  800736:	8d 50 01             	lea    0x1(%eax),%edx
  800739:	89 55 10             	mov    %edx,0x10(%ebp)
  80073c:	0f b6 00             	movzbl (%eax),%eax
  80073f:	0f b6 d8             	movzbl %al,%ebx
  800742:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800745:	83 f8 55             	cmp    $0x55,%eax
  800748:	0f 87 3d 03 00 00    	ja     800a8b <vprintfmt+0x3ae>
  80074e:	8b 04 85 2c 15 80 00 	mov    0x80152c(,%eax,4),%eax
  800755:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800757:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  80075b:	eb d6                	jmp    800733 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80075d:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800761:	eb d0                	jmp    800733 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800763:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  80076a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80076d:	89 d0                	mov    %edx,%eax
  80076f:	c1 e0 02             	shl    $0x2,%eax
  800772:	01 d0                	add    %edx,%eax
  800774:	01 c0                	add    %eax,%eax
  800776:	01 d8                	add    %ebx,%eax
  800778:	83 e8 30             	sub    $0x30,%eax
  80077b:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  80077e:	8b 45 10             	mov    0x10(%ebp),%eax
  800781:	0f b6 00             	movzbl (%eax),%eax
  800784:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800787:	83 fb 2f             	cmp    $0x2f,%ebx
  80078a:	7e 0b                	jle    800797 <vprintfmt+0xba>
  80078c:	83 fb 39             	cmp    $0x39,%ebx
  80078f:	7f 06                	jg     800797 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800791:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800795:	eb d3                	jmp    80076a <vprintfmt+0x8d>
			goto process_precision;
  800797:	eb 33                	jmp    8007cc <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800799:	8b 45 14             	mov    0x14(%ebp),%eax
  80079c:	8d 50 04             	lea    0x4(%eax),%edx
  80079f:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a2:	8b 00                	mov    (%eax),%eax
  8007a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8007a7:	eb 23                	jmp    8007cc <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8007a9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007ad:	79 0c                	jns    8007bb <vprintfmt+0xde>
				width = 0;
  8007af:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8007b6:	e9 78 ff ff ff       	jmp    800733 <vprintfmt+0x56>
  8007bb:	e9 73 ff ff ff       	jmp    800733 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8007c0:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8007c7:	e9 67 ff ff ff       	jmp    800733 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  8007cc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007d0:	79 12                	jns    8007e4 <vprintfmt+0x107>
				width = precision, precision = -1;
  8007d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007d8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8007df:	e9 4f ff ff ff       	jmp    800733 <vprintfmt+0x56>
  8007e4:	e9 4a ff ff ff       	jmp    800733 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007e9:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8007ed:	e9 41 ff ff ff       	jmp    800733 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f5:	8d 50 04             	lea    0x4(%eax),%edx
  8007f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fb:	8b 00                	mov    (%eax),%eax
  8007fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800800:	89 54 24 04          	mov    %edx,0x4(%esp)
  800804:	89 04 24             	mov    %eax,(%esp)
  800807:	8b 45 08             	mov    0x8(%ebp),%eax
  80080a:	ff d0                	call   *%eax
			break;
  80080c:	e9 a5 02 00 00       	jmp    800ab6 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800811:	8b 45 14             	mov    0x14(%ebp),%eax
  800814:	8d 50 04             	lea    0x4(%eax),%edx
  800817:	89 55 14             	mov    %edx,0x14(%ebp)
  80081a:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80081c:	85 db                	test   %ebx,%ebx
  80081e:	79 02                	jns    800822 <vprintfmt+0x145>
				err = -err;
  800820:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800822:	83 fb 09             	cmp    $0x9,%ebx
  800825:	7f 0b                	jg     800832 <vprintfmt+0x155>
  800827:	8b 34 9d e0 14 80 00 	mov    0x8014e0(,%ebx,4),%esi
  80082e:	85 f6                	test   %esi,%esi
  800830:	75 23                	jne    800855 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800832:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800836:	c7 44 24 08 19 15 80 	movl   $0x801519,0x8(%esp)
  80083d:	00 
  80083e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800841:	89 44 24 04          	mov    %eax,0x4(%esp)
  800845:	8b 45 08             	mov    0x8(%ebp),%eax
  800848:	89 04 24             	mov    %eax,(%esp)
  80084b:	e8 73 02 00 00       	call   800ac3 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800850:	e9 61 02 00 00       	jmp    800ab6 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800855:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800859:	c7 44 24 08 22 15 80 	movl   $0x801522,0x8(%esp)
  800860:	00 
  800861:	8b 45 0c             	mov    0xc(%ebp),%eax
  800864:	89 44 24 04          	mov    %eax,0x4(%esp)
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	89 04 24             	mov    %eax,(%esp)
  80086e:	e8 50 02 00 00       	call   800ac3 <printfmt>
			break;
  800873:	e9 3e 02 00 00       	jmp    800ab6 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800878:	8b 45 14             	mov    0x14(%ebp),%eax
  80087b:	8d 50 04             	lea    0x4(%eax),%edx
  80087e:	89 55 14             	mov    %edx,0x14(%ebp)
  800881:	8b 30                	mov    (%eax),%esi
  800883:	85 f6                	test   %esi,%esi
  800885:	75 05                	jne    80088c <vprintfmt+0x1af>
				p = "(null)";
  800887:	be 25 15 80 00       	mov    $0x801525,%esi
			if (width > 0 && padc != '-')
  80088c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800890:	7e 37                	jle    8008c9 <vprintfmt+0x1ec>
  800892:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800896:	74 31                	je     8008c9 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800898:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80089b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80089f:	89 34 24             	mov    %esi,(%esp)
  8008a2:	e8 39 03 00 00       	call   800be0 <strnlen>
  8008a7:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8008aa:	eb 17                	jmp    8008c3 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8008ac:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8008b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008b7:	89 04 24             	mov    %eax,(%esp)
  8008ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bd:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008bf:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008c3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008c7:	7f e3                	jg     8008ac <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008c9:	eb 38                	jmp    800903 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8008cb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008cf:	74 1f                	je     8008f0 <vprintfmt+0x213>
  8008d1:	83 fb 1f             	cmp    $0x1f,%ebx
  8008d4:	7e 05                	jle    8008db <vprintfmt+0x1fe>
  8008d6:	83 fb 7e             	cmp    $0x7e,%ebx
  8008d9:	7e 15                	jle    8008f0 <vprintfmt+0x213>
					putch('?', putdat);
  8008db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e2:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ec:	ff d0                	call   *%eax
  8008ee:	eb 0f                	jmp    8008ff <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8008f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f7:	89 1c 24             	mov    %ebx,(%esp)
  8008fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fd:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008ff:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800903:	89 f0                	mov    %esi,%eax
  800905:	8d 70 01             	lea    0x1(%eax),%esi
  800908:	0f b6 00             	movzbl (%eax),%eax
  80090b:	0f be d8             	movsbl %al,%ebx
  80090e:	85 db                	test   %ebx,%ebx
  800910:	74 10                	je     800922 <vprintfmt+0x245>
  800912:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800916:	78 b3                	js     8008cb <vprintfmt+0x1ee>
  800918:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80091c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800920:	79 a9                	jns    8008cb <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800922:	eb 17                	jmp    80093b <vprintfmt+0x25e>
				putch(' ', putdat);
  800924:	8b 45 0c             	mov    0xc(%ebp),%eax
  800927:	89 44 24 04          	mov    %eax,0x4(%esp)
  80092b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800932:	8b 45 08             	mov    0x8(%ebp),%eax
  800935:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800937:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80093b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80093f:	7f e3                	jg     800924 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800941:	e9 70 01 00 00       	jmp    800ab6 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800946:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800949:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094d:	8d 45 14             	lea    0x14(%ebp),%eax
  800950:	89 04 24             	mov    %eax,(%esp)
  800953:	e8 3e fd ff ff       	call   800696 <getint>
  800958:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80095b:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  80095e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800961:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800964:	85 d2                	test   %edx,%edx
  800966:	79 26                	jns    80098e <vprintfmt+0x2b1>
				putch('-', putdat);
  800968:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	ff d0                	call   *%eax
				num = -(long long) num;
  80097b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80097e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800981:	f7 d8                	neg    %eax
  800983:	83 d2 00             	adc    $0x0,%edx
  800986:	f7 da                	neg    %edx
  800988:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80098b:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  80098e:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800995:	e9 a8 00 00 00       	jmp    800a42 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80099a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80099d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a1:	8d 45 14             	lea    0x14(%ebp),%eax
  8009a4:	89 04 24             	mov    %eax,(%esp)
  8009a7:	e8 9b fc ff ff       	call   800647 <getuint>
  8009ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009af:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8009b2:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009b9:	e9 84 00 00 00       	jmp    800a42 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8009be:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c5:	8d 45 14             	lea    0x14(%ebp),%eax
  8009c8:	89 04 24             	mov    %eax,(%esp)
  8009cb:	e8 77 fc ff ff       	call   800647 <getuint>
  8009d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009d3:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  8009d6:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  8009dd:	eb 63                	jmp    800a42 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8009df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	ff d0                	call   *%eax
			putch('x', putdat);
  8009f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f9:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a05:	8b 45 14             	mov    0x14(%ebp),%eax
  800a08:	8d 50 04             	lea    0x4(%eax),%edx
  800a0b:	89 55 14             	mov    %edx,0x14(%ebp)
  800a0e:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a10:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a13:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a1a:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a21:	eb 1f                	jmp    800a42 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a23:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a26:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a2a:	8d 45 14             	lea    0x14(%ebp),%eax
  800a2d:	89 04 24             	mov    %eax,(%esp)
  800a30:	e8 12 fc ff ff       	call   800647 <getuint>
  800a35:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a38:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800a3b:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a42:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800a46:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a49:	89 54 24 18          	mov    %edx,0x18(%esp)
  800a4d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a50:	89 54 24 14          	mov    %edx,0x14(%esp)
  800a54:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a5b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a5e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a62:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a66:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a69:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a70:	89 04 24             	mov    %eax,(%esp)
  800a73:	e8 f1 fa ff ff       	call   800569 <printnum>
			break;
  800a78:	eb 3c                	jmp    800ab6 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a81:	89 1c 24             	mov    %ebx,(%esp)
  800a84:	8b 45 08             	mov    0x8(%ebp),%eax
  800a87:	ff d0                	call   *%eax
			break;
  800a89:	eb 2b                	jmp    800ab6 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a92:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a99:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9c:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a9e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800aa2:	eb 04                	jmp    800aa8 <vprintfmt+0x3cb>
  800aa4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800aa8:	8b 45 10             	mov    0x10(%ebp),%eax
  800aab:	83 e8 01             	sub    $0x1,%eax
  800aae:	0f b6 00             	movzbl (%eax),%eax
  800ab1:	3c 25                	cmp    $0x25,%al
  800ab3:	75 ef                	jne    800aa4 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800ab5:	90                   	nop
		}
	}
  800ab6:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800ab7:	e9 43 fc ff ff       	jmp    8006ff <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800abc:	83 c4 40             	add    $0x40,%esp
  800abf:	5b                   	pop    %ebx
  800ac0:	5e                   	pop    %esi
  800ac1:	5d                   	pop    %ebp
  800ac2:	c3                   	ret    

00800ac3 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800ac9:	8d 45 14             	lea    0x14(%ebp),%eax
  800acc:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ad2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ad6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ad9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800add:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae7:	89 04 24             	mov    %eax,(%esp)
  800aea:	e8 ee fb ff ff       	call   8006dd <vprintfmt>
	va_end(ap);
}
  800aef:	c9                   	leave  
  800af0:	c3                   	ret    

00800af1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800af4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af7:	8b 40 08             	mov    0x8(%eax),%eax
  800afa:	8d 50 01             	lea    0x1(%eax),%edx
  800afd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b00:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b03:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b06:	8b 10                	mov    (%eax),%edx
  800b08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0b:	8b 40 04             	mov    0x4(%eax),%eax
  800b0e:	39 c2                	cmp    %eax,%edx
  800b10:	73 12                	jae    800b24 <sprintputch+0x33>
		*b->buf++ = ch;
  800b12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b15:	8b 00                	mov    (%eax),%eax
  800b17:	8d 48 01             	lea    0x1(%eax),%ecx
  800b1a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b1d:	89 0a                	mov    %ecx,(%edx)
  800b1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b22:	88 10                	mov    %dl,(%eax)
}
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b35:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b38:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3b:	01 d0                	add    %edx,%eax
  800b3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b40:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b47:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b4b:	74 06                	je     800b53 <vsnprintf+0x2d>
  800b4d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b51:	7f 07                	jg     800b5a <vsnprintf+0x34>
		return -E_INVAL;
  800b53:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b58:	eb 2a                	jmp    800b84 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b5a:	8b 45 14             	mov    0x14(%ebp),%eax
  800b5d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b61:	8b 45 10             	mov    0x10(%ebp),%eax
  800b64:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b68:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b6f:	c7 04 24 f1 0a 80 00 	movl   $0x800af1,(%esp)
  800b76:	e8 62 fb ff ff       	call   8006dd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b7e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800b84:	c9                   	leave  
  800b85:	c3                   	ret    

00800b86 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b8c:	8d 45 14             	lea    0x14(%ebp),%eax
  800b8f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800b92:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b95:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b99:	8b 45 10             	mov    0x10(%ebp),%eax
  800b9c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ba0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ba7:	8b 45 08             	mov    0x8(%ebp),%eax
  800baa:	89 04 24             	mov    %eax,(%esp)
  800bad:	e8 74 ff ff ff       	call   800b26 <vsnprintf>
  800bb2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bb8:	c9                   	leave  
  800bb9:	c3                   	ret    

00800bba <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800bc0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800bc7:	eb 08                	jmp    800bd1 <strlen+0x17>
		n++;
  800bc9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800bcd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800bd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd4:	0f b6 00             	movzbl (%eax),%eax
  800bd7:	84 c0                	test   %al,%al
  800bd9:	75 ee                	jne    800bc9 <strlen+0xf>
		n++;
	return n;
  800bdb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800bde:	c9                   	leave  
  800bdf:	c3                   	ret    

00800be0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800be6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800bed:	eb 0c                	jmp    800bfb <strnlen+0x1b>
		n++;
  800bef:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bf3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800bf7:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800bfb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bff:	74 0a                	je     800c0b <strnlen+0x2b>
  800c01:	8b 45 08             	mov    0x8(%ebp),%eax
  800c04:	0f b6 00             	movzbl (%eax),%eax
  800c07:	84 c0                	test   %al,%al
  800c09:	75 e4                	jne    800bef <strnlen+0xf>
		n++;
	return n;
  800c0b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c0e:	c9                   	leave  
  800c0f:	c3                   	ret    

00800c10 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c16:	8b 45 08             	mov    0x8(%ebp),%eax
  800c19:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c1c:	90                   	nop
  800c1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c20:	8d 50 01             	lea    0x1(%eax),%edx
  800c23:	89 55 08             	mov    %edx,0x8(%ebp)
  800c26:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c29:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c2c:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800c2f:	0f b6 12             	movzbl (%edx),%edx
  800c32:	88 10                	mov    %dl,(%eax)
  800c34:	0f b6 00             	movzbl (%eax),%eax
  800c37:	84 c0                	test   %al,%al
  800c39:	75 e2                	jne    800c1d <strcpy+0xd>
		/* do nothing */;
	return ret;
  800c3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c3e:	c9                   	leave  
  800c3f:	c3                   	ret    

00800c40 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800c46:	8b 45 08             	mov    0x8(%ebp),%eax
  800c49:	89 04 24             	mov    %eax,(%esp)
  800c4c:	e8 69 ff ff ff       	call   800bba <strlen>
  800c51:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800c54:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800c57:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5a:	01 c2                	add    %eax,%edx
  800c5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c63:	89 14 24             	mov    %edx,(%esp)
  800c66:	e8 a5 ff ff ff       	call   800c10 <strcpy>
	return dst;
  800c6b:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c6e:	c9                   	leave  
  800c6f:	c3                   	ret    

00800c70 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800c76:	8b 45 08             	mov    0x8(%ebp),%eax
  800c79:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800c7c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c83:	eb 23                	jmp    800ca8 <strncpy+0x38>
		*dst++ = *src;
  800c85:	8b 45 08             	mov    0x8(%ebp),%eax
  800c88:	8d 50 01             	lea    0x1(%eax),%edx
  800c8b:	89 55 08             	mov    %edx,0x8(%ebp)
  800c8e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c91:	0f b6 12             	movzbl (%edx),%edx
  800c94:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800c96:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c99:	0f b6 00             	movzbl (%eax),%eax
  800c9c:	84 c0                	test   %al,%al
  800c9e:	74 04                	je     800ca4 <strncpy+0x34>
			src++;
  800ca0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ca4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800ca8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cab:	3b 45 10             	cmp    0x10(%ebp),%eax
  800cae:	72 d5                	jb     800c85 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800cb0:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800cb3:	c9                   	leave  
  800cb4:	c3                   	ret    

00800cb5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800cbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbe:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800cc1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cc5:	74 33                	je     800cfa <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800cc7:	eb 17                	jmp    800ce0 <strlcpy+0x2b>
			*dst++ = *src++;
  800cc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccc:	8d 50 01             	lea    0x1(%eax),%edx
  800ccf:	89 55 08             	mov    %edx,0x8(%ebp)
  800cd2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cd5:	8d 4a 01             	lea    0x1(%edx),%ecx
  800cd8:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800cdb:	0f b6 12             	movzbl (%edx),%edx
  800cde:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ce0:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ce4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ce8:	74 0a                	je     800cf4 <strlcpy+0x3f>
  800cea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ced:	0f b6 00             	movzbl (%eax),%eax
  800cf0:	84 c0                	test   %al,%al
  800cf2:	75 d5                	jne    800cc9 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d00:	29 c2                	sub    %eax,%edx
  800d02:	89 d0                	mov    %edx,%eax
}
  800d04:	c9                   	leave  
  800d05:	c3                   	ret    

00800d06 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d09:	eb 08                	jmp    800d13 <strcmp+0xd>
		p++, q++;
  800d0b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d0f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d13:	8b 45 08             	mov    0x8(%ebp),%eax
  800d16:	0f b6 00             	movzbl (%eax),%eax
  800d19:	84 c0                	test   %al,%al
  800d1b:	74 10                	je     800d2d <strcmp+0x27>
  800d1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d20:	0f b6 10             	movzbl (%eax),%edx
  800d23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d26:	0f b6 00             	movzbl (%eax),%eax
  800d29:	38 c2                	cmp    %al,%dl
  800d2b:	74 de                	je     800d0b <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d30:	0f b6 00             	movzbl (%eax),%eax
  800d33:	0f b6 d0             	movzbl %al,%edx
  800d36:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d39:	0f b6 00             	movzbl (%eax),%eax
  800d3c:	0f b6 c0             	movzbl %al,%eax
  800d3f:	29 c2                	sub    %eax,%edx
  800d41:	89 d0                	mov    %edx,%eax
}
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800d48:	eb 0c                	jmp    800d56 <strncmp+0x11>
		n--, p++, q++;
  800d4a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d4e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d52:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d56:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d5a:	74 1a                	je     800d76 <strncmp+0x31>
  800d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5f:	0f b6 00             	movzbl (%eax),%eax
  800d62:	84 c0                	test   %al,%al
  800d64:	74 10                	je     800d76 <strncmp+0x31>
  800d66:	8b 45 08             	mov    0x8(%ebp),%eax
  800d69:	0f b6 10             	movzbl (%eax),%edx
  800d6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d6f:	0f b6 00             	movzbl (%eax),%eax
  800d72:	38 c2                	cmp    %al,%dl
  800d74:	74 d4                	je     800d4a <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800d76:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d7a:	75 07                	jne    800d83 <strncmp+0x3e>
		return 0;
  800d7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d81:	eb 16                	jmp    800d99 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d83:	8b 45 08             	mov    0x8(%ebp),%eax
  800d86:	0f b6 00             	movzbl (%eax),%eax
  800d89:	0f b6 d0             	movzbl %al,%edx
  800d8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d8f:	0f b6 00             	movzbl (%eax),%eax
  800d92:	0f b6 c0             	movzbl %al,%eax
  800d95:	29 c2                	sub    %eax,%edx
  800d97:	89 d0                	mov    %edx,%eax
}
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	83 ec 04             	sub    $0x4,%esp
  800da1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da4:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800da7:	eb 14                	jmp    800dbd <strchr+0x22>
		if (*s == c)
  800da9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dac:	0f b6 00             	movzbl (%eax),%eax
  800daf:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800db2:	75 05                	jne    800db9 <strchr+0x1e>
			return (char *) s;
  800db4:	8b 45 08             	mov    0x8(%ebp),%eax
  800db7:	eb 13                	jmp    800dcc <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800db9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc0:	0f b6 00             	movzbl (%eax),%eax
  800dc3:	84 c0                	test   %al,%al
  800dc5:	75 e2                	jne    800da9 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800dc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dcc:	c9                   	leave  
  800dcd:	c3                   	ret    

00800dce <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	83 ec 04             	sub    $0x4,%esp
  800dd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd7:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800dda:	eb 11                	jmp    800ded <strfind+0x1f>
		if (*s == c)
  800ddc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddf:	0f b6 00             	movzbl (%eax),%eax
  800de2:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800de5:	75 02                	jne    800de9 <strfind+0x1b>
			break;
  800de7:	eb 0e                	jmp    800df7 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800de9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ded:	8b 45 08             	mov    0x8(%ebp),%eax
  800df0:	0f b6 00             	movzbl (%eax),%eax
  800df3:	84 c0                	test   %al,%al
  800df5:	75 e5                	jne    800ddc <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800df7:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800dfa:	c9                   	leave  
  800dfb:	c3                   	ret    

00800dfc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e00:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e04:	75 05                	jne    800e0b <memset+0xf>
		return v;
  800e06:	8b 45 08             	mov    0x8(%ebp),%eax
  800e09:	eb 5c                	jmp    800e67 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0e:	83 e0 03             	and    $0x3,%eax
  800e11:	85 c0                	test   %eax,%eax
  800e13:	75 41                	jne    800e56 <memset+0x5a>
  800e15:	8b 45 10             	mov    0x10(%ebp),%eax
  800e18:	83 e0 03             	and    $0x3,%eax
  800e1b:	85 c0                	test   %eax,%eax
  800e1d:	75 37                	jne    800e56 <memset+0x5a>
		c &= 0xFF;
  800e1f:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e26:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e29:	c1 e0 18             	shl    $0x18,%eax
  800e2c:	89 c2                	mov    %eax,%edx
  800e2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e31:	c1 e0 10             	shl    $0x10,%eax
  800e34:	09 c2                	or     %eax,%edx
  800e36:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e39:	c1 e0 08             	shl    $0x8,%eax
  800e3c:	09 d0                	or     %edx,%eax
  800e3e:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e41:	8b 45 10             	mov    0x10(%ebp),%eax
  800e44:	c1 e8 02             	shr    $0x2,%eax
  800e47:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e49:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e4f:	89 d7                	mov    %edx,%edi
  800e51:	fc                   	cld    
  800e52:	f3 ab                	rep stos %eax,%es:(%edi)
  800e54:	eb 0e                	jmp    800e64 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e56:	8b 55 08             	mov    0x8(%ebp),%edx
  800e59:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e5f:	89 d7                	mov    %edx,%edi
  800e61:	fc                   	cld    
  800e62:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800e64:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e67:	5f                   	pop    %edi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    

00800e6a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	57                   	push   %edi
  800e6e:	56                   	push   %esi
  800e6f:	53                   	push   %ebx
  800e70:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800e73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e76:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800e79:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7c:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800e7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e82:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800e85:	73 6d                	jae    800ef4 <memmove+0x8a>
  800e87:	8b 45 10             	mov    0x10(%ebp),%eax
  800e8a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e8d:	01 d0                	add    %edx,%eax
  800e8f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800e92:	76 60                	jbe    800ef4 <memmove+0x8a>
		s += n;
  800e94:	8b 45 10             	mov    0x10(%ebp),%eax
  800e97:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800e9a:	8b 45 10             	mov    0x10(%ebp),%eax
  800e9d:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ea0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ea3:	83 e0 03             	and    $0x3,%eax
  800ea6:	85 c0                	test   %eax,%eax
  800ea8:	75 2f                	jne    800ed9 <memmove+0x6f>
  800eaa:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ead:	83 e0 03             	and    $0x3,%eax
  800eb0:	85 c0                	test   %eax,%eax
  800eb2:	75 25                	jne    800ed9 <memmove+0x6f>
  800eb4:	8b 45 10             	mov    0x10(%ebp),%eax
  800eb7:	83 e0 03             	and    $0x3,%eax
  800eba:	85 c0                	test   %eax,%eax
  800ebc:	75 1b                	jne    800ed9 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ebe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ec1:	83 e8 04             	sub    $0x4,%eax
  800ec4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ec7:	83 ea 04             	sub    $0x4,%edx
  800eca:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ecd:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800ed0:	89 c7                	mov    %eax,%edi
  800ed2:	89 d6                	mov    %edx,%esi
  800ed4:	fd                   	std    
  800ed5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ed7:	eb 18                	jmp    800ef1 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ed9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800edc:	8d 50 ff             	lea    -0x1(%eax),%edx
  800edf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ee2:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ee5:	8b 45 10             	mov    0x10(%ebp),%eax
  800ee8:	89 d7                	mov    %edx,%edi
  800eea:	89 de                	mov    %ebx,%esi
  800eec:	89 c1                	mov    %eax,%ecx
  800eee:	fd                   	std    
  800eef:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ef1:	fc                   	cld    
  800ef2:	eb 45                	jmp    800f39 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ef4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ef7:	83 e0 03             	and    $0x3,%eax
  800efa:	85 c0                	test   %eax,%eax
  800efc:	75 2b                	jne    800f29 <memmove+0xbf>
  800efe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f01:	83 e0 03             	and    $0x3,%eax
  800f04:	85 c0                	test   %eax,%eax
  800f06:	75 21                	jne    800f29 <memmove+0xbf>
  800f08:	8b 45 10             	mov    0x10(%ebp),%eax
  800f0b:	83 e0 03             	and    $0x3,%eax
  800f0e:	85 c0                	test   %eax,%eax
  800f10:	75 17                	jne    800f29 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f12:	8b 45 10             	mov    0x10(%ebp),%eax
  800f15:	c1 e8 02             	shr    $0x2,%eax
  800f18:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f1a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f1d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f20:	89 c7                	mov    %eax,%edi
  800f22:	89 d6                	mov    %edx,%esi
  800f24:	fc                   	cld    
  800f25:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f27:	eb 10                	jmp    800f39 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f29:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f2c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f32:	89 c7                	mov    %eax,%edi
  800f34:	89 d6                	mov    %edx,%esi
  800f36:	fc                   	cld    
  800f37:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800f39:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f3c:	83 c4 10             	add    $0x10,%esp
  800f3f:	5b                   	pop    %ebx
  800f40:	5e                   	pop    %esi
  800f41:	5f                   	pop    %edi
  800f42:	5d                   	pop    %ebp
  800f43:	c3                   	ret    

00800f44 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f4a:	8b 45 10             	mov    0x10(%ebp),%eax
  800f4d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f54:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f58:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5b:	89 04 24             	mov    %eax,(%esp)
  800f5e:	e8 07 ff ff ff       	call   800e6a <memmove>
}
  800f63:	c9                   	leave  
  800f64:	c3                   	ret    

00800f65 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
  800f68:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800f6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800f71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f74:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800f77:	eb 30                	jmp    800fa9 <memcmp+0x44>
		if (*s1 != *s2)
  800f79:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f7c:	0f b6 10             	movzbl (%eax),%edx
  800f7f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f82:	0f b6 00             	movzbl (%eax),%eax
  800f85:	38 c2                	cmp    %al,%dl
  800f87:	74 18                	je     800fa1 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800f89:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f8c:	0f b6 00             	movzbl (%eax),%eax
  800f8f:	0f b6 d0             	movzbl %al,%edx
  800f92:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f95:	0f b6 00             	movzbl (%eax),%eax
  800f98:	0f b6 c0             	movzbl %al,%eax
  800f9b:	29 c2                	sub    %eax,%edx
  800f9d:	89 d0                	mov    %edx,%eax
  800f9f:	eb 1a                	jmp    800fbb <memcmp+0x56>
		s1++, s2++;
  800fa1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800fa5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fa9:	8b 45 10             	mov    0x10(%ebp),%eax
  800fac:	8d 50 ff             	lea    -0x1(%eax),%edx
  800faf:	89 55 10             	mov    %edx,0x10(%ebp)
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	75 c3                	jne    800f79 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fb6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fbb:	c9                   	leave  
  800fbc:	c3                   	ret    

00800fbd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fbd:	55                   	push   %ebp
  800fbe:	89 e5                	mov    %esp,%ebp
  800fc0:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800fc3:	8b 45 10             	mov    0x10(%ebp),%eax
  800fc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc9:	01 d0                	add    %edx,%eax
  800fcb:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800fce:	eb 13                	jmp    800fe3 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd3:	0f b6 10             	movzbl (%eax),%edx
  800fd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd9:	38 c2                	cmp    %al,%dl
  800fdb:	75 02                	jne    800fdf <memfind+0x22>
			break;
  800fdd:	eb 0c                	jmp    800feb <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fdf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800fe3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800fe9:	72 e5                	jb     800fd0 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  800feb:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800fee:	c9                   	leave  
  800fef:	c3                   	ret    

00800ff0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800ff6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800ffd:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801004:	eb 04                	jmp    80100a <strtol+0x1a>
		s++;
  801006:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80100a:	8b 45 08             	mov    0x8(%ebp),%eax
  80100d:	0f b6 00             	movzbl (%eax),%eax
  801010:	3c 20                	cmp    $0x20,%al
  801012:	74 f2                	je     801006 <strtol+0x16>
  801014:	8b 45 08             	mov    0x8(%ebp),%eax
  801017:	0f b6 00             	movzbl (%eax),%eax
  80101a:	3c 09                	cmp    $0x9,%al
  80101c:	74 e8                	je     801006 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  80101e:	8b 45 08             	mov    0x8(%ebp),%eax
  801021:	0f b6 00             	movzbl (%eax),%eax
  801024:	3c 2b                	cmp    $0x2b,%al
  801026:	75 06                	jne    80102e <strtol+0x3e>
		s++;
  801028:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80102c:	eb 15                	jmp    801043 <strtol+0x53>
	else if (*s == '-')
  80102e:	8b 45 08             	mov    0x8(%ebp),%eax
  801031:	0f b6 00             	movzbl (%eax),%eax
  801034:	3c 2d                	cmp    $0x2d,%al
  801036:	75 0b                	jne    801043 <strtol+0x53>
		s++, neg = 1;
  801038:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80103c:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801043:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801047:	74 06                	je     80104f <strtol+0x5f>
  801049:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  80104d:	75 24                	jne    801073 <strtol+0x83>
  80104f:	8b 45 08             	mov    0x8(%ebp),%eax
  801052:	0f b6 00             	movzbl (%eax),%eax
  801055:	3c 30                	cmp    $0x30,%al
  801057:	75 1a                	jne    801073 <strtol+0x83>
  801059:	8b 45 08             	mov    0x8(%ebp),%eax
  80105c:	83 c0 01             	add    $0x1,%eax
  80105f:	0f b6 00             	movzbl (%eax),%eax
  801062:	3c 78                	cmp    $0x78,%al
  801064:	75 0d                	jne    801073 <strtol+0x83>
		s += 2, base = 16;
  801066:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  80106a:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  801071:	eb 2a                	jmp    80109d <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  801073:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801077:	75 17                	jne    801090 <strtol+0xa0>
  801079:	8b 45 08             	mov    0x8(%ebp),%eax
  80107c:	0f b6 00             	movzbl (%eax),%eax
  80107f:	3c 30                	cmp    $0x30,%al
  801081:	75 0d                	jne    801090 <strtol+0xa0>
		s++, base = 8;
  801083:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801087:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  80108e:	eb 0d                	jmp    80109d <strtol+0xad>
	else if (base == 0)
  801090:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801094:	75 07                	jne    80109d <strtol+0xad>
		base = 10;
  801096:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80109d:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a0:	0f b6 00             	movzbl (%eax),%eax
  8010a3:	3c 2f                	cmp    $0x2f,%al
  8010a5:	7e 1b                	jle    8010c2 <strtol+0xd2>
  8010a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010aa:	0f b6 00             	movzbl (%eax),%eax
  8010ad:	3c 39                	cmp    $0x39,%al
  8010af:	7f 11                	jg     8010c2 <strtol+0xd2>
			dig = *s - '0';
  8010b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b4:	0f b6 00             	movzbl (%eax),%eax
  8010b7:	0f be c0             	movsbl %al,%eax
  8010ba:	83 e8 30             	sub    $0x30,%eax
  8010bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8010c0:	eb 48                	jmp    80110a <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  8010c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c5:	0f b6 00             	movzbl (%eax),%eax
  8010c8:	3c 60                	cmp    $0x60,%al
  8010ca:	7e 1b                	jle    8010e7 <strtol+0xf7>
  8010cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cf:	0f b6 00             	movzbl (%eax),%eax
  8010d2:	3c 7a                	cmp    $0x7a,%al
  8010d4:	7f 11                	jg     8010e7 <strtol+0xf7>
			dig = *s - 'a' + 10;
  8010d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d9:	0f b6 00             	movzbl (%eax),%eax
  8010dc:	0f be c0             	movsbl %al,%eax
  8010df:	83 e8 57             	sub    $0x57,%eax
  8010e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8010e5:	eb 23                	jmp    80110a <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  8010e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ea:	0f b6 00             	movzbl (%eax),%eax
  8010ed:	3c 40                	cmp    $0x40,%al
  8010ef:	7e 3d                	jle    80112e <strtol+0x13e>
  8010f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f4:	0f b6 00             	movzbl (%eax),%eax
  8010f7:	3c 5a                	cmp    $0x5a,%al
  8010f9:	7f 33                	jg     80112e <strtol+0x13e>
			dig = *s - 'A' + 10;
  8010fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fe:	0f b6 00             	movzbl (%eax),%eax
  801101:	0f be c0             	movsbl %al,%eax
  801104:	83 e8 37             	sub    $0x37,%eax
  801107:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  80110a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80110d:	3b 45 10             	cmp    0x10(%ebp),%eax
  801110:	7c 02                	jl     801114 <strtol+0x124>
			break;
  801112:	eb 1a                	jmp    80112e <strtol+0x13e>
		s++, val = (val * base) + dig;
  801114:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801118:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80111b:	0f af 45 10          	imul   0x10(%ebp),%eax
  80111f:	89 c2                	mov    %eax,%edx
  801121:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801124:	01 d0                	add    %edx,%eax
  801126:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  801129:	e9 6f ff ff ff       	jmp    80109d <strtol+0xad>

	if (endptr)
  80112e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801132:	74 08                	je     80113c <strtol+0x14c>
		*endptr = (char *) s;
  801134:	8b 45 0c             	mov    0xc(%ebp),%eax
  801137:	8b 55 08             	mov    0x8(%ebp),%edx
  80113a:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  80113c:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  801140:	74 07                	je     801149 <strtol+0x159>
  801142:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801145:	f7 d8                	neg    %eax
  801147:	eb 03                	jmp    80114c <strtol+0x15c>
  801149:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  80114c:	c9                   	leave  
  80114d:	c3                   	ret    
  80114e:	66 90                	xchg   %ax,%ax

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
