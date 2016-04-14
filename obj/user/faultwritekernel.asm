
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
  8000e0:	c7 44 24 08 4a 14 80 	movl   $0x80144a,0x8(%esp)
  8000e7:	00 
  8000e8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000ef:	00 
  8000f0:	c7 04 24 67 14 80 00 	movl   $0x801467,(%esp)
  8000f7:	e8 6f 03 00 00       	call   80046b <_panic>

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

00800428 <sys_exec>:

void sys_exec(char* buf){
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  80042e:	8b 45 08             	mov    0x8(%ebp),%eax
  800431:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800438:	00 
  800439:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800440:	00 
  800441:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800448:	00 
  800449:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800450:	00 
  800451:	89 44 24 08          	mov    %eax,0x8(%esp)
  800455:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80045c:	00 
  80045d:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  800464:	e8 3d fc ff ff       	call   8000a6 <syscall>
}
  800469:	c9                   	leave  
  80046a:	c3                   	ret    

0080046b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80046b:	55                   	push   %ebp
  80046c:	89 e5                	mov    %esp,%ebp
  80046e:	53                   	push   %ebx
  80046f:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  800472:	8d 45 14             	lea    0x14(%ebp),%eax
  800475:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800478:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80047e:	e8 4d fd ff ff       	call   8001d0 <sys_getenvid>
  800483:	8b 55 0c             	mov    0xc(%ebp),%edx
  800486:	89 54 24 10          	mov    %edx,0x10(%esp)
  80048a:	8b 55 08             	mov    0x8(%ebp),%edx
  80048d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800491:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800495:	89 44 24 04          	mov    %eax,0x4(%esp)
  800499:	c7 04 24 78 14 80 00 	movl   $0x801478,(%esp)
  8004a0:	e8 e1 00 00 00       	call   800586 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8004a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8004af:	89 04 24             	mov    %eax,(%esp)
  8004b2:	e8 6b 00 00 00       	call   800522 <vcprintf>
	cprintf("\n");
  8004b7:	c7 04 24 9b 14 80 00 	movl   $0x80149b,(%esp)
  8004be:	e8 c3 00 00 00       	call   800586 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004c3:	cc                   	int3   
  8004c4:	eb fd                	jmp    8004c3 <_panic+0x58>

008004c6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004c6:	55                   	push   %ebp
  8004c7:	89 e5                	mov    %esp,%ebp
  8004c9:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8004cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004cf:	8b 00                	mov    (%eax),%eax
  8004d1:	8d 48 01             	lea    0x1(%eax),%ecx
  8004d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004d7:	89 0a                	mov    %ecx,(%edx)
  8004d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8004dc:	89 d1                	mov    %edx,%ecx
  8004de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004e1:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8004e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e8:	8b 00                	mov    (%eax),%eax
  8004ea:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004ef:	75 20                	jne    800511 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8004f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f4:	8b 00                	mov    (%eax),%eax
  8004f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004f9:	83 c2 08             	add    $0x8,%edx
  8004fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800500:	89 14 24             	mov    %edx,(%esp)
  800503:	e8 ff fb ff ff       	call   800107 <sys_cputs>
		b->idx = 0;
  800508:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800511:	8b 45 0c             	mov    0xc(%ebp),%eax
  800514:	8b 40 04             	mov    0x4(%eax),%eax
  800517:	8d 50 01             	lea    0x1(%eax),%edx
  80051a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80051d:	89 50 04             	mov    %edx,0x4(%eax)
}
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80052b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800532:	00 00 00 
	b.cnt = 0;
  800535:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80053c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80053f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800542:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800546:	8b 45 08             	mov    0x8(%ebp),%eax
  800549:	89 44 24 08          	mov    %eax,0x8(%esp)
  80054d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800553:	89 44 24 04          	mov    %eax,0x4(%esp)
  800557:	c7 04 24 c6 04 80 00 	movl   $0x8004c6,(%esp)
  80055e:	e8 bd 01 00 00       	call   800720 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800563:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800569:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800573:	83 c0 08             	add    $0x8,%eax
  800576:	89 04 24             	mov    %eax,(%esp)
  800579:	e8 89 fb ff ff       	call   800107 <sys_cputs>

	return b.cnt;
  80057e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800584:	c9                   	leave  
  800585:	c3                   	ret    

00800586 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800586:	55                   	push   %ebp
  800587:	89 e5                	mov    %esp,%ebp
  800589:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80058c:	8d 45 0c             	lea    0xc(%ebp),%eax
  80058f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800592:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800595:	89 44 24 04          	mov    %eax,0x4(%esp)
  800599:	8b 45 08             	mov    0x8(%ebp),%eax
  80059c:	89 04 24             	mov    %eax,(%esp)
  80059f:	e8 7e ff ff ff       	call   800522 <vcprintf>
  8005a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8005a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8005aa:	c9                   	leave  
  8005ab:	c3                   	ret    

008005ac <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005ac:	55                   	push   %ebp
  8005ad:	89 e5                	mov    %esp,%ebp
  8005af:	53                   	push   %ebx
  8005b0:	83 ec 34             	sub    $0x34,%esp
  8005b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8005b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005bf:	8b 45 18             	mov    0x18(%ebp),%eax
  8005c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8005c7:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005ca:	77 72                	ja     80063e <printnum+0x92>
  8005cc:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005cf:	72 05                	jb     8005d6 <printnum+0x2a>
  8005d1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8005d4:	77 68                	ja     80063e <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005d6:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8005d9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8005dc:	8b 45 18             	mov    0x18(%ebp),%eax
  8005df:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005e8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005f2:	89 04 24             	mov    %eax,(%esp)
  8005f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005f9:	e8 a2 0b 00 00       	call   8011a0 <__udivdi3>
  8005fe:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800601:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800605:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800609:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80060c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800610:	89 44 24 08          	mov    %eax,0x8(%esp)
  800614:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800618:	8b 45 0c             	mov    0xc(%ebp),%eax
  80061b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061f:	8b 45 08             	mov    0x8(%ebp),%eax
  800622:	89 04 24             	mov    %eax,(%esp)
  800625:	e8 82 ff ff ff       	call   8005ac <printnum>
  80062a:	eb 1c                	jmp    800648 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80062c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80062f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800633:	8b 45 20             	mov    0x20(%ebp),%eax
  800636:	89 04 24             	mov    %eax,(%esp)
  800639:	8b 45 08             	mov    0x8(%ebp),%eax
  80063c:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80063e:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800642:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800646:	7f e4                	jg     80062c <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800648:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80064b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800650:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800653:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800656:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80065a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80065e:	89 04 24             	mov    %eax,(%esp)
  800661:	89 54 24 04          	mov    %edx,0x4(%esp)
  800665:	e8 66 0c 00 00       	call   8012d0 <__umoddi3>
  80066a:	05 68 15 80 00       	add    $0x801568,%eax
  80066f:	0f b6 00             	movzbl (%eax),%eax
  800672:	0f be c0             	movsbl %al,%eax
  800675:	8b 55 0c             	mov    0xc(%ebp),%edx
  800678:	89 54 24 04          	mov    %edx,0x4(%esp)
  80067c:	89 04 24             	mov    %eax,(%esp)
  80067f:	8b 45 08             	mov    0x8(%ebp),%eax
  800682:	ff d0                	call   *%eax
}
  800684:	83 c4 34             	add    $0x34,%esp
  800687:	5b                   	pop    %ebx
  800688:	5d                   	pop    %ebp
  800689:	c3                   	ret    

0080068a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80068a:	55                   	push   %ebp
  80068b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80068d:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800691:	7e 14                	jle    8006a7 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800693:	8b 45 08             	mov    0x8(%ebp),%eax
  800696:	8b 00                	mov    (%eax),%eax
  800698:	8d 48 08             	lea    0x8(%eax),%ecx
  80069b:	8b 55 08             	mov    0x8(%ebp),%edx
  80069e:	89 0a                	mov    %ecx,(%edx)
  8006a0:	8b 50 04             	mov    0x4(%eax),%edx
  8006a3:	8b 00                	mov    (%eax),%eax
  8006a5:	eb 30                	jmp    8006d7 <getuint+0x4d>
	else if (lflag)
  8006a7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006ab:	74 16                	je     8006c3 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8006ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b0:	8b 00                	mov    (%eax),%eax
  8006b2:	8d 48 04             	lea    0x4(%eax),%ecx
  8006b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8006b8:	89 0a                	mov    %ecx,(%edx)
  8006ba:	8b 00                	mov    (%eax),%eax
  8006bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c1:	eb 14                	jmp    8006d7 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8006c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c6:	8b 00                	mov    (%eax),%eax
  8006c8:	8d 48 04             	lea    0x4(%eax),%ecx
  8006cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8006ce:	89 0a                	mov    %ecx,(%edx)
  8006d0:	8b 00                	mov    (%eax),%eax
  8006d2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006d7:	5d                   	pop    %ebp
  8006d8:	c3                   	ret    

008006d9 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8006d9:	55                   	push   %ebp
  8006da:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006dc:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8006e0:	7e 14                	jle    8006f6 <getint+0x1d>
		return va_arg(*ap, long long);
  8006e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e5:	8b 00                	mov    (%eax),%eax
  8006e7:	8d 48 08             	lea    0x8(%eax),%ecx
  8006ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8006ed:	89 0a                	mov    %ecx,(%edx)
  8006ef:	8b 50 04             	mov    0x4(%eax),%edx
  8006f2:	8b 00                	mov    (%eax),%eax
  8006f4:	eb 28                	jmp    80071e <getint+0x45>
	else if (lflag)
  8006f6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006fa:	74 12                	je     80070e <getint+0x35>
		return va_arg(*ap, long);
  8006fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ff:	8b 00                	mov    (%eax),%eax
  800701:	8d 48 04             	lea    0x4(%eax),%ecx
  800704:	8b 55 08             	mov    0x8(%ebp),%edx
  800707:	89 0a                	mov    %ecx,(%edx)
  800709:	8b 00                	mov    (%eax),%eax
  80070b:	99                   	cltd   
  80070c:	eb 10                	jmp    80071e <getint+0x45>
	else
		return va_arg(*ap, int);
  80070e:	8b 45 08             	mov    0x8(%ebp),%eax
  800711:	8b 00                	mov    (%eax),%eax
  800713:	8d 48 04             	lea    0x4(%eax),%ecx
  800716:	8b 55 08             	mov    0x8(%ebp),%edx
  800719:	89 0a                	mov    %ecx,(%edx)
  80071b:	8b 00                	mov    (%eax),%eax
  80071d:	99                   	cltd   
}
  80071e:	5d                   	pop    %ebp
  80071f:	c3                   	ret    

00800720 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	56                   	push   %esi
  800724:	53                   	push   %ebx
  800725:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800728:	eb 18                	jmp    800742 <vprintfmt+0x22>
			if (ch == '\0')
  80072a:	85 db                	test   %ebx,%ebx
  80072c:	75 05                	jne    800733 <vprintfmt+0x13>
				return;
  80072e:	e9 cc 03 00 00       	jmp    800aff <vprintfmt+0x3df>
			putch(ch, putdat);
  800733:	8b 45 0c             	mov    0xc(%ebp),%eax
  800736:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073a:	89 1c 24             	mov    %ebx,(%esp)
  80073d:	8b 45 08             	mov    0x8(%ebp),%eax
  800740:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800742:	8b 45 10             	mov    0x10(%ebp),%eax
  800745:	8d 50 01             	lea    0x1(%eax),%edx
  800748:	89 55 10             	mov    %edx,0x10(%ebp)
  80074b:	0f b6 00             	movzbl (%eax),%eax
  80074e:	0f b6 d8             	movzbl %al,%ebx
  800751:	83 fb 25             	cmp    $0x25,%ebx
  800754:	75 d4                	jne    80072a <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800756:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80075a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800761:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800768:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80076f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800776:	8b 45 10             	mov    0x10(%ebp),%eax
  800779:	8d 50 01             	lea    0x1(%eax),%edx
  80077c:	89 55 10             	mov    %edx,0x10(%ebp)
  80077f:	0f b6 00             	movzbl (%eax),%eax
  800782:	0f b6 d8             	movzbl %al,%ebx
  800785:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800788:	83 f8 55             	cmp    $0x55,%eax
  80078b:	0f 87 3d 03 00 00    	ja     800ace <vprintfmt+0x3ae>
  800791:	8b 04 85 8c 15 80 00 	mov    0x80158c(,%eax,4),%eax
  800798:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  80079a:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  80079e:	eb d6                	jmp    800776 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8007a0:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8007a4:	eb d0                	jmp    800776 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007a6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8007ad:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007b0:	89 d0                	mov    %edx,%eax
  8007b2:	c1 e0 02             	shl    $0x2,%eax
  8007b5:	01 d0                	add    %edx,%eax
  8007b7:	01 c0                	add    %eax,%eax
  8007b9:	01 d8                	add    %ebx,%eax
  8007bb:	83 e8 30             	sub    $0x30,%eax
  8007be:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8007c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c4:	0f b6 00             	movzbl (%eax),%eax
  8007c7:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8007ca:	83 fb 2f             	cmp    $0x2f,%ebx
  8007cd:	7e 0b                	jle    8007da <vprintfmt+0xba>
  8007cf:	83 fb 39             	cmp    $0x39,%ebx
  8007d2:	7f 06                	jg     8007da <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007d4:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8007d8:	eb d3                	jmp    8007ad <vprintfmt+0x8d>
			goto process_precision;
  8007da:	eb 33                	jmp    80080f <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8007dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007df:	8d 50 04             	lea    0x4(%eax),%edx
  8007e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e5:	8b 00                	mov    (%eax),%eax
  8007e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8007ea:	eb 23                	jmp    80080f <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8007ec:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007f0:	79 0c                	jns    8007fe <vprintfmt+0xde>
				width = 0;
  8007f2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8007f9:	e9 78 ff ff ff       	jmp    800776 <vprintfmt+0x56>
  8007fe:	e9 73 ff ff ff       	jmp    800776 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800803:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80080a:	e9 67 ff ff ff       	jmp    800776 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80080f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800813:	79 12                	jns    800827 <vprintfmt+0x107>
				width = precision, precision = -1;
  800815:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800818:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80081b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800822:	e9 4f ff ff ff       	jmp    800776 <vprintfmt+0x56>
  800827:	e9 4a ff ff ff       	jmp    800776 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80082c:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800830:	e9 41 ff ff ff       	jmp    800776 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800835:	8b 45 14             	mov    0x14(%ebp),%eax
  800838:	8d 50 04             	lea    0x4(%eax),%edx
  80083b:	89 55 14             	mov    %edx,0x14(%ebp)
  80083e:	8b 00                	mov    (%eax),%eax
  800840:	8b 55 0c             	mov    0xc(%ebp),%edx
  800843:	89 54 24 04          	mov    %edx,0x4(%esp)
  800847:	89 04 24             	mov    %eax,(%esp)
  80084a:	8b 45 08             	mov    0x8(%ebp),%eax
  80084d:	ff d0                	call   *%eax
			break;
  80084f:	e9 a5 02 00 00       	jmp    800af9 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800854:	8b 45 14             	mov    0x14(%ebp),%eax
  800857:	8d 50 04             	lea    0x4(%eax),%edx
  80085a:	89 55 14             	mov    %edx,0x14(%ebp)
  80085d:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80085f:	85 db                	test   %ebx,%ebx
  800861:	79 02                	jns    800865 <vprintfmt+0x145>
				err = -err;
  800863:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800865:	83 fb 09             	cmp    $0x9,%ebx
  800868:	7f 0b                	jg     800875 <vprintfmt+0x155>
  80086a:	8b 34 9d 40 15 80 00 	mov    0x801540(,%ebx,4),%esi
  800871:	85 f6                	test   %esi,%esi
  800873:	75 23                	jne    800898 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800875:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800879:	c7 44 24 08 79 15 80 	movl   $0x801579,0x8(%esp)
  800880:	00 
  800881:	8b 45 0c             	mov    0xc(%ebp),%eax
  800884:	89 44 24 04          	mov    %eax,0x4(%esp)
  800888:	8b 45 08             	mov    0x8(%ebp),%eax
  80088b:	89 04 24             	mov    %eax,(%esp)
  80088e:	e8 73 02 00 00       	call   800b06 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800893:	e9 61 02 00 00       	jmp    800af9 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800898:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80089c:	c7 44 24 08 82 15 80 	movl   $0x801582,0x8(%esp)
  8008a3:	00 
  8008a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ae:	89 04 24             	mov    %eax,(%esp)
  8008b1:	e8 50 02 00 00       	call   800b06 <printfmt>
			break;
  8008b6:	e9 3e 02 00 00       	jmp    800af9 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008be:	8d 50 04             	lea    0x4(%eax),%edx
  8008c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c4:	8b 30                	mov    (%eax),%esi
  8008c6:	85 f6                	test   %esi,%esi
  8008c8:	75 05                	jne    8008cf <vprintfmt+0x1af>
				p = "(null)";
  8008ca:	be 85 15 80 00       	mov    $0x801585,%esi
			if (width > 0 && padc != '-')
  8008cf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008d3:	7e 37                	jle    80090c <vprintfmt+0x1ec>
  8008d5:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8008d9:	74 31                	je     80090c <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e2:	89 34 24             	mov    %esi,(%esp)
  8008e5:	e8 39 03 00 00       	call   800c23 <strnlen>
  8008ea:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8008ed:	eb 17                	jmp    800906 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8008ef:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8008f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008fa:	89 04 24             	mov    %eax,(%esp)
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800902:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800906:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80090a:	7f e3                	jg     8008ef <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80090c:	eb 38                	jmp    800946 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  80090e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800912:	74 1f                	je     800933 <vprintfmt+0x213>
  800914:	83 fb 1f             	cmp    $0x1f,%ebx
  800917:	7e 05                	jle    80091e <vprintfmt+0x1fe>
  800919:	83 fb 7e             	cmp    $0x7e,%ebx
  80091c:	7e 15                	jle    800933 <vprintfmt+0x213>
					putch('?', putdat);
  80091e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800921:	89 44 24 04          	mov    %eax,0x4(%esp)
  800925:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80092c:	8b 45 08             	mov    0x8(%ebp),%eax
  80092f:	ff d0                	call   *%eax
  800931:	eb 0f                	jmp    800942 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800933:	8b 45 0c             	mov    0xc(%ebp),%eax
  800936:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093a:	89 1c 24             	mov    %ebx,(%esp)
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800942:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800946:	89 f0                	mov    %esi,%eax
  800948:	8d 70 01             	lea    0x1(%eax),%esi
  80094b:	0f b6 00             	movzbl (%eax),%eax
  80094e:	0f be d8             	movsbl %al,%ebx
  800951:	85 db                	test   %ebx,%ebx
  800953:	74 10                	je     800965 <vprintfmt+0x245>
  800955:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800959:	78 b3                	js     80090e <vprintfmt+0x1ee>
  80095b:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80095f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800963:	79 a9                	jns    80090e <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800965:	eb 17                	jmp    80097e <vprintfmt+0x25e>
				putch(' ', putdat);
  800967:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80097a:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80097e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800982:	7f e3                	jg     800967 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800984:	e9 70 01 00 00       	jmp    800af9 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800989:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80098c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800990:	8d 45 14             	lea    0x14(%ebp),%eax
  800993:	89 04 24             	mov    %eax,(%esp)
  800996:	e8 3e fd ff ff       	call   8006d9 <getint>
  80099b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80099e:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8009a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009a7:	85 d2                	test   %edx,%edx
  8009a9:	79 26                	jns    8009d1 <vprintfmt+0x2b1>
				putch('-', putdat);
  8009ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b2:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bc:	ff d0                	call   *%eax
				num = -(long long) num;
  8009be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009c4:	f7 d8                	neg    %eax
  8009c6:	83 d2 00             	adc    $0x0,%edx
  8009c9:	f7 da                	neg    %edx
  8009cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009ce:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8009d1:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009d8:	e9 a8 00 00 00       	jmp    800a85 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e4:	8d 45 14             	lea    0x14(%ebp),%eax
  8009e7:	89 04 24             	mov    %eax,(%esp)
  8009ea:	e8 9b fc ff ff       	call   80068a <getuint>
  8009ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009f2:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8009f5:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009fc:	e9 84 00 00 00       	jmp    800a85 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a01:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a04:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a08:	8d 45 14             	lea    0x14(%ebp),%eax
  800a0b:	89 04 24             	mov    %eax,(%esp)
  800a0e:	e8 77 fc ff ff       	call   80068a <getuint>
  800a13:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a16:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800a19:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800a20:	eb 63                	jmp    800a85 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a25:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a29:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a30:	8b 45 08             	mov    0x8(%ebp),%eax
  800a33:	ff d0                	call   *%eax
			putch('x', putdat);
  800a35:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a38:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a3c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a43:	8b 45 08             	mov    0x8(%ebp),%eax
  800a46:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a48:	8b 45 14             	mov    0x14(%ebp),%eax
  800a4b:	8d 50 04             	lea    0x4(%eax),%edx
  800a4e:	89 55 14             	mov    %edx,0x14(%ebp)
  800a51:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a53:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a56:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a5d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a64:	eb 1f                	jmp    800a85 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a66:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a69:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a6d:	8d 45 14             	lea    0x14(%ebp),%eax
  800a70:	89 04 24             	mov    %eax,(%esp)
  800a73:	e8 12 fc ff ff       	call   80068a <getuint>
  800a78:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a7b:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800a7e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a85:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800a89:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a8c:	89 54 24 18          	mov    %edx,0x18(%esp)
  800a90:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a93:	89 54 24 14          	mov    %edx,0x14(%esp)
  800a97:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800aa1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aa5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800aa9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab3:	89 04 24             	mov    %eax,(%esp)
  800ab6:	e8 f1 fa ff ff       	call   8005ac <printnum>
			break;
  800abb:	eb 3c                	jmp    800af9 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800abd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac4:	89 1c 24             	mov    %ebx,(%esp)
  800ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aca:	ff d0                	call   *%eax
			break;
  800acc:	eb 2b                	jmp    800af9 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ace:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800adc:	8b 45 08             	mov    0x8(%ebp),%eax
  800adf:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ae1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ae5:	eb 04                	jmp    800aeb <vprintfmt+0x3cb>
  800ae7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800aeb:	8b 45 10             	mov    0x10(%ebp),%eax
  800aee:	83 e8 01             	sub    $0x1,%eax
  800af1:	0f b6 00             	movzbl (%eax),%eax
  800af4:	3c 25                	cmp    $0x25,%al
  800af6:	75 ef                	jne    800ae7 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800af8:	90                   	nop
		}
	}
  800af9:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800afa:	e9 43 fc ff ff       	jmp    800742 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800aff:	83 c4 40             	add    $0x40,%esp
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b0c:	8d 45 14             	lea    0x14(%ebp),%eax
  800b0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b15:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b19:	8b 45 10             	mov    0x10(%ebp),%eax
  800b1c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b20:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b23:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b27:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2a:	89 04 24             	mov    %eax,(%esp)
  800b2d:	e8 ee fb ff ff       	call   800720 <vprintfmt>
	va_end(ap);
}
  800b32:	c9                   	leave  
  800b33:	c3                   	ret    

00800b34 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800b37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3a:	8b 40 08             	mov    0x8(%eax),%eax
  800b3d:	8d 50 01             	lea    0x1(%eax),%edx
  800b40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b43:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b46:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b49:	8b 10                	mov    (%eax),%edx
  800b4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4e:	8b 40 04             	mov    0x4(%eax),%eax
  800b51:	39 c2                	cmp    %eax,%edx
  800b53:	73 12                	jae    800b67 <sprintputch+0x33>
		*b->buf++ = ch;
  800b55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b58:	8b 00                	mov    (%eax),%eax
  800b5a:	8d 48 01             	lea    0x1(%eax),%ecx
  800b5d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b60:	89 0a                	mov    %ecx,(%edx)
  800b62:	8b 55 08             	mov    0x8(%ebp),%edx
  800b65:	88 10                	mov    %dl,(%eax)
}
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b72:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b78:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7e:	01 d0                	add    %edx,%eax
  800b80:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b83:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b8a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b8e:	74 06                	je     800b96 <vsnprintf+0x2d>
  800b90:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b94:	7f 07                	jg     800b9d <vsnprintf+0x34>
		return -E_INVAL;
  800b96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b9b:	eb 2a                	jmp    800bc7 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b9d:	8b 45 14             	mov    0x14(%ebp),%eax
  800ba0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ba4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bab:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bae:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bb2:	c7 04 24 34 0b 80 00 	movl   $0x800b34,(%esp)
  800bb9:	e8 62 fb ff ff       	call   800720 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bbe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bc1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bc7:	c9                   	leave  
  800bc8:	c3                   	ret    

00800bc9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bcf:	8d 45 14             	lea    0x14(%ebp),%eax
  800bd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800bd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bd8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bdc:	8b 45 10             	mov    0x10(%ebp),%eax
  800bdf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800be3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bea:	8b 45 08             	mov    0x8(%ebp),%eax
  800bed:	89 04 24             	mov    %eax,(%esp)
  800bf0:	e8 74 ff ff ff       	call   800b69 <vsnprintf>
  800bf5:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bfb:	c9                   	leave  
  800bfc:	c3                   	ret    

00800bfd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800c03:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c0a:	eb 08                	jmp    800c14 <strlen+0x17>
		n++;
  800c0c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c10:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c14:	8b 45 08             	mov    0x8(%ebp),%eax
  800c17:	0f b6 00             	movzbl (%eax),%eax
  800c1a:	84 c0                	test   %al,%al
  800c1c:	75 ee                	jne    800c0c <strlen+0xf>
		n++;
	return n;
  800c1e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c21:	c9                   	leave  
  800c22:	c3                   	ret    

00800c23 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c29:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c30:	eb 0c                	jmp    800c3e <strnlen+0x1b>
		n++;
  800c32:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c36:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c3a:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800c3e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c42:	74 0a                	je     800c4e <strnlen+0x2b>
  800c44:	8b 45 08             	mov    0x8(%ebp),%eax
  800c47:	0f b6 00             	movzbl (%eax),%eax
  800c4a:	84 c0                	test   %al,%al
  800c4c:	75 e4                	jne    800c32 <strnlen+0xf>
		n++;
	return n;
  800c4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c51:	c9                   	leave  
  800c52:	c3                   	ret    

00800c53 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c59:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c5f:	90                   	nop
  800c60:	8b 45 08             	mov    0x8(%ebp),%eax
  800c63:	8d 50 01             	lea    0x1(%eax),%edx
  800c66:	89 55 08             	mov    %edx,0x8(%ebp)
  800c69:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c6c:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c6f:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800c72:	0f b6 12             	movzbl (%edx),%edx
  800c75:	88 10                	mov    %dl,(%eax)
  800c77:	0f b6 00             	movzbl (%eax),%eax
  800c7a:	84 c0                	test   %al,%al
  800c7c:	75 e2                	jne    800c60 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800c7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c81:	c9                   	leave  
  800c82:	c3                   	ret    

00800c83 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800c89:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8c:	89 04 24             	mov    %eax,(%esp)
  800c8f:	e8 69 ff ff ff       	call   800bfd <strlen>
  800c94:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800c97:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800c9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9d:	01 c2                	add    %eax,%edx
  800c9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ca6:	89 14 24             	mov    %edx,(%esp)
  800ca9:	e8 a5 ff ff ff       	call   800c53 <strcpy>
	return dst;
  800cae:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cb1:	c9                   	leave  
  800cb2:	c3                   	ret    

00800cb3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800cb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbc:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800cbf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800cc6:	eb 23                	jmp    800ceb <strncpy+0x38>
		*dst++ = *src;
  800cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccb:	8d 50 01             	lea    0x1(%eax),%edx
  800cce:	89 55 08             	mov    %edx,0x8(%ebp)
  800cd1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cd4:	0f b6 12             	movzbl (%edx),%edx
  800cd7:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800cd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cdc:	0f b6 00             	movzbl (%eax),%eax
  800cdf:	84 c0                	test   %al,%al
  800ce1:	74 04                	je     800ce7 <strncpy+0x34>
			src++;
  800ce3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ce7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800ceb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cee:	3b 45 10             	cmp    0x10(%ebp),%eax
  800cf1:	72 d5                	jb     800cc8 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800cf3:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800cf6:	c9                   	leave  
  800cf7:	c3                   	ret    

00800cf8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800cfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800d01:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800d04:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d08:	74 33                	je     800d3d <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d0a:	eb 17                	jmp    800d23 <strlcpy+0x2b>
			*dst++ = *src++;
  800d0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0f:	8d 50 01             	lea    0x1(%eax),%edx
  800d12:	89 55 08             	mov    %edx,0x8(%ebp)
  800d15:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d18:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d1b:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d1e:	0f b6 12             	movzbl (%edx),%edx
  800d21:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d23:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d27:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d2b:	74 0a                	je     800d37 <strlcpy+0x3f>
  800d2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d30:	0f b6 00             	movzbl (%eax),%eax
  800d33:	84 c0                	test   %al,%al
  800d35:	75 d5                	jne    800d0c <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800d37:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d40:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d43:	29 c2                	sub    %eax,%edx
  800d45:	89 d0                	mov    %edx,%eax
}
  800d47:	c9                   	leave  
  800d48:	c3                   	ret    

00800d49 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d4c:	eb 08                	jmp    800d56 <strcmp+0xd>
		p++, q++;
  800d4e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d52:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d56:	8b 45 08             	mov    0x8(%ebp),%eax
  800d59:	0f b6 00             	movzbl (%eax),%eax
  800d5c:	84 c0                	test   %al,%al
  800d5e:	74 10                	je     800d70 <strcmp+0x27>
  800d60:	8b 45 08             	mov    0x8(%ebp),%eax
  800d63:	0f b6 10             	movzbl (%eax),%edx
  800d66:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d69:	0f b6 00             	movzbl (%eax),%eax
  800d6c:	38 c2                	cmp    %al,%dl
  800d6e:	74 de                	je     800d4e <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d70:	8b 45 08             	mov    0x8(%ebp),%eax
  800d73:	0f b6 00             	movzbl (%eax),%eax
  800d76:	0f b6 d0             	movzbl %al,%edx
  800d79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d7c:	0f b6 00             	movzbl (%eax),%eax
  800d7f:	0f b6 c0             	movzbl %al,%eax
  800d82:	29 c2                	sub    %eax,%edx
  800d84:	89 d0                	mov    %edx,%eax
}
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800d8b:	eb 0c                	jmp    800d99 <strncmp+0x11>
		n--, p++, q++;
  800d8d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d91:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d95:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d99:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d9d:	74 1a                	je     800db9 <strncmp+0x31>
  800d9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800da2:	0f b6 00             	movzbl (%eax),%eax
  800da5:	84 c0                	test   %al,%al
  800da7:	74 10                	je     800db9 <strncmp+0x31>
  800da9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dac:	0f b6 10             	movzbl (%eax),%edx
  800daf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db2:	0f b6 00             	movzbl (%eax),%eax
  800db5:	38 c2                	cmp    %al,%dl
  800db7:	74 d4                	je     800d8d <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800db9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dbd:	75 07                	jne    800dc6 <strncmp+0x3e>
		return 0;
  800dbf:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc4:	eb 16                	jmp    800ddc <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc9:	0f b6 00             	movzbl (%eax),%eax
  800dcc:	0f b6 d0             	movzbl %al,%edx
  800dcf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd2:	0f b6 00             	movzbl (%eax),%eax
  800dd5:	0f b6 c0             	movzbl %al,%eax
  800dd8:	29 c2                	sub    %eax,%edx
  800dda:	89 d0                	mov    %edx,%eax
}
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    

00800dde <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
  800de1:	83 ec 04             	sub    $0x4,%esp
  800de4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de7:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800dea:	eb 14                	jmp    800e00 <strchr+0x22>
		if (*s == c)
  800dec:	8b 45 08             	mov    0x8(%ebp),%eax
  800def:	0f b6 00             	movzbl (%eax),%eax
  800df2:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800df5:	75 05                	jne    800dfc <strchr+0x1e>
			return (char *) s;
  800df7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfa:	eb 13                	jmp    800e0f <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dfc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e00:	8b 45 08             	mov    0x8(%ebp),%eax
  800e03:	0f b6 00             	movzbl (%eax),%eax
  800e06:	84 c0                	test   %al,%al
  800e08:	75 e2                	jne    800dec <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e0f:	c9                   	leave  
  800e10:	c3                   	ret    

00800e11 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	83 ec 04             	sub    $0x4,%esp
  800e17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e1a:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e1d:	eb 11                	jmp    800e30 <strfind+0x1f>
		if (*s == c)
  800e1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e22:	0f b6 00             	movzbl (%eax),%eax
  800e25:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e28:	75 02                	jne    800e2c <strfind+0x1b>
			break;
  800e2a:	eb 0e                	jmp    800e3a <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e2c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e30:	8b 45 08             	mov    0x8(%ebp),%eax
  800e33:	0f b6 00             	movzbl (%eax),%eax
  800e36:	84 c0                	test   %al,%al
  800e38:	75 e5                	jne    800e1f <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800e3a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e3d:	c9                   	leave  
  800e3e:	c3                   	ret    

00800e3f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e43:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e47:	75 05                	jne    800e4e <memset+0xf>
		return v;
  800e49:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4c:	eb 5c                	jmp    800eaa <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e51:	83 e0 03             	and    $0x3,%eax
  800e54:	85 c0                	test   %eax,%eax
  800e56:	75 41                	jne    800e99 <memset+0x5a>
  800e58:	8b 45 10             	mov    0x10(%ebp),%eax
  800e5b:	83 e0 03             	and    $0x3,%eax
  800e5e:	85 c0                	test   %eax,%eax
  800e60:	75 37                	jne    800e99 <memset+0x5a>
		c &= 0xFF;
  800e62:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6c:	c1 e0 18             	shl    $0x18,%eax
  800e6f:	89 c2                	mov    %eax,%edx
  800e71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e74:	c1 e0 10             	shl    $0x10,%eax
  800e77:	09 c2                	or     %eax,%edx
  800e79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7c:	c1 e0 08             	shl    $0x8,%eax
  800e7f:	09 d0                	or     %edx,%eax
  800e81:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e84:	8b 45 10             	mov    0x10(%ebp),%eax
  800e87:	c1 e8 02             	shr    $0x2,%eax
  800e8a:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e92:	89 d7                	mov    %edx,%edi
  800e94:	fc                   	cld    
  800e95:	f3 ab                	rep stos %eax,%es:(%edi)
  800e97:	eb 0e                	jmp    800ea7 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e99:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ea2:	89 d7                	mov    %edx,%edi
  800ea4:	fc                   	cld    
  800ea5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800ea7:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800eaa:	5f                   	pop    %edi
  800eab:	5d                   	pop    %ebp
  800eac:	c3                   	ret    

00800ead <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	57                   	push   %edi
  800eb1:	56                   	push   %esi
  800eb2:	53                   	push   %ebx
  800eb3:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800eb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800ebc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebf:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800ec2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ec5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ec8:	73 6d                	jae    800f37 <memmove+0x8a>
  800eca:	8b 45 10             	mov    0x10(%ebp),%eax
  800ecd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ed0:	01 d0                	add    %edx,%eax
  800ed2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ed5:	76 60                	jbe    800f37 <memmove+0x8a>
		s += n;
  800ed7:	8b 45 10             	mov    0x10(%ebp),%eax
  800eda:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800edd:	8b 45 10             	mov    0x10(%ebp),%eax
  800ee0:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ee3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ee6:	83 e0 03             	and    $0x3,%eax
  800ee9:	85 c0                	test   %eax,%eax
  800eeb:	75 2f                	jne    800f1c <memmove+0x6f>
  800eed:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ef0:	83 e0 03             	and    $0x3,%eax
  800ef3:	85 c0                	test   %eax,%eax
  800ef5:	75 25                	jne    800f1c <memmove+0x6f>
  800ef7:	8b 45 10             	mov    0x10(%ebp),%eax
  800efa:	83 e0 03             	and    $0x3,%eax
  800efd:	85 c0                	test   %eax,%eax
  800eff:	75 1b                	jne    800f1c <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f01:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f04:	83 e8 04             	sub    $0x4,%eax
  800f07:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f0a:	83 ea 04             	sub    $0x4,%edx
  800f0d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f10:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f13:	89 c7                	mov    %eax,%edi
  800f15:	89 d6                	mov    %edx,%esi
  800f17:	fd                   	std    
  800f18:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f1a:	eb 18                	jmp    800f34 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f1f:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f25:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f28:	8b 45 10             	mov    0x10(%ebp),%eax
  800f2b:	89 d7                	mov    %edx,%edi
  800f2d:	89 de                	mov    %ebx,%esi
  800f2f:	89 c1                	mov    %eax,%ecx
  800f31:	fd                   	std    
  800f32:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f34:	fc                   	cld    
  800f35:	eb 45                	jmp    800f7c <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f37:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f3a:	83 e0 03             	and    $0x3,%eax
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	75 2b                	jne    800f6c <memmove+0xbf>
  800f41:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f44:	83 e0 03             	and    $0x3,%eax
  800f47:	85 c0                	test   %eax,%eax
  800f49:	75 21                	jne    800f6c <memmove+0xbf>
  800f4b:	8b 45 10             	mov    0x10(%ebp),%eax
  800f4e:	83 e0 03             	and    $0x3,%eax
  800f51:	85 c0                	test   %eax,%eax
  800f53:	75 17                	jne    800f6c <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f55:	8b 45 10             	mov    0x10(%ebp),%eax
  800f58:	c1 e8 02             	shr    $0x2,%eax
  800f5b:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f5d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f60:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f63:	89 c7                	mov    %eax,%edi
  800f65:	89 d6                	mov    %edx,%esi
  800f67:	fc                   	cld    
  800f68:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f6a:	eb 10                	jmp    800f7c <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f6f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f72:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f75:	89 c7                	mov    %eax,%edi
  800f77:	89 d6                	mov    %edx,%esi
  800f79:	fc                   	cld    
  800f7a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800f7c:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f7f:	83 c4 10             	add    $0x10,%esp
  800f82:	5b                   	pop    %ebx
  800f83:	5e                   	pop    %esi
  800f84:	5f                   	pop    %edi
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    

00800f87 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f8d:	8b 45 10             	mov    0x10(%ebp),%eax
  800f90:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f97:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9e:	89 04 24             	mov    %eax,(%esp)
  800fa1:	e8 07 ff ff ff       	call   800ead <memmove>
}
  800fa6:	c9                   	leave  
  800fa7:	c3                   	ret    

00800fa8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800fae:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb1:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800fb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb7:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800fba:	eb 30                	jmp    800fec <memcmp+0x44>
		if (*s1 != *s2)
  800fbc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fbf:	0f b6 10             	movzbl (%eax),%edx
  800fc2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fc5:	0f b6 00             	movzbl (%eax),%eax
  800fc8:	38 c2                	cmp    %al,%dl
  800fca:	74 18                	je     800fe4 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800fcc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fcf:	0f b6 00             	movzbl (%eax),%eax
  800fd2:	0f b6 d0             	movzbl %al,%edx
  800fd5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fd8:	0f b6 00             	movzbl (%eax),%eax
  800fdb:	0f b6 c0             	movzbl %al,%eax
  800fde:	29 c2                	sub    %eax,%edx
  800fe0:	89 d0                	mov    %edx,%eax
  800fe2:	eb 1a                	jmp    800ffe <memcmp+0x56>
		s1++, s2++;
  800fe4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800fe8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fec:	8b 45 10             	mov    0x10(%ebp),%eax
  800fef:	8d 50 ff             	lea    -0x1(%eax),%edx
  800ff2:	89 55 10             	mov    %edx,0x10(%ebp)
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	75 c3                	jne    800fbc <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ff9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ffe:	c9                   	leave  
  800fff:	c3                   	ret    

00801000 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  801006:	8b 45 10             	mov    0x10(%ebp),%eax
  801009:	8b 55 08             	mov    0x8(%ebp),%edx
  80100c:	01 d0                	add    %edx,%eax
  80100e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801011:	eb 13                	jmp    801026 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801013:	8b 45 08             	mov    0x8(%ebp),%eax
  801016:	0f b6 10             	movzbl (%eax),%edx
  801019:	8b 45 0c             	mov    0xc(%ebp),%eax
  80101c:	38 c2                	cmp    %al,%dl
  80101e:	75 02                	jne    801022 <memfind+0x22>
			break;
  801020:	eb 0c                	jmp    80102e <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801022:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801026:	8b 45 08             	mov    0x8(%ebp),%eax
  801029:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  80102c:	72 e5                	jb     801013 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  80102e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801031:	c9                   	leave  
  801032:	c3                   	ret    

00801033 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  801039:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  801040:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801047:	eb 04                	jmp    80104d <strtol+0x1a>
		s++;
  801049:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80104d:	8b 45 08             	mov    0x8(%ebp),%eax
  801050:	0f b6 00             	movzbl (%eax),%eax
  801053:	3c 20                	cmp    $0x20,%al
  801055:	74 f2                	je     801049 <strtol+0x16>
  801057:	8b 45 08             	mov    0x8(%ebp),%eax
  80105a:	0f b6 00             	movzbl (%eax),%eax
  80105d:	3c 09                	cmp    $0x9,%al
  80105f:	74 e8                	je     801049 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  801061:	8b 45 08             	mov    0x8(%ebp),%eax
  801064:	0f b6 00             	movzbl (%eax),%eax
  801067:	3c 2b                	cmp    $0x2b,%al
  801069:	75 06                	jne    801071 <strtol+0x3e>
		s++;
  80106b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80106f:	eb 15                	jmp    801086 <strtol+0x53>
	else if (*s == '-')
  801071:	8b 45 08             	mov    0x8(%ebp),%eax
  801074:	0f b6 00             	movzbl (%eax),%eax
  801077:	3c 2d                	cmp    $0x2d,%al
  801079:	75 0b                	jne    801086 <strtol+0x53>
		s++, neg = 1;
  80107b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80107f:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801086:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80108a:	74 06                	je     801092 <strtol+0x5f>
  80108c:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  801090:	75 24                	jne    8010b6 <strtol+0x83>
  801092:	8b 45 08             	mov    0x8(%ebp),%eax
  801095:	0f b6 00             	movzbl (%eax),%eax
  801098:	3c 30                	cmp    $0x30,%al
  80109a:	75 1a                	jne    8010b6 <strtol+0x83>
  80109c:	8b 45 08             	mov    0x8(%ebp),%eax
  80109f:	83 c0 01             	add    $0x1,%eax
  8010a2:	0f b6 00             	movzbl (%eax),%eax
  8010a5:	3c 78                	cmp    $0x78,%al
  8010a7:	75 0d                	jne    8010b6 <strtol+0x83>
		s += 2, base = 16;
  8010a9:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8010ad:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8010b4:	eb 2a                	jmp    8010e0 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  8010b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010ba:	75 17                	jne    8010d3 <strtol+0xa0>
  8010bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010bf:	0f b6 00             	movzbl (%eax),%eax
  8010c2:	3c 30                	cmp    $0x30,%al
  8010c4:	75 0d                	jne    8010d3 <strtol+0xa0>
		s++, base = 8;
  8010c6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010ca:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8010d1:	eb 0d                	jmp    8010e0 <strtol+0xad>
	else if (base == 0)
  8010d3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010d7:	75 07                	jne    8010e0 <strtol+0xad>
		base = 10;
  8010d9:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e3:	0f b6 00             	movzbl (%eax),%eax
  8010e6:	3c 2f                	cmp    $0x2f,%al
  8010e8:	7e 1b                	jle    801105 <strtol+0xd2>
  8010ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ed:	0f b6 00             	movzbl (%eax),%eax
  8010f0:	3c 39                	cmp    $0x39,%al
  8010f2:	7f 11                	jg     801105 <strtol+0xd2>
			dig = *s - '0';
  8010f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f7:	0f b6 00             	movzbl (%eax),%eax
  8010fa:	0f be c0             	movsbl %al,%eax
  8010fd:	83 e8 30             	sub    $0x30,%eax
  801100:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801103:	eb 48                	jmp    80114d <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  801105:	8b 45 08             	mov    0x8(%ebp),%eax
  801108:	0f b6 00             	movzbl (%eax),%eax
  80110b:	3c 60                	cmp    $0x60,%al
  80110d:	7e 1b                	jle    80112a <strtol+0xf7>
  80110f:	8b 45 08             	mov    0x8(%ebp),%eax
  801112:	0f b6 00             	movzbl (%eax),%eax
  801115:	3c 7a                	cmp    $0x7a,%al
  801117:	7f 11                	jg     80112a <strtol+0xf7>
			dig = *s - 'a' + 10;
  801119:	8b 45 08             	mov    0x8(%ebp),%eax
  80111c:	0f b6 00             	movzbl (%eax),%eax
  80111f:	0f be c0             	movsbl %al,%eax
  801122:	83 e8 57             	sub    $0x57,%eax
  801125:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801128:	eb 23                	jmp    80114d <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  80112a:	8b 45 08             	mov    0x8(%ebp),%eax
  80112d:	0f b6 00             	movzbl (%eax),%eax
  801130:	3c 40                	cmp    $0x40,%al
  801132:	7e 3d                	jle    801171 <strtol+0x13e>
  801134:	8b 45 08             	mov    0x8(%ebp),%eax
  801137:	0f b6 00             	movzbl (%eax),%eax
  80113a:	3c 5a                	cmp    $0x5a,%al
  80113c:	7f 33                	jg     801171 <strtol+0x13e>
			dig = *s - 'A' + 10;
  80113e:	8b 45 08             	mov    0x8(%ebp),%eax
  801141:	0f b6 00             	movzbl (%eax),%eax
  801144:	0f be c0             	movsbl %al,%eax
  801147:	83 e8 37             	sub    $0x37,%eax
  80114a:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  80114d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801150:	3b 45 10             	cmp    0x10(%ebp),%eax
  801153:	7c 02                	jl     801157 <strtol+0x124>
			break;
  801155:	eb 1a                	jmp    801171 <strtol+0x13e>
		s++, val = (val * base) + dig;
  801157:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80115b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80115e:	0f af 45 10          	imul   0x10(%ebp),%eax
  801162:	89 c2                	mov    %eax,%edx
  801164:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801167:	01 d0                	add    %edx,%eax
  801169:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  80116c:	e9 6f ff ff ff       	jmp    8010e0 <strtol+0xad>

	if (endptr)
  801171:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801175:	74 08                	je     80117f <strtol+0x14c>
		*endptr = (char *) s;
  801177:	8b 45 0c             	mov    0xc(%ebp),%eax
  80117a:	8b 55 08             	mov    0x8(%ebp),%edx
  80117d:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  80117f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  801183:	74 07                	je     80118c <strtol+0x159>
  801185:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801188:	f7 d8                	neg    %eax
  80118a:	eb 03                	jmp    80118f <strtol+0x15c>
  80118c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  80118f:	c9                   	leave  
  801190:	c3                   	ret    
  801191:	66 90                	xchg   %ax,%ax
  801193:	66 90                	xchg   %ax,%ax
  801195:	66 90                	xchg   %ax,%ax
  801197:	66 90                	xchg   %ax,%ax
  801199:	66 90                	xchg   %ax,%ax
  80119b:	66 90                	xchg   %ax,%ax
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
