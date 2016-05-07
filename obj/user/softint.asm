
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800040:	e8 72 01 00 00       	call   8001b7 <sys_getenvid>
  800045:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004a:	c1 e0 02             	shl    $0x2,%eax
  80004d:	89 c2                	mov    %eax,%edx
  80004f:	c1 e2 05             	shl    $0x5,%edx
  800052:	29 c2                	sub    %eax,%edx
  800054:	89 d0                	mov    %edx,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	// if (argc > 0)
	// 	binaryname = argv[0];

	// call user main routine
	umain(argc, argv);
  800060:	8b 45 0c             	mov    0xc(%ebp),%eax
  800063:	89 44 24 04          	mov    %eax,0x4(%esp)
  800067:	8b 45 08             	mov    0x8(%ebp),%eax
  80006a:	89 04 24             	mov    %eax,(%esp)
  80006d:	e8 c1 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800072:	e8 02 00 00 00       	call   800079 <exit>
}
  800077:	c9                   	leave  
  800078:	c3                   	ret    

00800079 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800079:	55                   	push   %ebp
  80007a:	89 e5                	mov    %esp,%ebp
  80007c:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80007f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800086:	e8 e9 00 00 00       	call   800174 <sys_env_destroy>
}
  80008b:	c9                   	leave  
  80008c:	c3                   	ret    

0080008d <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	57                   	push   %edi
  800091:	56                   	push   %esi
  800092:	53                   	push   %ebx
  800093:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800096:	8b 45 08             	mov    0x8(%ebp),%eax
  800099:	8b 55 10             	mov    0x10(%ebp),%edx
  80009c:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80009f:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8000a2:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  8000a5:	8b 75 20             	mov    0x20(%ebp),%esi
  8000a8:	cd 30                	int    $0x30
  8000aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000ad:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8000b1:	74 30                	je     8000e3 <syscall+0x56>
  8000b3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000b7:	7e 2a                	jle    8000e3 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000bc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8000c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c7:	c7 44 24 08 6a 14 80 	movl   $0x80146a,0x8(%esp)
  8000ce:	00 
  8000cf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000d6:	00 
  8000d7:	c7 04 24 87 14 80 00 	movl   $0x801487,(%esp)
  8000de:	e8 b3 03 00 00       	call   800496 <_panic>

	return ret;
  8000e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8000e6:	83 c4 3c             	add    $0x3c,%esp
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5f                   	pop    %edi
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8000f7:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8000fe:	00 
  8000ff:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800106:	00 
  800107:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80010e:	00 
  80010f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800112:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800116:	89 44 24 08          	mov    %eax,0x8(%esp)
  80011a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800121:	00 
  800122:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800129:	e8 5f ff ff ff       	call   80008d <syscall>
}
  80012e:	c9                   	leave  
  80012f:	c3                   	ret    

00800130 <sys_cgetc>:

int
sys_cgetc(void)
{
  800130:	55                   	push   %ebp
  800131:	89 e5                	mov    %esp,%ebp
  800133:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800136:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80013d:	00 
  80013e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800145:	00 
  800146:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80014d:	00 
  80014e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800155:	00 
  800156:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80015d:	00 
  80015e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800165:	00 
  800166:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80016d:	e8 1b ff ff ff       	call   80008d <syscall>
}
  800172:	c9                   	leave  
  800173:	c3                   	ret    

00800174 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80017a:	8b 45 08             	mov    0x8(%ebp),%eax
  80017d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800184:	00 
  800185:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80018c:	00 
  80018d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800194:	00 
  800195:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80019c:	00 
  80019d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001a1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001a8:	00 
  8001a9:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8001b0:	e8 d8 fe ff ff       	call   80008d <syscall>
}
  8001b5:	c9                   	leave  
  8001b6:	c3                   	ret    

008001b7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8001bd:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001c4:	00 
  8001c5:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001cc:	00 
  8001cd:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001d4:	00 
  8001d5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001dc:	00 
  8001dd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001e4:	00 
  8001e5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001ec:	00 
  8001ed:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8001f4:	e8 94 fe ff ff       	call   80008d <syscall>
}
  8001f9:	c9                   	leave  
  8001fa:	c3                   	ret    

008001fb <sys_yield>:

void
sys_yield(void)
{
  8001fb:	55                   	push   %ebp
  8001fc:	89 e5                	mov    %esp,%ebp
  8001fe:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800201:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800208:	00 
  800209:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800210:	00 
  800211:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800218:	00 
  800219:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800220:	00 
  800221:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800228:	00 
  800229:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800230:	00 
  800231:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800238:	e8 50 fe ff ff       	call   80008d <syscall>
}
  80023d:	c9                   	leave  
  80023e:	c3                   	ret    

0080023f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800245:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800248:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024b:	8b 45 08             	mov    0x8(%ebp),%eax
  80024e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800255:	00 
  800256:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80025d:	00 
  80025e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800262:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800266:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800271:	00 
  800272:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800279:	e8 0f fe ff ff       	call   80008d <syscall>
}
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	56                   	push   %esi
  800284:	53                   	push   %ebx
  800285:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800288:	8b 75 18             	mov    0x18(%ebp),%esi
  80028b:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80028e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800291:	8b 55 0c             	mov    0xc(%ebp),%edx
  800294:	8b 45 08             	mov    0x8(%ebp),%eax
  800297:	89 74 24 18          	mov    %esi,0x18(%esp)
  80029b:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80029f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002a3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ab:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002b2:	00 
  8002b3:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8002ba:	e8 ce fd ff ff       	call   80008d <syscall>
}
  8002bf:	83 c4 20             	add    $0x20,%esp
  8002c2:	5b                   	pop    %ebx
  8002c3:	5e                   	pop    %esi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8002cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d2:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8002d9:	00 
  8002da:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8002e1:	00 
  8002e2:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8002e9:	00 
  8002ea:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002f9:	00 
  8002fa:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  800301:	e8 87 fd ff ff       	call   80008d <syscall>
}
  800306:	c9                   	leave  
  800307:	c3                   	ret    

00800308 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80030e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800311:	8b 45 08             	mov    0x8(%ebp),%eax
  800314:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80031b:	00 
  80031c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800323:	00 
  800324:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80032b:	00 
  80032c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800330:	89 44 24 08          	mov    %eax,0x8(%esp)
  800334:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80033b:	00 
  80033c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800343:	e8 45 fd ff ff       	call   80008d <syscall>
}
  800348:	c9                   	leave  
  800349:	c3                   	ret    

0080034a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
  80034d:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800350:	8b 55 0c             	mov    0xc(%ebp),%edx
  800353:	8b 45 08             	mov    0x8(%ebp),%eax
  800356:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80035d:	00 
  80035e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800365:	00 
  800366:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80036d:	00 
  80036e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800372:	89 44 24 08          	mov    %eax,0x8(%esp)
  800376:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80037d:	00 
  80037e:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  800385:	e8 03 fd ff ff       	call   80008d <syscall>
}
  80038a:	c9                   	leave  
  80038b:	c3                   	ret    

0080038c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800392:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800395:	8b 55 10             	mov    0x10(%ebp),%edx
  800398:	8b 45 08             	mov    0x8(%ebp),%eax
  80039b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003a2:	00 
  8003a3:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8003a7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ae:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003b6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003bd:	00 
  8003be:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8003c5:	e8 c3 fc ff ff       	call   80008d <syscall>
}
  8003ca:	c9                   	leave  
  8003cb:	c3                   	ret    

008003cc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003cc:	55                   	push   %ebp
  8003cd:	89 e5                	mov    %esp,%ebp
  8003cf:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8003d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003dc:	00 
  8003dd:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8003e4:	00 
  8003e5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8003ec:	00 
  8003ed:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003f4:	00 
  8003f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003f9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800400:	00 
  800401:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  800408:	e8 80 fc ff ff       	call   80008d <syscall>
}
  80040d:	c9                   	leave  
  80040e:	c3                   	ret    

0080040f <sys_exec>:

void sys_exec(char* buf){
  80040f:	55                   	push   %ebp
  800410:	89 e5                	mov    %esp,%ebp
  800412:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  800415:	8b 45 08             	mov    0x8(%ebp),%eax
  800418:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80041f:	00 
  800420:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800427:	00 
  800428:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80042f:	00 
  800430:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800437:	00 
  800438:	89 44 24 08          	mov    %eax,0x8(%esp)
  80043c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800443:	00 
  800444:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  80044b:	e8 3d fc ff ff       	call   80008d <syscall>
}
  800450:	c9                   	leave  
  800451:	c3                   	ret    

00800452 <sys_wait>:

void sys_wait(){
  800452:	55                   	push   %ebp
  800453:	89 e5                	mov    %esp,%ebp
  800455:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_wait, 0, 0, 0, 0, 0, 0);
  800458:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80045f:	00 
  800460:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800467:	00 
  800468:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80046f:	00 
  800470:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800477:	00 
  800478:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80047f:	00 
  800480:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800487:	00 
  800488:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  80048f:	e8 f9 fb ff ff       	call   80008d <syscall>
  800494:	c9                   	leave  
  800495:	c3                   	ret    

00800496 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800496:	55                   	push   %ebp
  800497:	89 e5                	mov    %esp,%ebp
  800499:	53                   	push   %ebx
  80049a:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80049d:	8d 45 14             	lea    0x14(%ebp),%eax
  8004a0:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004a3:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8004a9:	e8 09 fd ff ff       	call   8001b7 <sys_getenvid>
  8004ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004b1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8004b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8004b8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004bc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c4:	c7 04 24 98 14 80 00 	movl   $0x801498,(%esp)
  8004cb:	e8 e1 00 00 00       	call   8005b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8004d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8004da:	89 04 24             	mov    %eax,(%esp)
  8004dd:	e8 6b 00 00 00       	call   80054d <vcprintf>
	cprintf("\n");
  8004e2:	c7 04 24 bb 14 80 00 	movl   $0x8014bb,(%esp)
  8004e9:	e8 c3 00 00 00       	call   8005b1 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004ee:	cc                   	int3   
  8004ef:	eb fd                	jmp    8004ee <_panic+0x58>

008004f1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004f1:	55                   	push   %ebp
  8004f2:	89 e5                	mov    %esp,%ebp
  8004f4:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8004f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004fa:	8b 00                	mov    (%eax),%eax
  8004fc:	8d 48 01             	lea    0x1(%eax),%ecx
  8004ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800502:	89 0a                	mov    %ecx,(%edx)
  800504:	8b 55 08             	mov    0x8(%ebp),%edx
  800507:	89 d1                	mov    %edx,%ecx
  800509:	8b 55 0c             	mov    0xc(%ebp),%edx
  80050c:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800510:	8b 45 0c             	mov    0xc(%ebp),%eax
  800513:	8b 00                	mov    (%eax),%eax
  800515:	3d ff 00 00 00       	cmp    $0xff,%eax
  80051a:	75 20                	jne    80053c <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  80051c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80051f:	8b 00                	mov    (%eax),%eax
  800521:	8b 55 0c             	mov    0xc(%ebp),%edx
  800524:	83 c2 08             	add    $0x8,%edx
  800527:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052b:	89 14 24             	mov    %edx,(%esp)
  80052e:	e8 bb fb ff ff       	call   8000ee <sys_cputs>
		b->idx = 0;
  800533:	8b 45 0c             	mov    0xc(%ebp),%eax
  800536:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  80053c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80053f:	8b 40 04             	mov    0x4(%eax),%eax
  800542:	8d 50 01             	lea    0x1(%eax),%edx
  800545:	8b 45 0c             	mov    0xc(%ebp),%eax
  800548:	89 50 04             	mov    %edx,0x4(%eax)
}
  80054b:	c9                   	leave  
  80054c:	c3                   	ret    

0080054d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80054d:	55                   	push   %ebp
  80054e:	89 e5                	mov    %esp,%ebp
  800550:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800556:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80055d:	00 00 00 
	b.cnt = 0;
  800560:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800567:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80056a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80056d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800571:	8b 45 08             	mov    0x8(%ebp),%eax
  800574:	89 44 24 08          	mov    %eax,0x8(%esp)
  800578:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80057e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800582:	c7 04 24 f1 04 80 00 	movl   $0x8004f1,(%esp)
  800589:	e8 bd 01 00 00       	call   80074b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80058e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800594:	89 44 24 04          	mov    %eax,0x4(%esp)
  800598:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80059e:	83 c0 08             	add    $0x8,%eax
  8005a1:	89 04 24             	mov    %eax,(%esp)
  8005a4:	e8 45 fb ff ff       	call   8000ee <sys_cputs>

	return b.cnt;
  8005a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8005af:	c9                   	leave  
  8005b0:	c3                   	ret    

008005b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005b1:	55                   	push   %ebp
  8005b2:	89 e5                	mov    %esp,%ebp
  8005b4:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005b7:	8d 45 0c             	lea    0xc(%ebp),%eax
  8005ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8005bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c7:	89 04 24             	mov    %eax,(%esp)
  8005ca:	e8 7e ff ff ff       	call   80054d <vcprintf>
  8005cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8005d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8005d5:	c9                   	leave  
  8005d6:	c3                   	ret    

008005d7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005d7:	55                   	push   %ebp
  8005d8:	89 e5                	mov    %esp,%ebp
  8005da:	53                   	push   %ebx
  8005db:	83 ec 34             	sub    $0x34,%esp
  8005de:	8b 45 10             	mov    0x10(%ebp),%eax
  8005e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ea:	8b 45 18             	mov    0x18(%ebp),%eax
  8005ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8005f2:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005f5:	77 72                	ja     800669 <printnum+0x92>
  8005f7:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005fa:	72 05                	jb     800601 <printnum+0x2a>
  8005fc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8005ff:	77 68                	ja     800669 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800601:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800604:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800607:	8b 45 18             	mov    0x18(%ebp),%eax
  80060a:	ba 00 00 00 00       	mov    $0x0,%edx
  80060f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800613:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800617:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80061a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80061d:	89 04 24             	mov    %eax,(%esp)
  800620:	89 54 24 04          	mov    %edx,0x4(%esp)
  800624:	e8 97 0b 00 00       	call   8011c0 <__udivdi3>
  800629:	8b 4d 20             	mov    0x20(%ebp),%ecx
  80062c:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800630:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800634:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800637:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80063b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80063f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800643:	8b 45 0c             	mov    0xc(%ebp),%eax
  800646:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064a:	8b 45 08             	mov    0x8(%ebp),%eax
  80064d:	89 04 24             	mov    %eax,(%esp)
  800650:	e8 82 ff ff ff       	call   8005d7 <printnum>
  800655:	eb 1c                	jmp    800673 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800657:	8b 45 0c             	mov    0xc(%ebp),%eax
  80065a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065e:	8b 45 20             	mov    0x20(%ebp),%eax
  800661:	89 04 24             	mov    %eax,(%esp)
  800664:	8b 45 08             	mov    0x8(%ebp),%eax
  800667:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800669:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  80066d:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800671:	7f e4                	jg     800657 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800673:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800676:	bb 00 00 00 00       	mov    $0x0,%ebx
  80067b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80067e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800681:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800685:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800689:	89 04 24             	mov    %eax,(%esp)
  80068c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800690:	e8 5b 0c 00 00       	call   8012f0 <__umoddi3>
  800695:	05 88 15 80 00       	add    $0x801588,%eax
  80069a:	0f b6 00             	movzbl (%eax),%eax
  80069d:	0f be c0             	movsbl %al,%eax
  8006a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006a7:	89 04 24             	mov    %eax,(%esp)
  8006aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ad:	ff d0                	call   *%eax
}
  8006af:	83 c4 34             	add    $0x34,%esp
  8006b2:	5b                   	pop    %ebx
  8006b3:	5d                   	pop    %ebp
  8006b4:	c3                   	ret    

008006b5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8006b5:	55                   	push   %ebp
  8006b6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006b8:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8006bc:	7e 14                	jle    8006d2 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8006be:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c1:	8b 00                	mov    (%eax),%eax
  8006c3:	8d 48 08             	lea    0x8(%eax),%ecx
  8006c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8006c9:	89 0a                	mov    %ecx,(%edx)
  8006cb:	8b 50 04             	mov    0x4(%eax),%edx
  8006ce:	8b 00                	mov    (%eax),%eax
  8006d0:	eb 30                	jmp    800702 <getuint+0x4d>
	else if (lflag)
  8006d2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006d6:	74 16                	je     8006ee <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8006d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006db:	8b 00                	mov    (%eax),%eax
  8006dd:	8d 48 04             	lea    0x4(%eax),%ecx
  8006e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e3:	89 0a                	mov    %ecx,(%edx)
  8006e5:	8b 00                	mov    (%eax),%eax
  8006e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8006ec:	eb 14                	jmp    800702 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8006ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f1:	8b 00                	mov    (%eax),%eax
  8006f3:	8d 48 04             	lea    0x4(%eax),%ecx
  8006f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8006f9:	89 0a                	mov    %ecx,(%edx)
  8006fb:	8b 00                	mov    (%eax),%eax
  8006fd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800702:	5d                   	pop    %ebp
  800703:	c3                   	ret    

00800704 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800707:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80070b:	7e 14                	jle    800721 <getint+0x1d>
		return va_arg(*ap, long long);
  80070d:	8b 45 08             	mov    0x8(%ebp),%eax
  800710:	8b 00                	mov    (%eax),%eax
  800712:	8d 48 08             	lea    0x8(%eax),%ecx
  800715:	8b 55 08             	mov    0x8(%ebp),%edx
  800718:	89 0a                	mov    %ecx,(%edx)
  80071a:	8b 50 04             	mov    0x4(%eax),%edx
  80071d:	8b 00                	mov    (%eax),%eax
  80071f:	eb 28                	jmp    800749 <getint+0x45>
	else if (lflag)
  800721:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800725:	74 12                	je     800739 <getint+0x35>
		return va_arg(*ap, long);
  800727:	8b 45 08             	mov    0x8(%ebp),%eax
  80072a:	8b 00                	mov    (%eax),%eax
  80072c:	8d 48 04             	lea    0x4(%eax),%ecx
  80072f:	8b 55 08             	mov    0x8(%ebp),%edx
  800732:	89 0a                	mov    %ecx,(%edx)
  800734:	8b 00                	mov    (%eax),%eax
  800736:	99                   	cltd   
  800737:	eb 10                	jmp    800749 <getint+0x45>
	else
		return va_arg(*ap, int);
  800739:	8b 45 08             	mov    0x8(%ebp),%eax
  80073c:	8b 00                	mov    (%eax),%eax
  80073e:	8d 48 04             	lea    0x4(%eax),%ecx
  800741:	8b 55 08             	mov    0x8(%ebp),%edx
  800744:	89 0a                	mov    %ecx,(%edx)
  800746:	8b 00                	mov    (%eax),%eax
  800748:	99                   	cltd   
}
  800749:	5d                   	pop    %ebp
  80074a:	c3                   	ret    

0080074b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80074b:	55                   	push   %ebp
  80074c:	89 e5                	mov    %esp,%ebp
  80074e:	56                   	push   %esi
  80074f:	53                   	push   %ebx
  800750:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800753:	eb 18                	jmp    80076d <vprintfmt+0x22>
			if (ch == '\0')
  800755:	85 db                	test   %ebx,%ebx
  800757:	75 05                	jne    80075e <vprintfmt+0x13>
				return;
  800759:	e9 cc 03 00 00       	jmp    800b2a <vprintfmt+0x3df>
			putch(ch, putdat);
  80075e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800761:	89 44 24 04          	mov    %eax,0x4(%esp)
  800765:	89 1c 24             	mov    %ebx,(%esp)
  800768:	8b 45 08             	mov    0x8(%ebp),%eax
  80076b:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80076d:	8b 45 10             	mov    0x10(%ebp),%eax
  800770:	8d 50 01             	lea    0x1(%eax),%edx
  800773:	89 55 10             	mov    %edx,0x10(%ebp)
  800776:	0f b6 00             	movzbl (%eax),%eax
  800779:	0f b6 d8             	movzbl %al,%ebx
  80077c:	83 fb 25             	cmp    $0x25,%ebx
  80077f:	75 d4                	jne    800755 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800781:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800785:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  80078c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800793:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80079a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a4:	8d 50 01             	lea    0x1(%eax),%edx
  8007a7:	89 55 10             	mov    %edx,0x10(%ebp)
  8007aa:	0f b6 00             	movzbl (%eax),%eax
  8007ad:	0f b6 d8             	movzbl %al,%ebx
  8007b0:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8007b3:	83 f8 55             	cmp    $0x55,%eax
  8007b6:	0f 87 3d 03 00 00    	ja     800af9 <vprintfmt+0x3ae>
  8007bc:	8b 04 85 ac 15 80 00 	mov    0x8015ac(,%eax,4),%eax
  8007c3:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8007c5:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8007c9:	eb d6                	jmp    8007a1 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8007cb:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8007cf:	eb d0                	jmp    8007a1 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007d1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8007d8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007db:	89 d0                	mov    %edx,%eax
  8007dd:	c1 e0 02             	shl    $0x2,%eax
  8007e0:	01 d0                	add    %edx,%eax
  8007e2:	01 c0                	add    %eax,%eax
  8007e4:	01 d8                	add    %ebx,%eax
  8007e6:	83 e8 30             	sub    $0x30,%eax
  8007e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8007ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ef:	0f b6 00             	movzbl (%eax),%eax
  8007f2:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8007f5:	83 fb 2f             	cmp    $0x2f,%ebx
  8007f8:	7e 0b                	jle    800805 <vprintfmt+0xba>
  8007fa:	83 fb 39             	cmp    $0x39,%ebx
  8007fd:	7f 06                	jg     800805 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007ff:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800803:	eb d3                	jmp    8007d8 <vprintfmt+0x8d>
			goto process_precision;
  800805:	eb 33                	jmp    80083a <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800807:	8b 45 14             	mov    0x14(%ebp),%eax
  80080a:	8d 50 04             	lea    0x4(%eax),%edx
  80080d:	89 55 14             	mov    %edx,0x14(%ebp)
  800810:	8b 00                	mov    (%eax),%eax
  800812:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800815:	eb 23                	jmp    80083a <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800817:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80081b:	79 0c                	jns    800829 <vprintfmt+0xde>
				width = 0;
  80081d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800824:	e9 78 ff ff ff       	jmp    8007a1 <vprintfmt+0x56>
  800829:	e9 73 ff ff ff       	jmp    8007a1 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  80082e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800835:	e9 67 ff ff ff       	jmp    8007a1 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80083a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80083e:	79 12                	jns    800852 <vprintfmt+0x107>
				width = precision, precision = -1;
  800840:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800843:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800846:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  80084d:	e9 4f ff ff ff       	jmp    8007a1 <vprintfmt+0x56>
  800852:	e9 4a ff ff ff       	jmp    8007a1 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800857:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80085b:	e9 41 ff ff ff       	jmp    8007a1 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800860:	8b 45 14             	mov    0x14(%ebp),%eax
  800863:	8d 50 04             	lea    0x4(%eax),%edx
  800866:	89 55 14             	mov    %edx,0x14(%ebp)
  800869:	8b 00                	mov    (%eax),%eax
  80086b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800872:	89 04 24             	mov    %eax,(%esp)
  800875:	8b 45 08             	mov    0x8(%ebp),%eax
  800878:	ff d0                	call   *%eax
			break;
  80087a:	e9 a5 02 00 00       	jmp    800b24 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80087f:	8b 45 14             	mov    0x14(%ebp),%eax
  800882:	8d 50 04             	lea    0x4(%eax),%edx
  800885:	89 55 14             	mov    %edx,0x14(%ebp)
  800888:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80088a:	85 db                	test   %ebx,%ebx
  80088c:	79 02                	jns    800890 <vprintfmt+0x145>
				err = -err;
  80088e:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800890:	83 fb 09             	cmp    $0x9,%ebx
  800893:	7f 0b                	jg     8008a0 <vprintfmt+0x155>
  800895:	8b 34 9d 60 15 80 00 	mov    0x801560(,%ebx,4),%esi
  80089c:	85 f6                	test   %esi,%esi
  80089e:	75 23                	jne    8008c3 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8008a0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8008a4:	c7 44 24 08 99 15 80 	movl   $0x801599,0x8(%esp)
  8008ab:	00 
  8008ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b6:	89 04 24             	mov    %eax,(%esp)
  8008b9:	e8 73 02 00 00       	call   800b31 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8008be:	e9 61 02 00 00       	jmp    800b24 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8008c3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008c7:	c7 44 24 08 a2 15 80 	movl   $0x8015a2,0x8(%esp)
  8008ce:	00 
  8008cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d9:	89 04 24             	mov    %eax,(%esp)
  8008dc:	e8 50 02 00 00       	call   800b31 <printfmt>
			break;
  8008e1:	e9 3e 02 00 00       	jmp    800b24 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e9:	8d 50 04             	lea    0x4(%eax),%edx
  8008ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ef:	8b 30                	mov    (%eax),%esi
  8008f1:	85 f6                	test   %esi,%esi
  8008f3:	75 05                	jne    8008fa <vprintfmt+0x1af>
				p = "(null)";
  8008f5:	be a5 15 80 00       	mov    $0x8015a5,%esi
			if (width > 0 && padc != '-')
  8008fa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008fe:	7e 37                	jle    800937 <vprintfmt+0x1ec>
  800900:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800904:	74 31                	je     800937 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800906:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800909:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090d:	89 34 24             	mov    %esi,(%esp)
  800910:	e8 39 03 00 00       	call   800c4e <strnlen>
  800915:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800918:	eb 17                	jmp    800931 <vprintfmt+0x1e6>
					putch(padc, putdat);
  80091a:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  80091e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800921:	89 54 24 04          	mov    %edx,0x4(%esp)
  800925:	89 04 24             	mov    %eax,(%esp)
  800928:	8b 45 08             	mov    0x8(%ebp),%eax
  80092b:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80092d:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800931:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800935:	7f e3                	jg     80091a <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800937:	eb 38                	jmp    800971 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800939:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80093d:	74 1f                	je     80095e <vprintfmt+0x213>
  80093f:	83 fb 1f             	cmp    $0x1f,%ebx
  800942:	7e 05                	jle    800949 <vprintfmt+0x1fe>
  800944:	83 fb 7e             	cmp    $0x7e,%ebx
  800947:	7e 15                	jle    80095e <vprintfmt+0x213>
					putch('?', putdat);
  800949:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800950:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	ff d0                	call   *%eax
  80095c:	eb 0f                	jmp    80096d <vprintfmt+0x222>
				else
					putch(ch, putdat);
  80095e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800961:	89 44 24 04          	mov    %eax,0x4(%esp)
  800965:	89 1c 24             	mov    %ebx,(%esp)
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80096d:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800971:	89 f0                	mov    %esi,%eax
  800973:	8d 70 01             	lea    0x1(%eax),%esi
  800976:	0f b6 00             	movzbl (%eax),%eax
  800979:	0f be d8             	movsbl %al,%ebx
  80097c:	85 db                	test   %ebx,%ebx
  80097e:	74 10                	je     800990 <vprintfmt+0x245>
  800980:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800984:	78 b3                	js     800939 <vprintfmt+0x1ee>
  800986:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80098a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80098e:	79 a9                	jns    800939 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800990:	eb 17                	jmp    8009a9 <vprintfmt+0x25e>
				putch(' ', putdat);
  800992:	8b 45 0c             	mov    0xc(%ebp),%eax
  800995:	89 44 24 04          	mov    %eax,0x4(%esp)
  800999:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a3:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009a5:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8009a9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009ad:	7f e3                	jg     800992 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8009af:	e9 70 01 00 00       	jmp    800b24 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8009be:	89 04 24             	mov    %eax,(%esp)
  8009c1:	e8 3e fd ff ff       	call   800704 <getint>
  8009c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009c9:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8009cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009d2:	85 d2                	test   %edx,%edx
  8009d4:	79 26                	jns    8009fc <vprintfmt+0x2b1>
				putch('-', putdat);
  8009d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009dd:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e7:	ff d0                	call   *%eax
				num = -(long long) num;
  8009e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009ef:	f7 d8                	neg    %eax
  8009f1:	83 d2 00             	adc    $0x0,%edx
  8009f4:	f7 da                	neg    %edx
  8009f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009f9:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8009fc:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a03:	e9 a8 00 00 00       	jmp    800ab0 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a08:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0f:	8d 45 14             	lea    0x14(%ebp),%eax
  800a12:	89 04 24             	mov    %eax,(%esp)
  800a15:	e8 9b fc ff ff       	call   8006b5 <getuint>
  800a1a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a1d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800a20:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a27:	e9 84 00 00 00       	jmp    800ab0 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a2c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a33:	8d 45 14             	lea    0x14(%ebp),%eax
  800a36:	89 04 24             	mov    %eax,(%esp)
  800a39:	e8 77 fc ff ff       	call   8006b5 <getuint>
  800a3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a41:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800a44:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800a4b:	eb 63                	jmp    800ab0 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a50:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a54:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5e:	ff d0                	call   *%eax
			putch('x', putdat);
  800a60:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a63:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a67:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a71:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a73:	8b 45 14             	mov    0x14(%ebp),%eax
  800a76:	8d 50 04             	lea    0x4(%eax),%edx
  800a79:	89 55 14             	mov    %edx,0x14(%ebp)
  800a7c:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a81:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a88:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a8f:	eb 1f                	jmp    800ab0 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a91:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a94:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a98:	8d 45 14             	lea    0x14(%ebp),%eax
  800a9b:	89 04 24             	mov    %eax,(%esp)
  800a9e:	e8 12 fc ff ff       	call   8006b5 <getuint>
  800aa3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800aa6:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800aa9:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ab0:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800ab4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ab7:	89 54 24 18          	mov    %edx,0x18(%esp)
  800abb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800abe:	89 54 24 14          	mov    %edx,0x14(%esp)
  800ac2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ac6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ac9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800acc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ad0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ad4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800adb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ade:	89 04 24             	mov    %eax,(%esp)
  800ae1:	e8 f1 fa ff ff       	call   8005d7 <printnum>
			break;
  800ae6:	eb 3c                	jmp    800b24 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ae8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aeb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aef:	89 1c 24             	mov    %ebx,(%esp)
  800af2:	8b 45 08             	mov    0x8(%ebp),%eax
  800af5:	ff d0                	call   *%eax
			break;
  800af7:	eb 2b                	jmp    800b24 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800af9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b00:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b07:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0a:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b0c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b10:	eb 04                	jmp    800b16 <vprintfmt+0x3cb>
  800b12:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b16:	8b 45 10             	mov    0x10(%ebp),%eax
  800b19:	83 e8 01             	sub    $0x1,%eax
  800b1c:	0f b6 00             	movzbl (%eax),%eax
  800b1f:	3c 25                	cmp    $0x25,%al
  800b21:	75 ef                	jne    800b12 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800b23:	90                   	nop
		}
	}
  800b24:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b25:	e9 43 fc ff ff       	jmp    80076d <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800b2a:	83 c4 40             	add    $0x40,%esp
  800b2d:	5b                   	pop    %ebx
  800b2e:	5e                   	pop    %esi
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b37:	8d 45 14             	lea    0x14(%ebp),%eax
  800b3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b40:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b44:	8b 45 10             	mov    0x10(%ebp),%eax
  800b47:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b52:	8b 45 08             	mov    0x8(%ebp),%eax
  800b55:	89 04 24             	mov    %eax,(%esp)
  800b58:	e8 ee fb ff ff       	call   80074b <vprintfmt>
	va_end(ap);
}
  800b5d:	c9                   	leave  
  800b5e:	c3                   	ret    

00800b5f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800b62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b65:	8b 40 08             	mov    0x8(%eax),%eax
  800b68:	8d 50 01             	lea    0x1(%eax),%edx
  800b6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6e:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b74:	8b 10                	mov    (%eax),%edx
  800b76:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b79:	8b 40 04             	mov    0x4(%eax),%eax
  800b7c:	39 c2                	cmp    %eax,%edx
  800b7e:	73 12                	jae    800b92 <sprintputch+0x33>
		*b->buf++ = ch;
  800b80:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b83:	8b 00                	mov    (%eax),%eax
  800b85:	8d 48 01             	lea    0x1(%eax),%ecx
  800b88:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b8b:	89 0a                	mov    %ecx,(%edx)
  800b8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b90:	88 10                	mov    %dl,(%eax)
}
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ba0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba3:	8d 50 ff             	lea    -0x1(%eax),%edx
  800ba6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba9:	01 d0                	add    %edx,%eax
  800bab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800bae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bb5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800bb9:	74 06                	je     800bc1 <vsnprintf+0x2d>
  800bbb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bbf:	7f 07                	jg     800bc8 <vsnprintf+0x34>
		return -E_INVAL;
  800bc1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bc6:	eb 2a                	jmp    800bf2 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bc8:	8b 45 14             	mov    0x14(%ebp),%eax
  800bcb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bcf:	8b 45 10             	mov    0x10(%ebp),%eax
  800bd2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bd6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bdd:	c7 04 24 5f 0b 80 00 	movl   $0x800b5f,(%esp)
  800be4:	e8 62 fb ff ff       	call   80074b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800be9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bec:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bf2:	c9                   	leave  
  800bf3:	c3                   	ret    

00800bf4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bfa:	8d 45 14             	lea    0x14(%ebp),%eax
  800bfd:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800c00:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c03:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c07:	8b 45 10             	mov    0x10(%ebp),%eax
  800c0a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c11:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c15:	8b 45 08             	mov    0x8(%ebp),%eax
  800c18:	89 04 24             	mov    %eax,(%esp)
  800c1b:	e8 74 ff ff ff       	call   800b94 <vsnprintf>
  800c20:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c26:	c9                   	leave  
  800c27:	c3                   	ret    

00800c28 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800c2e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c35:	eb 08                	jmp    800c3f <strlen+0x17>
		n++;
  800c37:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c3b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c42:	0f b6 00             	movzbl (%eax),%eax
  800c45:	84 c0                	test   %al,%al
  800c47:	75 ee                	jne    800c37 <strlen+0xf>
		n++;
	return n;
  800c49:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c4c:	c9                   	leave  
  800c4d:	c3                   	ret    

00800c4e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c54:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c5b:	eb 0c                	jmp    800c69 <strnlen+0x1b>
		n++;
  800c5d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c61:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c65:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800c69:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c6d:	74 0a                	je     800c79 <strnlen+0x2b>
  800c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c72:	0f b6 00             	movzbl (%eax),%eax
  800c75:	84 c0                	test   %al,%al
  800c77:	75 e4                	jne    800c5d <strnlen+0xf>
		n++;
	return n;
  800c79:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c7c:	c9                   	leave  
  800c7d:	c3                   	ret    

00800c7e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c84:	8b 45 08             	mov    0x8(%ebp),%eax
  800c87:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c8a:	90                   	nop
  800c8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8e:	8d 50 01             	lea    0x1(%eax),%edx
  800c91:	89 55 08             	mov    %edx,0x8(%ebp)
  800c94:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c97:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c9a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800c9d:	0f b6 12             	movzbl (%edx),%edx
  800ca0:	88 10                	mov    %dl,(%eax)
  800ca2:	0f b6 00             	movzbl (%eax),%eax
  800ca5:	84 c0                	test   %al,%al
  800ca7:	75 e2                	jne    800c8b <strcpy+0xd>
		/* do nothing */;
	return ret;
  800ca9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800cac:	c9                   	leave  
  800cad:	c3                   	ret    

00800cae <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800cb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb7:	89 04 24             	mov    %eax,(%esp)
  800cba:	e8 69 ff ff ff       	call   800c28 <strlen>
  800cbf:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800cc2:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800cc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc8:	01 c2                	add    %eax,%edx
  800cca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ccd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd1:	89 14 24             	mov    %edx,(%esp)
  800cd4:	e8 a5 ff ff ff       	call   800c7e <strcpy>
	return dst;
  800cd9:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cdc:	c9                   	leave  
  800cdd:	c3                   	ret    

00800cde <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800ce4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce7:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800cea:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800cf1:	eb 23                	jmp    800d16 <strncpy+0x38>
		*dst++ = *src;
  800cf3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf6:	8d 50 01             	lea    0x1(%eax),%edx
  800cf9:	89 55 08             	mov    %edx,0x8(%ebp)
  800cfc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cff:	0f b6 12             	movzbl (%edx),%edx
  800d02:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800d04:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d07:	0f b6 00             	movzbl (%eax),%eax
  800d0a:	84 c0                	test   %al,%al
  800d0c:	74 04                	je     800d12 <strncpy+0x34>
			src++;
  800d0e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d12:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d16:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d19:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d1c:	72 d5                	jb     800cf3 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800d1e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d21:	c9                   	leave  
  800d22:	c3                   	ret    

00800d23 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800d29:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800d2f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d33:	74 33                	je     800d68 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d35:	eb 17                	jmp    800d4e <strlcpy+0x2b>
			*dst++ = *src++;
  800d37:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3a:	8d 50 01             	lea    0x1(%eax),%edx
  800d3d:	89 55 08             	mov    %edx,0x8(%ebp)
  800d40:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d43:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d46:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d49:	0f b6 12             	movzbl (%edx),%edx
  800d4c:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d4e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d52:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d56:	74 0a                	je     800d62 <strlcpy+0x3f>
  800d58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d5b:	0f b6 00             	movzbl (%eax),%eax
  800d5e:	84 c0                	test   %al,%al
  800d60:	75 d5                	jne    800d37 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800d62:	8b 45 08             	mov    0x8(%ebp),%eax
  800d65:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d68:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d6e:	29 c2                	sub    %eax,%edx
  800d70:	89 d0                	mov    %edx,%eax
}
  800d72:	c9                   	leave  
  800d73:	c3                   	ret    

00800d74 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d77:	eb 08                	jmp    800d81 <strcmp+0xd>
		p++, q++;
  800d79:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d7d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d81:	8b 45 08             	mov    0x8(%ebp),%eax
  800d84:	0f b6 00             	movzbl (%eax),%eax
  800d87:	84 c0                	test   %al,%al
  800d89:	74 10                	je     800d9b <strcmp+0x27>
  800d8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8e:	0f b6 10             	movzbl (%eax),%edx
  800d91:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d94:	0f b6 00             	movzbl (%eax),%eax
  800d97:	38 c2                	cmp    %al,%dl
  800d99:	74 de                	je     800d79 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9e:	0f b6 00             	movzbl (%eax),%eax
  800da1:	0f b6 d0             	movzbl %al,%edx
  800da4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da7:	0f b6 00             	movzbl (%eax),%eax
  800daa:	0f b6 c0             	movzbl %al,%eax
  800dad:	29 c2                	sub    %eax,%edx
  800daf:	89 d0                	mov    %edx,%eax
}
  800db1:	5d                   	pop    %ebp
  800db2:	c3                   	ret    

00800db3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800db6:	eb 0c                	jmp    800dc4 <strncmp+0x11>
		n--, p++, q++;
  800db8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800dbc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dc0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dc4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dc8:	74 1a                	je     800de4 <strncmp+0x31>
  800dca:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcd:	0f b6 00             	movzbl (%eax),%eax
  800dd0:	84 c0                	test   %al,%al
  800dd2:	74 10                	je     800de4 <strncmp+0x31>
  800dd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd7:	0f b6 10             	movzbl (%eax),%edx
  800dda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ddd:	0f b6 00             	movzbl (%eax),%eax
  800de0:	38 c2                	cmp    %al,%dl
  800de2:	74 d4                	je     800db8 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800de4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800de8:	75 07                	jne    800df1 <strncmp+0x3e>
		return 0;
  800dea:	b8 00 00 00 00       	mov    $0x0,%eax
  800def:	eb 16                	jmp    800e07 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800df1:	8b 45 08             	mov    0x8(%ebp),%eax
  800df4:	0f b6 00             	movzbl (%eax),%eax
  800df7:	0f b6 d0             	movzbl %al,%edx
  800dfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dfd:	0f b6 00             	movzbl (%eax),%eax
  800e00:	0f b6 c0             	movzbl %al,%eax
  800e03:	29 c2                	sub    %eax,%edx
  800e05:	89 d0                	mov    %edx,%eax
}
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    

00800e09 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	83 ec 04             	sub    $0x4,%esp
  800e0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e12:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e15:	eb 14                	jmp    800e2b <strchr+0x22>
		if (*s == c)
  800e17:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1a:	0f b6 00             	movzbl (%eax),%eax
  800e1d:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e20:	75 05                	jne    800e27 <strchr+0x1e>
			return (char *) s;
  800e22:	8b 45 08             	mov    0x8(%ebp),%eax
  800e25:	eb 13                	jmp    800e3a <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e27:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2e:	0f b6 00             	movzbl (%eax),%eax
  800e31:	84 c0                	test   %al,%al
  800e33:	75 e2                	jne    800e17 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e35:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e3a:	c9                   	leave  
  800e3b:	c3                   	ret    

00800e3c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	83 ec 04             	sub    $0x4,%esp
  800e42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e45:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e48:	eb 11                	jmp    800e5b <strfind+0x1f>
		if (*s == c)
  800e4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4d:	0f b6 00             	movzbl (%eax),%eax
  800e50:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e53:	75 02                	jne    800e57 <strfind+0x1b>
			break;
  800e55:	eb 0e                	jmp    800e65 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e57:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5e:	0f b6 00             	movzbl (%eax),%eax
  800e61:	84 c0                	test   %al,%al
  800e63:	75 e5                	jne    800e4a <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800e65:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e68:	c9                   	leave  
  800e69:	c3                   	ret    

00800e6a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e6e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e72:	75 05                	jne    800e79 <memset+0xf>
		return v;
  800e74:	8b 45 08             	mov    0x8(%ebp),%eax
  800e77:	eb 5c                	jmp    800ed5 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e79:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7c:	83 e0 03             	and    $0x3,%eax
  800e7f:	85 c0                	test   %eax,%eax
  800e81:	75 41                	jne    800ec4 <memset+0x5a>
  800e83:	8b 45 10             	mov    0x10(%ebp),%eax
  800e86:	83 e0 03             	and    $0x3,%eax
  800e89:	85 c0                	test   %eax,%eax
  800e8b:	75 37                	jne    800ec4 <memset+0x5a>
		c &= 0xFF;
  800e8d:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e97:	c1 e0 18             	shl    $0x18,%eax
  800e9a:	89 c2                	mov    %eax,%edx
  800e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9f:	c1 e0 10             	shl    $0x10,%eax
  800ea2:	09 c2                	or     %eax,%edx
  800ea4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea7:	c1 e0 08             	shl    $0x8,%eax
  800eaa:	09 d0                	or     %edx,%eax
  800eac:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800eaf:	8b 45 10             	mov    0x10(%ebp),%eax
  800eb2:	c1 e8 02             	shr    $0x2,%eax
  800eb5:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800eb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ebd:	89 d7                	mov    %edx,%edi
  800ebf:	fc                   	cld    
  800ec0:	f3 ab                	rep stos %eax,%es:(%edi)
  800ec2:	eb 0e                	jmp    800ed2 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ec4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eca:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ecd:	89 d7                	mov    %edx,%edi
  800ecf:	fc                   	cld    
  800ed0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800ed2:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ed5:	5f                   	pop    %edi
  800ed6:	5d                   	pop    %ebp
  800ed7:	c3                   	ret    

00800ed8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	57                   	push   %edi
  800edc:	56                   	push   %esi
  800edd:	53                   	push   %ebx
  800ede:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800ee1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee4:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800ee7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eea:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800eed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ef0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ef3:	73 6d                	jae    800f62 <memmove+0x8a>
  800ef5:	8b 45 10             	mov    0x10(%ebp),%eax
  800ef8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800efb:	01 d0                	add    %edx,%eax
  800efd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f00:	76 60                	jbe    800f62 <memmove+0x8a>
		s += n;
  800f02:	8b 45 10             	mov    0x10(%ebp),%eax
  800f05:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800f08:	8b 45 10             	mov    0x10(%ebp),%eax
  800f0b:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f11:	83 e0 03             	and    $0x3,%eax
  800f14:	85 c0                	test   %eax,%eax
  800f16:	75 2f                	jne    800f47 <memmove+0x6f>
  800f18:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f1b:	83 e0 03             	and    $0x3,%eax
  800f1e:	85 c0                	test   %eax,%eax
  800f20:	75 25                	jne    800f47 <memmove+0x6f>
  800f22:	8b 45 10             	mov    0x10(%ebp),%eax
  800f25:	83 e0 03             	and    $0x3,%eax
  800f28:	85 c0                	test   %eax,%eax
  800f2a:	75 1b                	jne    800f47 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f2f:	83 e8 04             	sub    $0x4,%eax
  800f32:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f35:	83 ea 04             	sub    $0x4,%edx
  800f38:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f3b:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f3e:	89 c7                	mov    %eax,%edi
  800f40:	89 d6                	mov    %edx,%esi
  800f42:	fd                   	std    
  800f43:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f45:	eb 18                	jmp    800f5f <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f47:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f4a:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f50:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f53:	8b 45 10             	mov    0x10(%ebp),%eax
  800f56:	89 d7                	mov    %edx,%edi
  800f58:	89 de                	mov    %ebx,%esi
  800f5a:	89 c1                	mov    %eax,%ecx
  800f5c:	fd                   	std    
  800f5d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f5f:	fc                   	cld    
  800f60:	eb 45                	jmp    800fa7 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f62:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f65:	83 e0 03             	and    $0x3,%eax
  800f68:	85 c0                	test   %eax,%eax
  800f6a:	75 2b                	jne    800f97 <memmove+0xbf>
  800f6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f6f:	83 e0 03             	and    $0x3,%eax
  800f72:	85 c0                	test   %eax,%eax
  800f74:	75 21                	jne    800f97 <memmove+0xbf>
  800f76:	8b 45 10             	mov    0x10(%ebp),%eax
  800f79:	83 e0 03             	and    $0x3,%eax
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	75 17                	jne    800f97 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f80:	8b 45 10             	mov    0x10(%ebp),%eax
  800f83:	c1 e8 02             	shr    $0x2,%eax
  800f86:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f88:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f8b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f8e:	89 c7                	mov    %eax,%edi
  800f90:	89 d6                	mov    %edx,%esi
  800f92:	fc                   	cld    
  800f93:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f95:	eb 10                	jmp    800fa7 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f97:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f9a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f9d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fa0:	89 c7                	mov    %eax,%edi
  800fa2:	89 d6                	mov    %edx,%esi
  800fa4:	fc                   	cld    
  800fa5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800fa7:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800faa:	83 c4 10             	add    $0x10,%esp
  800fad:	5b                   	pop    %ebx
  800fae:	5e                   	pop    %esi
  800faf:	5f                   	pop    %edi
  800fb0:	5d                   	pop    %ebp
  800fb1:	c3                   	ret    

00800fb2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800fb8:	8b 45 10             	mov    0x10(%ebp),%eax
  800fbb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fc2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc9:	89 04 24             	mov    %eax,(%esp)
  800fcc:	e8 07 ff ff ff       	call   800ed8 <memmove>
}
  800fd1:	c9                   	leave  
  800fd2:	c3                   	ret    

00800fd3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800fd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdc:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800fdf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe2:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800fe5:	eb 30                	jmp    801017 <memcmp+0x44>
		if (*s1 != *s2)
  800fe7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fea:	0f b6 10             	movzbl (%eax),%edx
  800fed:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ff0:	0f b6 00             	movzbl (%eax),%eax
  800ff3:	38 c2                	cmp    %al,%dl
  800ff5:	74 18                	je     80100f <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800ff7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ffa:	0f b6 00             	movzbl (%eax),%eax
  800ffd:	0f b6 d0             	movzbl %al,%edx
  801000:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801003:	0f b6 00             	movzbl (%eax),%eax
  801006:	0f b6 c0             	movzbl %al,%eax
  801009:	29 c2                	sub    %eax,%edx
  80100b:	89 d0                	mov    %edx,%eax
  80100d:	eb 1a                	jmp    801029 <memcmp+0x56>
		s1++, s2++;
  80100f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  801013:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801017:	8b 45 10             	mov    0x10(%ebp),%eax
  80101a:	8d 50 ff             	lea    -0x1(%eax),%edx
  80101d:	89 55 10             	mov    %edx,0x10(%ebp)
  801020:	85 c0                	test   %eax,%eax
  801022:	75 c3                	jne    800fe7 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801024:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801029:	c9                   	leave  
  80102a:	c3                   	ret    

0080102b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  801031:	8b 45 10             	mov    0x10(%ebp),%eax
  801034:	8b 55 08             	mov    0x8(%ebp),%edx
  801037:	01 d0                	add    %edx,%eax
  801039:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  80103c:	eb 13                	jmp    801051 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  80103e:	8b 45 08             	mov    0x8(%ebp),%eax
  801041:	0f b6 10             	movzbl (%eax),%edx
  801044:	8b 45 0c             	mov    0xc(%ebp),%eax
  801047:	38 c2                	cmp    %al,%dl
  801049:	75 02                	jne    80104d <memfind+0x22>
			break;
  80104b:	eb 0c                	jmp    801059 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80104d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801051:	8b 45 08             	mov    0x8(%ebp),%eax
  801054:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  801057:	72 e5                	jb     80103e <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  801059:	8b 45 08             	mov    0x8(%ebp),%eax
}
  80105c:	c9                   	leave  
  80105d:	c3                   	ret    

0080105e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80105e:	55                   	push   %ebp
  80105f:	89 e5                	mov    %esp,%ebp
  801061:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  801064:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  80106b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801072:	eb 04                	jmp    801078 <strtol+0x1a>
		s++;
  801074:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801078:	8b 45 08             	mov    0x8(%ebp),%eax
  80107b:	0f b6 00             	movzbl (%eax),%eax
  80107e:	3c 20                	cmp    $0x20,%al
  801080:	74 f2                	je     801074 <strtol+0x16>
  801082:	8b 45 08             	mov    0x8(%ebp),%eax
  801085:	0f b6 00             	movzbl (%eax),%eax
  801088:	3c 09                	cmp    $0x9,%al
  80108a:	74 e8                	je     801074 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  80108c:	8b 45 08             	mov    0x8(%ebp),%eax
  80108f:	0f b6 00             	movzbl (%eax),%eax
  801092:	3c 2b                	cmp    $0x2b,%al
  801094:	75 06                	jne    80109c <strtol+0x3e>
		s++;
  801096:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80109a:	eb 15                	jmp    8010b1 <strtol+0x53>
	else if (*s == '-')
  80109c:	8b 45 08             	mov    0x8(%ebp),%eax
  80109f:	0f b6 00             	movzbl (%eax),%eax
  8010a2:	3c 2d                	cmp    $0x2d,%al
  8010a4:	75 0b                	jne    8010b1 <strtol+0x53>
		s++, neg = 1;
  8010a6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010aa:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010b1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010b5:	74 06                	je     8010bd <strtol+0x5f>
  8010b7:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8010bb:	75 24                	jne    8010e1 <strtol+0x83>
  8010bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c0:	0f b6 00             	movzbl (%eax),%eax
  8010c3:	3c 30                	cmp    $0x30,%al
  8010c5:	75 1a                	jne    8010e1 <strtol+0x83>
  8010c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ca:	83 c0 01             	add    $0x1,%eax
  8010cd:	0f b6 00             	movzbl (%eax),%eax
  8010d0:	3c 78                	cmp    $0x78,%al
  8010d2:	75 0d                	jne    8010e1 <strtol+0x83>
		s += 2, base = 16;
  8010d4:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8010d8:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8010df:	eb 2a                	jmp    80110b <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  8010e1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010e5:	75 17                	jne    8010fe <strtol+0xa0>
  8010e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ea:	0f b6 00             	movzbl (%eax),%eax
  8010ed:	3c 30                	cmp    $0x30,%al
  8010ef:	75 0d                	jne    8010fe <strtol+0xa0>
		s++, base = 8;
  8010f1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010f5:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8010fc:	eb 0d                	jmp    80110b <strtol+0xad>
	else if (base == 0)
  8010fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801102:	75 07                	jne    80110b <strtol+0xad>
		base = 10;
  801104:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80110b:	8b 45 08             	mov    0x8(%ebp),%eax
  80110e:	0f b6 00             	movzbl (%eax),%eax
  801111:	3c 2f                	cmp    $0x2f,%al
  801113:	7e 1b                	jle    801130 <strtol+0xd2>
  801115:	8b 45 08             	mov    0x8(%ebp),%eax
  801118:	0f b6 00             	movzbl (%eax),%eax
  80111b:	3c 39                	cmp    $0x39,%al
  80111d:	7f 11                	jg     801130 <strtol+0xd2>
			dig = *s - '0';
  80111f:	8b 45 08             	mov    0x8(%ebp),%eax
  801122:	0f b6 00             	movzbl (%eax),%eax
  801125:	0f be c0             	movsbl %al,%eax
  801128:	83 e8 30             	sub    $0x30,%eax
  80112b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80112e:	eb 48                	jmp    801178 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  801130:	8b 45 08             	mov    0x8(%ebp),%eax
  801133:	0f b6 00             	movzbl (%eax),%eax
  801136:	3c 60                	cmp    $0x60,%al
  801138:	7e 1b                	jle    801155 <strtol+0xf7>
  80113a:	8b 45 08             	mov    0x8(%ebp),%eax
  80113d:	0f b6 00             	movzbl (%eax),%eax
  801140:	3c 7a                	cmp    $0x7a,%al
  801142:	7f 11                	jg     801155 <strtol+0xf7>
			dig = *s - 'a' + 10;
  801144:	8b 45 08             	mov    0x8(%ebp),%eax
  801147:	0f b6 00             	movzbl (%eax),%eax
  80114a:	0f be c0             	movsbl %al,%eax
  80114d:	83 e8 57             	sub    $0x57,%eax
  801150:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801153:	eb 23                	jmp    801178 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  801155:	8b 45 08             	mov    0x8(%ebp),%eax
  801158:	0f b6 00             	movzbl (%eax),%eax
  80115b:	3c 40                	cmp    $0x40,%al
  80115d:	7e 3d                	jle    80119c <strtol+0x13e>
  80115f:	8b 45 08             	mov    0x8(%ebp),%eax
  801162:	0f b6 00             	movzbl (%eax),%eax
  801165:	3c 5a                	cmp    $0x5a,%al
  801167:	7f 33                	jg     80119c <strtol+0x13e>
			dig = *s - 'A' + 10;
  801169:	8b 45 08             	mov    0x8(%ebp),%eax
  80116c:	0f b6 00             	movzbl (%eax),%eax
  80116f:	0f be c0             	movsbl %al,%eax
  801172:	83 e8 37             	sub    $0x37,%eax
  801175:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  801178:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80117b:	3b 45 10             	cmp    0x10(%ebp),%eax
  80117e:	7c 02                	jl     801182 <strtol+0x124>
			break;
  801180:	eb 1a                	jmp    80119c <strtol+0x13e>
		s++, val = (val * base) + dig;
  801182:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801186:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801189:	0f af 45 10          	imul   0x10(%ebp),%eax
  80118d:	89 c2                	mov    %eax,%edx
  80118f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801192:	01 d0                	add    %edx,%eax
  801194:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  801197:	e9 6f ff ff ff       	jmp    80110b <strtol+0xad>

	if (endptr)
  80119c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011a0:	74 08                	je     8011aa <strtol+0x14c>
		*endptr = (char *) s;
  8011a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a8:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8011aa:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8011ae:	74 07                	je     8011b7 <strtol+0x159>
  8011b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011b3:	f7 d8                	neg    %eax
  8011b5:	eb 03                	jmp    8011ba <strtol+0x15c>
  8011b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8011ba:	c9                   	leave  
  8011bb:	c3                   	ret    
  8011bc:	66 90                	xchg   %ax,%ax
  8011be:	66 90                	xchg   %ax,%ax

008011c0 <__udivdi3>:
  8011c0:	55                   	push   %ebp
  8011c1:	57                   	push   %edi
  8011c2:	56                   	push   %esi
  8011c3:	83 ec 0c             	sub    $0xc,%esp
  8011c6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8011ca:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8011ce:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8011d2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8011d6:	85 c0                	test   %eax,%eax
  8011d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011dc:	89 ea                	mov    %ebp,%edx
  8011de:	89 0c 24             	mov    %ecx,(%esp)
  8011e1:	75 2d                	jne    801210 <__udivdi3+0x50>
  8011e3:	39 e9                	cmp    %ebp,%ecx
  8011e5:	77 61                	ja     801248 <__udivdi3+0x88>
  8011e7:	85 c9                	test   %ecx,%ecx
  8011e9:	89 ce                	mov    %ecx,%esi
  8011eb:	75 0b                	jne    8011f8 <__udivdi3+0x38>
  8011ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8011f2:	31 d2                	xor    %edx,%edx
  8011f4:	f7 f1                	div    %ecx
  8011f6:	89 c6                	mov    %eax,%esi
  8011f8:	31 d2                	xor    %edx,%edx
  8011fa:	89 e8                	mov    %ebp,%eax
  8011fc:	f7 f6                	div    %esi
  8011fe:	89 c5                	mov    %eax,%ebp
  801200:	89 f8                	mov    %edi,%eax
  801202:	f7 f6                	div    %esi
  801204:	89 ea                	mov    %ebp,%edx
  801206:	83 c4 0c             	add    $0xc,%esp
  801209:	5e                   	pop    %esi
  80120a:	5f                   	pop    %edi
  80120b:	5d                   	pop    %ebp
  80120c:	c3                   	ret    
  80120d:	8d 76 00             	lea    0x0(%esi),%esi
  801210:	39 e8                	cmp    %ebp,%eax
  801212:	77 24                	ja     801238 <__udivdi3+0x78>
  801214:	0f bd e8             	bsr    %eax,%ebp
  801217:	83 f5 1f             	xor    $0x1f,%ebp
  80121a:	75 3c                	jne    801258 <__udivdi3+0x98>
  80121c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801220:	39 34 24             	cmp    %esi,(%esp)
  801223:	0f 86 9f 00 00 00    	jbe    8012c8 <__udivdi3+0x108>
  801229:	39 d0                	cmp    %edx,%eax
  80122b:	0f 82 97 00 00 00    	jb     8012c8 <__udivdi3+0x108>
  801231:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801238:	31 d2                	xor    %edx,%edx
  80123a:	31 c0                	xor    %eax,%eax
  80123c:	83 c4 0c             	add    $0xc,%esp
  80123f:	5e                   	pop    %esi
  801240:	5f                   	pop    %edi
  801241:	5d                   	pop    %ebp
  801242:	c3                   	ret    
  801243:	90                   	nop
  801244:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801248:	89 f8                	mov    %edi,%eax
  80124a:	f7 f1                	div    %ecx
  80124c:	31 d2                	xor    %edx,%edx
  80124e:	83 c4 0c             	add    $0xc,%esp
  801251:	5e                   	pop    %esi
  801252:	5f                   	pop    %edi
  801253:	5d                   	pop    %ebp
  801254:	c3                   	ret    
  801255:	8d 76 00             	lea    0x0(%esi),%esi
  801258:	89 e9                	mov    %ebp,%ecx
  80125a:	8b 3c 24             	mov    (%esp),%edi
  80125d:	d3 e0                	shl    %cl,%eax
  80125f:	89 c6                	mov    %eax,%esi
  801261:	b8 20 00 00 00       	mov    $0x20,%eax
  801266:	29 e8                	sub    %ebp,%eax
  801268:	89 c1                	mov    %eax,%ecx
  80126a:	d3 ef                	shr    %cl,%edi
  80126c:	89 e9                	mov    %ebp,%ecx
  80126e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801272:	8b 3c 24             	mov    (%esp),%edi
  801275:	09 74 24 08          	or     %esi,0x8(%esp)
  801279:	89 d6                	mov    %edx,%esi
  80127b:	d3 e7                	shl    %cl,%edi
  80127d:	89 c1                	mov    %eax,%ecx
  80127f:	89 3c 24             	mov    %edi,(%esp)
  801282:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801286:	d3 ee                	shr    %cl,%esi
  801288:	89 e9                	mov    %ebp,%ecx
  80128a:	d3 e2                	shl    %cl,%edx
  80128c:	89 c1                	mov    %eax,%ecx
  80128e:	d3 ef                	shr    %cl,%edi
  801290:	09 d7                	or     %edx,%edi
  801292:	89 f2                	mov    %esi,%edx
  801294:	89 f8                	mov    %edi,%eax
  801296:	f7 74 24 08          	divl   0x8(%esp)
  80129a:	89 d6                	mov    %edx,%esi
  80129c:	89 c7                	mov    %eax,%edi
  80129e:	f7 24 24             	mull   (%esp)
  8012a1:	39 d6                	cmp    %edx,%esi
  8012a3:	89 14 24             	mov    %edx,(%esp)
  8012a6:	72 30                	jb     8012d8 <__udivdi3+0x118>
  8012a8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012ac:	89 e9                	mov    %ebp,%ecx
  8012ae:	d3 e2                	shl    %cl,%edx
  8012b0:	39 c2                	cmp    %eax,%edx
  8012b2:	73 05                	jae    8012b9 <__udivdi3+0xf9>
  8012b4:	3b 34 24             	cmp    (%esp),%esi
  8012b7:	74 1f                	je     8012d8 <__udivdi3+0x118>
  8012b9:	89 f8                	mov    %edi,%eax
  8012bb:	31 d2                	xor    %edx,%edx
  8012bd:	e9 7a ff ff ff       	jmp    80123c <__udivdi3+0x7c>
  8012c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012c8:	31 d2                	xor    %edx,%edx
  8012ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8012cf:	e9 68 ff ff ff       	jmp    80123c <__udivdi3+0x7c>
  8012d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012d8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8012db:	31 d2                	xor    %edx,%edx
  8012dd:	83 c4 0c             	add    $0xc,%esp
  8012e0:	5e                   	pop    %esi
  8012e1:	5f                   	pop    %edi
  8012e2:	5d                   	pop    %ebp
  8012e3:	c3                   	ret    
  8012e4:	66 90                	xchg   %ax,%ax
  8012e6:	66 90                	xchg   %ax,%ax
  8012e8:	66 90                	xchg   %ax,%ax
  8012ea:	66 90                	xchg   %ax,%ax
  8012ec:	66 90                	xchg   %ax,%ax
  8012ee:	66 90                	xchg   %ax,%ax

008012f0 <__umoddi3>:
  8012f0:	55                   	push   %ebp
  8012f1:	57                   	push   %edi
  8012f2:	56                   	push   %esi
  8012f3:	83 ec 14             	sub    $0x14,%esp
  8012f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8012fa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8012fe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801302:	89 c7                	mov    %eax,%edi
  801304:	89 44 24 04          	mov    %eax,0x4(%esp)
  801308:	8b 44 24 30          	mov    0x30(%esp),%eax
  80130c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801310:	89 34 24             	mov    %esi,(%esp)
  801313:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801317:	85 c0                	test   %eax,%eax
  801319:	89 c2                	mov    %eax,%edx
  80131b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80131f:	75 17                	jne    801338 <__umoddi3+0x48>
  801321:	39 fe                	cmp    %edi,%esi
  801323:	76 4b                	jbe    801370 <__umoddi3+0x80>
  801325:	89 c8                	mov    %ecx,%eax
  801327:	89 fa                	mov    %edi,%edx
  801329:	f7 f6                	div    %esi
  80132b:	89 d0                	mov    %edx,%eax
  80132d:	31 d2                	xor    %edx,%edx
  80132f:	83 c4 14             	add    $0x14,%esp
  801332:	5e                   	pop    %esi
  801333:	5f                   	pop    %edi
  801334:	5d                   	pop    %ebp
  801335:	c3                   	ret    
  801336:	66 90                	xchg   %ax,%ax
  801338:	39 f8                	cmp    %edi,%eax
  80133a:	77 54                	ja     801390 <__umoddi3+0xa0>
  80133c:	0f bd e8             	bsr    %eax,%ebp
  80133f:	83 f5 1f             	xor    $0x1f,%ebp
  801342:	75 5c                	jne    8013a0 <__umoddi3+0xb0>
  801344:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801348:	39 3c 24             	cmp    %edi,(%esp)
  80134b:	0f 87 e7 00 00 00    	ja     801438 <__umoddi3+0x148>
  801351:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801355:	29 f1                	sub    %esi,%ecx
  801357:	19 c7                	sbb    %eax,%edi
  801359:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80135d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801361:	8b 44 24 08          	mov    0x8(%esp),%eax
  801365:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801369:	83 c4 14             	add    $0x14,%esp
  80136c:	5e                   	pop    %esi
  80136d:	5f                   	pop    %edi
  80136e:	5d                   	pop    %ebp
  80136f:	c3                   	ret    
  801370:	85 f6                	test   %esi,%esi
  801372:	89 f5                	mov    %esi,%ebp
  801374:	75 0b                	jne    801381 <__umoddi3+0x91>
  801376:	b8 01 00 00 00       	mov    $0x1,%eax
  80137b:	31 d2                	xor    %edx,%edx
  80137d:	f7 f6                	div    %esi
  80137f:	89 c5                	mov    %eax,%ebp
  801381:	8b 44 24 04          	mov    0x4(%esp),%eax
  801385:	31 d2                	xor    %edx,%edx
  801387:	f7 f5                	div    %ebp
  801389:	89 c8                	mov    %ecx,%eax
  80138b:	f7 f5                	div    %ebp
  80138d:	eb 9c                	jmp    80132b <__umoddi3+0x3b>
  80138f:	90                   	nop
  801390:	89 c8                	mov    %ecx,%eax
  801392:	89 fa                	mov    %edi,%edx
  801394:	83 c4 14             	add    $0x14,%esp
  801397:	5e                   	pop    %esi
  801398:	5f                   	pop    %edi
  801399:	5d                   	pop    %ebp
  80139a:	c3                   	ret    
  80139b:	90                   	nop
  80139c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013a0:	8b 04 24             	mov    (%esp),%eax
  8013a3:	be 20 00 00 00       	mov    $0x20,%esi
  8013a8:	89 e9                	mov    %ebp,%ecx
  8013aa:	29 ee                	sub    %ebp,%esi
  8013ac:	d3 e2                	shl    %cl,%edx
  8013ae:	89 f1                	mov    %esi,%ecx
  8013b0:	d3 e8                	shr    %cl,%eax
  8013b2:	89 e9                	mov    %ebp,%ecx
  8013b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b8:	8b 04 24             	mov    (%esp),%eax
  8013bb:	09 54 24 04          	or     %edx,0x4(%esp)
  8013bf:	89 fa                	mov    %edi,%edx
  8013c1:	d3 e0                	shl    %cl,%eax
  8013c3:	89 f1                	mov    %esi,%ecx
  8013c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013c9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8013cd:	d3 ea                	shr    %cl,%edx
  8013cf:	89 e9                	mov    %ebp,%ecx
  8013d1:	d3 e7                	shl    %cl,%edi
  8013d3:	89 f1                	mov    %esi,%ecx
  8013d5:	d3 e8                	shr    %cl,%eax
  8013d7:	89 e9                	mov    %ebp,%ecx
  8013d9:	09 f8                	or     %edi,%eax
  8013db:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8013df:	f7 74 24 04          	divl   0x4(%esp)
  8013e3:	d3 e7                	shl    %cl,%edi
  8013e5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013e9:	89 d7                	mov    %edx,%edi
  8013eb:	f7 64 24 08          	mull   0x8(%esp)
  8013ef:	39 d7                	cmp    %edx,%edi
  8013f1:	89 c1                	mov    %eax,%ecx
  8013f3:	89 14 24             	mov    %edx,(%esp)
  8013f6:	72 2c                	jb     801424 <__umoddi3+0x134>
  8013f8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8013fc:	72 22                	jb     801420 <__umoddi3+0x130>
  8013fe:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801402:	29 c8                	sub    %ecx,%eax
  801404:	19 d7                	sbb    %edx,%edi
  801406:	89 e9                	mov    %ebp,%ecx
  801408:	89 fa                	mov    %edi,%edx
  80140a:	d3 e8                	shr    %cl,%eax
  80140c:	89 f1                	mov    %esi,%ecx
  80140e:	d3 e2                	shl    %cl,%edx
  801410:	89 e9                	mov    %ebp,%ecx
  801412:	d3 ef                	shr    %cl,%edi
  801414:	09 d0                	or     %edx,%eax
  801416:	89 fa                	mov    %edi,%edx
  801418:	83 c4 14             	add    $0x14,%esp
  80141b:	5e                   	pop    %esi
  80141c:	5f                   	pop    %edi
  80141d:	5d                   	pop    %ebp
  80141e:	c3                   	ret    
  80141f:	90                   	nop
  801420:	39 d7                	cmp    %edx,%edi
  801422:	75 da                	jne    8013fe <__umoddi3+0x10e>
  801424:	8b 14 24             	mov    (%esp),%edx
  801427:	89 c1                	mov    %eax,%ecx
  801429:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80142d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801431:	eb cb                	jmp    8013fe <__umoddi3+0x10e>
  801433:	90                   	nop
  801434:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801438:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80143c:	0f 82 0f ff ff ff    	jb     801351 <__umoddi3+0x61>
  801442:	e9 1a ff ff ff       	jmp    801361 <__umoddi3+0x71>
