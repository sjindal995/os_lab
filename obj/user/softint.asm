
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
  8000c7:	c7 44 24 08 aa 14 80 	movl   $0x8014aa,0x8(%esp)
  8000ce:	00 
  8000cf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000d6:	00 
  8000d7:	c7 04 24 c7 14 80 00 	movl   $0x8014c7,(%esp)
  8000de:	e8 f7 03 00 00       	call   8004da <_panic>

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
}
  800494:	c9                   	leave  
  800495:	c3                   	ret    

00800496 <sys_guest>:

void sys_guest(){
  800496:	55                   	push   %ebp
  800497:	89 e5                	mov    %esp,%ebp
  800499:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_guest, 0, 0, 0, 0, 0, 0);
  80049c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8004a3:	00 
  8004a4:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8004ab:	00 
  8004ac:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8004b3:	00 
  8004b4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004bb:	00 
  8004bc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004c3:	00 
  8004c4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004cb:	00 
  8004cc:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
  8004d3:	e8 b5 fb ff ff       	call   80008d <syscall>
  8004d8:	c9                   	leave  
  8004d9:	c3                   	ret    

008004da <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004da:	55                   	push   %ebp
  8004db:	89 e5                	mov    %esp,%ebp
  8004dd:	53                   	push   %ebx
  8004de:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8004e1:	8d 45 14             	lea    0x14(%ebp),%eax
  8004e4:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004e7:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8004ed:	e8 c5 fc ff ff       	call   8001b7 <sys_getenvid>
  8004f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004f5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8004f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8004fc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800500:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800504:	89 44 24 04          	mov    %eax,0x4(%esp)
  800508:	c7 04 24 d8 14 80 00 	movl   $0x8014d8,(%esp)
  80050f:	e8 e1 00 00 00       	call   8005f5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800514:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800517:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051b:	8b 45 10             	mov    0x10(%ebp),%eax
  80051e:	89 04 24             	mov    %eax,(%esp)
  800521:	e8 6b 00 00 00       	call   800591 <vcprintf>
	cprintf("\n");
  800526:	c7 04 24 fb 14 80 00 	movl   $0x8014fb,(%esp)
  80052d:	e8 c3 00 00 00       	call   8005f5 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800532:	cc                   	int3   
  800533:	eb fd                	jmp    800532 <_panic+0x58>

00800535 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800535:	55                   	push   %ebp
  800536:	89 e5                	mov    %esp,%ebp
  800538:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  80053b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80053e:	8b 00                	mov    (%eax),%eax
  800540:	8d 48 01             	lea    0x1(%eax),%ecx
  800543:	8b 55 0c             	mov    0xc(%ebp),%edx
  800546:	89 0a                	mov    %ecx,(%edx)
  800548:	8b 55 08             	mov    0x8(%ebp),%edx
  80054b:	89 d1                	mov    %edx,%ecx
  80054d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800550:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800554:	8b 45 0c             	mov    0xc(%ebp),%eax
  800557:	8b 00                	mov    (%eax),%eax
  800559:	3d ff 00 00 00       	cmp    $0xff,%eax
  80055e:	75 20                	jne    800580 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800560:	8b 45 0c             	mov    0xc(%ebp),%eax
  800563:	8b 00                	mov    (%eax),%eax
  800565:	8b 55 0c             	mov    0xc(%ebp),%edx
  800568:	83 c2 08             	add    $0x8,%edx
  80056b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056f:	89 14 24             	mov    %edx,(%esp)
  800572:	e8 77 fb ff ff       	call   8000ee <sys_cputs>
		b->idx = 0;
  800577:	8b 45 0c             	mov    0xc(%ebp),%eax
  80057a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800580:	8b 45 0c             	mov    0xc(%ebp),%eax
  800583:	8b 40 04             	mov    0x4(%eax),%eax
  800586:	8d 50 01             	lea    0x1(%eax),%edx
  800589:	8b 45 0c             	mov    0xc(%ebp),%eax
  80058c:	89 50 04             	mov    %edx,0x4(%eax)
}
  80058f:	c9                   	leave  
  800590:	c3                   	ret    

00800591 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800591:	55                   	push   %ebp
  800592:	89 e5                	mov    %esp,%ebp
  800594:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80059a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8005a1:	00 00 00 
	b.cnt = 0;
  8005a4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8005ab:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8005ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005bc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c6:	c7 04 24 35 05 80 00 	movl   $0x800535,(%esp)
  8005cd:	e8 bd 01 00 00       	call   80078f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005d2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8005d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005dc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005e2:	83 c0 08             	add    $0x8,%eax
  8005e5:	89 04 24             	mov    %eax,(%esp)
  8005e8:	e8 01 fb ff ff       	call   8000ee <sys_cputs>

	return b.cnt;
  8005ed:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8005f3:	c9                   	leave  
  8005f4:	c3                   	ret    

008005f5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005f5:	55                   	push   %ebp
  8005f6:	89 e5                	mov    %esp,%ebp
  8005f8:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005fb:	8d 45 0c             	lea    0xc(%ebp),%eax
  8005fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800601:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800604:	89 44 24 04          	mov    %eax,0x4(%esp)
  800608:	8b 45 08             	mov    0x8(%ebp),%eax
  80060b:	89 04 24             	mov    %eax,(%esp)
  80060e:	e8 7e ff ff ff       	call   800591 <vcprintf>
  800613:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800616:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800619:	c9                   	leave  
  80061a:	c3                   	ret    

0080061b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80061b:	55                   	push   %ebp
  80061c:	89 e5                	mov    %esp,%ebp
  80061e:	53                   	push   %ebx
  80061f:	83 ec 34             	sub    $0x34,%esp
  800622:	8b 45 10             	mov    0x10(%ebp),%eax
  800625:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80062e:	8b 45 18             	mov    0x18(%ebp),%eax
  800631:	ba 00 00 00 00       	mov    $0x0,%edx
  800636:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800639:	77 72                	ja     8006ad <printnum+0x92>
  80063b:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80063e:	72 05                	jb     800645 <printnum+0x2a>
  800640:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800643:	77 68                	ja     8006ad <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800645:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800648:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80064b:	8b 45 18             	mov    0x18(%ebp),%eax
  80064e:	ba 00 00 00 00       	mov    $0x0,%edx
  800653:	89 44 24 08          	mov    %eax,0x8(%esp)
  800657:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80065b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800661:	89 04 24             	mov    %eax,(%esp)
  800664:	89 54 24 04          	mov    %edx,0x4(%esp)
  800668:	e8 93 0b 00 00       	call   801200 <__udivdi3>
  80066d:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800670:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800674:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800678:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80067b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80067f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800683:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800687:	8b 45 0c             	mov    0xc(%ebp),%eax
  80068a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80068e:	8b 45 08             	mov    0x8(%ebp),%eax
  800691:	89 04 24             	mov    %eax,(%esp)
  800694:	e8 82 ff ff ff       	call   80061b <printnum>
  800699:	eb 1c                	jmp    8006b7 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80069b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80069e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a2:	8b 45 20             	mov    0x20(%ebp),%eax
  8006a5:	89 04 24             	mov    %eax,(%esp)
  8006a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ab:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006ad:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8006b1:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8006b5:	7f e4                	jg     80069b <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006b7:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8006ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006c5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006c9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006cd:	89 04 24             	mov    %eax,(%esp)
  8006d0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006d4:	e8 57 0c 00 00       	call   801330 <__umoddi3>
  8006d9:	05 c8 15 80 00       	add    $0x8015c8,%eax
  8006de:	0f b6 00             	movzbl (%eax),%eax
  8006e1:	0f be c0             	movsbl %al,%eax
  8006e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006e7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006eb:	89 04 24             	mov    %eax,(%esp)
  8006ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f1:	ff d0                	call   *%eax
}
  8006f3:	83 c4 34             	add    $0x34,%esp
  8006f6:	5b                   	pop    %ebx
  8006f7:	5d                   	pop    %ebp
  8006f8:	c3                   	ret    

008006f9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8006f9:	55                   	push   %ebp
  8006fa:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006fc:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800700:	7e 14                	jle    800716 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800702:	8b 45 08             	mov    0x8(%ebp),%eax
  800705:	8b 00                	mov    (%eax),%eax
  800707:	8d 48 08             	lea    0x8(%eax),%ecx
  80070a:	8b 55 08             	mov    0x8(%ebp),%edx
  80070d:	89 0a                	mov    %ecx,(%edx)
  80070f:	8b 50 04             	mov    0x4(%eax),%edx
  800712:	8b 00                	mov    (%eax),%eax
  800714:	eb 30                	jmp    800746 <getuint+0x4d>
	else if (lflag)
  800716:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80071a:	74 16                	je     800732 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  80071c:	8b 45 08             	mov    0x8(%ebp),%eax
  80071f:	8b 00                	mov    (%eax),%eax
  800721:	8d 48 04             	lea    0x4(%eax),%ecx
  800724:	8b 55 08             	mov    0x8(%ebp),%edx
  800727:	89 0a                	mov    %ecx,(%edx)
  800729:	8b 00                	mov    (%eax),%eax
  80072b:	ba 00 00 00 00       	mov    $0x0,%edx
  800730:	eb 14                	jmp    800746 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800732:	8b 45 08             	mov    0x8(%ebp),%eax
  800735:	8b 00                	mov    (%eax),%eax
  800737:	8d 48 04             	lea    0x4(%eax),%ecx
  80073a:	8b 55 08             	mov    0x8(%ebp),%edx
  80073d:	89 0a                	mov    %ecx,(%edx)
  80073f:	8b 00                	mov    (%eax),%eax
  800741:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800746:	5d                   	pop    %ebp
  800747:	c3                   	ret    

00800748 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800748:	55                   	push   %ebp
  800749:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80074b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80074f:	7e 14                	jle    800765 <getint+0x1d>
		return va_arg(*ap, long long);
  800751:	8b 45 08             	mov    0x8(%ebp),%eax
  800754:	8b 00                	mov    (%eax),%eax
  800756:	8d 48 08             	lea    0x8(%eax),%ecx
  800759:	8b 55 08             	mov    0x8(%ebp),%edx
  80075c:	89 0a                	mov    %ecx,(%edx)
  80075e:	8b 50 04             	mov    0x4(%eax),%edx
  800761:	8b 00                	mov    (%eax),%eax
  800763:	eb 28                	jmp    80078d <getint+0x45>
	else if (lflag)
  800765:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800769:	74 12                	je     80077d <getint+0x35>
		return va_arg(*ap, long);
  80076b:	8b 45 08             	mov    0x8(%ebp),%eax
  80076e:	8b 00                	mov    (%eax),%eax
  800770:	8d 48 04             	lea    0x4(%eax),%ecx
  800773:	8b 55 08             	mov    0x8(%ebp),%edx
  800776:	89 0a                	mov    %ecx,(%edx)
  800778:	8b 00                	mov    (%eax),%eax
  80077a:	99                   	cltd   
  80077b:	eb 10                	jmp    80078d <getint+0x45>
	else
		return va_arg(*ap, int);
  80077d:	8b 45 08             	mov    0x8(%ebp),%eax
  800780:	8b 00                	mov    (%eax),%eax
  800782:	8d 48 04             	lea    0x4(%eax),%ecx
  800785:	8b 55 08             	mov    0x8(%ebp),%edx
  800788:	89 0a                	mov    %ecx,(%edx)
  80078a:	8b 00                	mov    (%eax),%eax
  80078c:	99                   	cltd   
}
  80078d:	5d                   	pop    %ebp
  80078e:	c3                   	ret    

0080078f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	56                   	push   %esi
  800793:	53                   	push   %ebx
  800794:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800797:	eb 18                	jmp    8007b1 <vprintfmt+0x22>
			if (ch == '\0')
  800799:	85 db                	test   %ebx,%ebx
  80079b:	75 05                	jne    8007a2 <vprintfmt+0x13>
				return;
  80079d:	e9 cc 03 00 00       	jmp    800b6e <vprintfmt+0x3df>
			putch(ch, putdat);
  8007a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a9:	89 1c 24             	mov    %ebx,(%esp)
  8007ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8007af:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b4:	8d 50 01             	lea    0x1(%eax),%edx
  8007b7:	89 55 10             	mov    %edx,0x10(%ebp)
  8007ba:	0f b6 00             	movzbl (%eax),%eax
  8007bd:	0f b6 d8             	movzbl %al,%ebx
  8007c0:	83 fb 25             	cmp    $0x25,%ebx
  8007c3:	75 d4                	jne    800799 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8007c5:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8007c9:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8007d0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8007d7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8007de:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e8:	8d 50 01             	lea    0x1(%eax),%edx
  8007eb:	89 55 10             	mov    %edx,0x10(%ebp)
  8007ee:	0f b6 00             	movzbl (%eax),%eax
  8007f1:	0f b6 d8             	movzbl %al,%ebx
  8007f4:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8007f7:	83 f8 55             	cmp    $0x55,%eax
  8007fa:	0f 87 3d 03 00 00    	ja     800b3d <vprintfmt+0x3ae>
  800800:	8b 04 85 ec 15 80 00 	mov    0x8015ec(,%eax,4),%eax
  800807:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800809:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  80080d:	eb d6                	jmp    8007e5 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80080f:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800813:	eb d0                	jmp    8007e5 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800815:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  80081c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80081f:	89 d0                	mov    %edx,%eax
  800821:	c1 e0 02             	shl    $0x2,%eax
  800824:	01 d0                	add    %edx,%eax
  800826:	01 c0                	add    %eax,%eax
  800828:	01 d8                	add    %ebx,%eax
  80082a:	83 e8 30             	sub    $0x30,%eax
  80082d:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800830:	8b 45 10             	mov    0x10(%ebp),%eax
  800833:	0f b6 00             	movzbl (%eax),%eax
  800836:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800839:	83 fb 2f             	cmp    $0x2f,%ebx
  80083c:	7e 0b                	jle    800849 <vprintfmt+0xba>
  80083e:	83 fb 39             	cmp    $0x39,%ebx
  800841:	7f 06                	jg     800849 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800843:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800847:	eb d3                	jmp    80081c <vprintfmt+0x8d>
			goto process_precision;
  800849:	eb 33                	jmp    80087e <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  80084b:	8b 45 14             	mov    0x14(%ebp),%eax
  80084e:	8d 50 04             	lea    0x4(%eax),%edx
  800851:	89 55 14             	mov    %edx,0x14(%ebp)
  800854:	8b 00                	mov    (%eax),%eax
  800856:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800859:	eb 23                	jmp    80087e <vprintfmt+0xef>

		case '.':
			if (width < 0)
  80085b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80085f:	79 0c                	jns    80086d <vprintfmt+0xde>
				width = 0;
  800861:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800868:	e9 78 ff ff ff       	jmp    8007e5 <vprintfmt+0x56>
  80086d:	e9 73 ff ff ff       	jmp    8007e5 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800872:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800879:	e9 67 ff ff ff       	jmp    8007e5 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  80087e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800882:	79 12                	jns    800896 <vprintfmt+0x107>
				width = precision, precision = -1;
  800884:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800887:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80088a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800891:	e9 4f ff ff ff       	jmp    8007e5 <vprintfmt+0x56>
  800896:	e9 4a ff ff ff       	jmp    8007e5 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80089b:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  80089f:	e9 41 ff ff ff       	jmp    8007e5 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a7:	8d 50 04             	lea    0x4(%eax),%edx
  8008aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ad:	8b 00                	mov    (%eax),%eax
  8008af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008b6:	89 04 24             	mov    %eax,(%esp)
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	ff d0                	call   *%eax
			break;
  8008be:	e9 a5 02 00 00       	jmp    800b68 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c6:	8d 50 04             	lea    0x4(%eax),%edx
  8008c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8008cc:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8008ce:	85 db                	test   %ebx,%ebx
  8008d0:	79 02                	jns    8008d4 <vprintfmt+0x145>
				err = -err;
  8008d2:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8008d4:	83 fb 09             	cmp    $0x9,%ebx
  8008d7:	7f 0b                	jg     8008e4 <vprintfmt+0x155>
  8008d9:	8b 34 9d a0 15 80 00 	mov    0x8015a0(,%ebx,4),%esi
  8008e0:	85 f6                	test   %esi,%esi
  8008e2:	75 23                	jne    800907 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8008e4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8008e8:	c7 44 24 08 d9 15 80 	movl   $0x8015d9,0x8(%esp)
  8008ef:	00 
  8008f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fa:	89 04 24             	mov    %eax,(%esp)
  8008fd:	e8 73 02 00 00       	call   800b75 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800902:	e9 61 02 00 00       	jmp    800b68 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800907:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80090b:	c7 44 24 08 e2 15 80 	movl   $0x8015e2,0x8(%esp)
  800912:	00 
  800913:	8b 45 0c             	mov    0xc(%ebp),%eax
  800916:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091a:	8b 45 08             	mov    0x8(%ebp),%eax
  80091d:	89 04 24             	mov    %eax,(%esp)
  800920:	e8 50 02 00 00       	call   800b75 <printfmt>
			break;
  800925:	e9 3e 02 00 00       	jmp    800b68 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80092a:	8b 45 14             	mov    0x14(%ebp),%eax
  80092d:	8d 50 04             	lea    0x4(%eax),%edx
  800930:	89 55 14             	mov    %edx,0x14(%ebp)
  800933:	8b 30                	mov    (%eax),%esi
  800935:	85 f6                	test   %esi,%esi
  800937:	75 05                	jne    80093e <vprintfmt+0x1af>
				p = "(null)";
  800939:	be e5 15 80 00       	mov    $0x8015e5,%esi
			if (width > 0 && padc != '-')
  80093e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800942:	7e 37                	jle    80097b <vprintfmt+0x1ec>
  800944:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800948:	74 31                	je     80097b <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  80094a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80094d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800951:	89 34 24             	mov    %esi,(%esp)
  800954:	e8 39 03 00 00       	call   800c92 <strnlen>
  800959:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80095c:	eb 17                	jmp    800975 <vprintfmt+0x1e6>
					putch(padc, putdat);
  80095e:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800962:	8b 55 0c             	mov    0xc(%ebp),%edx
  800965:	89 54 24 04          	mov    %edx,0x4(%esp)
  800969:	89 04 24             	mov    %eax,(%esp)
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
  80096f:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800971:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800975:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800979:	7f e3                	jg     80095e <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80097b:	eb 38                	jmp    8009b5 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  80097d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800981:	74 1f                	je     8009a2 <vprintfmt+0x213>
  800983:	83 fb 1f             	cmp    $0x1f,%ebx
  800986:	7e 05                	jle    80098d <vprintfmt+0x1fe>
  800988:	83 fb 7e             	cmp    $0x7e,%ebx
  80098b:	7e 15                	jle    8009a2 <vprintfmt+0x213>
					putch('?', putdat);
  80098d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800990:	89 44 24 04          	mov    %eax,0x4(%esp)
  800994:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	ff d0                	call   *%eax
  8009a0:	eb 0f                	jmp    8009b1 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8009a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a9:	89 1c 24             	mov    %ebx,(%esp)
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009b1:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8009b5:	89 f0                	mov    %esi,%eax
  8009b7:	8d 70 01             	lea    0x1(%eax),%esi
  8009ba:	0f b6 00             	movzbl (%eax),%eax
  8009bd:	0f be d8             	movsbl %al,%ebx
  8009c0:	85 db                	test   %ebx,%ebx
  8009c2:	74 10                	je     8009d4 <vprintfmt+0x245>
  8009c4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009c8:	78 b3                	js     80097d <vprintfmt+0x1ee>
  8009ca:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8009ce:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009d2:	79 a9                	jns    80097d <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009d4:	eb 17                	jmp    8009ed <vprintfmt+0x25e>
				putch(' ', putdat);
  8009d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009dd:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e7:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009e9:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8009ed:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009f1:	7f e3                	jg     8009d6 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8009f3:	e9 70 01 00 00       	jmp    800b68 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800a02:	89 04 24             	mov    %eax,(%esp)
  800a05:	e8 3e fd ff ff       	call   800748 <getint>
  800a0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a0d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800a10:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a13:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a16:	85 d2                	test   %edx,%edx
  800a18:	79 26                	jns    800a40 <vprintfmt+0x2b1>
				putch('-', putdat);
  800a1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a21:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a28:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2b:	ff d0                	call   *%eax
				num = -(long long) num;
  800a2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a30:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a33:	f7 d8                	neg    %eax
  800a35:	83 d2 00             	adc    $0x0,%edx
  800a38:	f7 da                	neg    %edx
  800a3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a3d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800a40:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a47:	e9 a8 00 00 00       	jmp    800af4 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a4c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a53:	8d 45 14             	lea    0x14(%ebp),%eax
  800a56:	89 04 24             	mov    %eax,(%esp)
  800a59:	e8 9b fc ff ff       	call   8006f9 <getuint>
  800a5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a61:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800a64:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a6b:	e9 84 00 00 00       	jmp    800af4 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a70:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a73:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a77:	8d 45 14             	lea    0x14(%ebp),%eax
  800a7a:	89 04 24             	mov    %eax,(%esp)
  800a7d:	e8 77 fc ff ff       	call   8006f9 <getuint>
  800a82:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a85:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800a88:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800a8f:	eb 63                	jmp    800af4 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a91:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a94:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a98:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa2:	ff d0                	call   *%eax
			putch('x', putdat);
  800aa4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aab:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab5:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800ab7:	8b 45 14             	mov    0x14(%ebp),%eax
  800aba:	8d 50 04             	lea    0x4(%eax),%edx
  800abd:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac0:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800ac2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ac5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800acc:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800ad3:	eb 1f                	jmp    800af4 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800ad5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ad8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800adc:	8d 45 14             	lea    0x14(%ebp),%eax
  800adf:	89 04 24             	mov    %eax,(%esp)
  800ae2:	e8 12 fc ff ff       	call   8006f9 <getuint>
  800ae7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800aea:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800aed:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800af4:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800af8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800afb:	89 54 24 18          	mov    %edx,0x18(%esp)
  800aff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b02:	89 54 24 14          	mov    %edx,0x14(%esp)
  800b06:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b10:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b14:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b22:	89 04 24             	mov    %eax,(%esp)
  800b25:	e8 f1 fa ff ff       	call   80061b <printnum>
			break;
  800b2a:	eb 3c                	jmp    800b68 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b33:	89 1c 24             	mov    %ebx,(%esp)
  800b36:	8b 45 08             	mov    0x8(%ebp),%eax
  800b39:	ff d0                	call   *%eax
			break;
  800b3b:	eb 2b                	jmp    800b68 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b40:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b44:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4e:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b50:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b54:	eb 04                	jmp    800b5a <vprintfmt+0x3cb>
  800b56:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b5a:	8b 45 10             	mov    0x10(%ebp),%eax
  800b5d:	83 e8 01             	sub    $0x1,%eax
  800b60:	0f b6 00             	movzbl (%eax),%eax
  800b63:	3c 25                	cmp    $0x25,%al
  800b65:	75 ef                	jne    800b56 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800b67:	90                   	nop
		}
	}
  800b68:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b69:	e9 43 fc ff ff       	jmp    8007b1 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800b6e:	83 c4 40             	add    $0x40,%esp
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b7b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b84:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b88:	8b 45 10             	mov    0x10(%ebp),%eax
  800b8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b92:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b96:	8b 45 08             	mov    0x8(%ebp),%eax
  800b99:	89 04 24             	mov    %eax,(%esp)
  800b9c:	e8 ee fb ff ff       	call   80078f <vprintfmt>
	va_end(ap);
}
  800ba1:	c9                   	leave  
  800ba2:	c3                   	ret    

00800ba3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800ba6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba9:	8b 40 08             	mov    0x8(%eax),%eax
  800bac:	8d 50 01             	lea    0x1(%eax),%edx
  800baf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb2:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800bb5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb8:	8b 10                	mov    (%eax),%edx
  800bba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbd:	8b 40 04             	mov    0x4(%eax),%eax
  800bc0:	39 c2                	cmp    %eax,%edx
  800bc2:	73 12                	jae    800bd6 <sprintputch+0x33>
		*b->buf++ = ch;
  800bc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc7:	8b 00                	mov    (%eax),%eax
  800bc9:	8d 48 01             	lea    0x1(%eax),%ecx
  800bcc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bcf:	89 0a                	mov    %ecx,(%edx)
  800bd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd4:	88 10                	mov    %dl,(%eax)
}
  800bd6:	5d                   	pop    %ebp
  800bd7:	c3                   	ret    

00800bd8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bde:	8b 45 08             	mov    0x8(%ebp),%eax
  800be1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800be4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be7:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bea:	8b 45 08             	mov    0x8(%ebp),%eax
  800bed:	01 d0                	add    %edx,%eax
  800bef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800bf2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bf9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800bfd:	74 06                	je     800c05 <vsnprintf+0x2d>
  800bff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c03:	7f 07                	jg     800c0c <vsnprintf+0x34>
		return -E_INVAL;
  800c05:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c0a:	eb 2a                	jmp    800c36 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c0c:	8b 45 14             	mov    0x14(%ebp),%eax
  800c0f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c13:	8b 45 10             	mov    0x10(%ebp),%eax
  800c16:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c1a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c21:	c7 04 24 a3 0b 80 00 	movl   $0x800ba3,(%esp)
  800c28:	e8 62 fb ff ff       	call   80078f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c30:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c36:	c9                   	leave  
  800c37:	c3                   	ret    

00800c38 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c3e:	8d 45 14             	lea    0x14(%ebp),%eax
  800c41:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800c44:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c47:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c4b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c4e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c55:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c59:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5c:	89 04 24             	mov    %eax,(%esp)
  800c5f:	e8 74 ff ff ff       	call   800bd8 <vsnprintf>
  800c64:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800c67:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c6a:	c9                   	leave  
  800c6b:	c3                   	ret    

00800c6c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800c72:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c79:	eb 08                	jmp    800c83 <strlen+0x17>
		n++;
  800c7b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c7f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c83:	8b 45 08             	mov    0x8(%ebp),%eax
  800c86:	0f b6 00             	movzbl (%eax),%eax
  800c89:	84 c0                	test   %al,%al
  800c8b:	75 ee                	jne    800c7b <strlen+0xf>
		n++;
	return n;
  800c8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c90:	c9                   	leave  
  800c91:	c3                   	ret    

00800c92 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c98:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c9f:	eb 0c                	jmp    800cad <strnlen+0x1b>
		n++;
  800ca1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ca5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ca9:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800cad:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cb1:	74 0a                	je     800cbd <strnlen+0x2b>
  800cb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb6:	0f b6 00             	movzbl (%eax),%eax
  800cb9:	84 c0                	test   %al,%al
  800cbb:	75 e4                	jne    800ca1 <strnlen+0xf>
		n++;
	return n;
  800cbd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800cc0:	c9                   	leave  
  800cc1:	c3                   	ret    

00800cc2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccb:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800cce:	90                   	nop
  800ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd2:	8d 50 01             	lea    0x1(%eax),%edx
  800cd5:	89 55 08             	mov    %edx,0x8(%ebp)
  800cd8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cdb:	8d 4a 01             	lea    0x1(%edx),%ecx
  800cde:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800ce1:	0f b6 12             	movzbl (%edx),%edx
  800ce4:	88 10                	mov    %dl,(%eax)
  800ce6:	0f b6 00             	movzbl (%eax),%eax
  800ce9:	84 c0                	test   %al,%al
  800ceb:	75 e2                	jne    800ccf <strcpy+0xd>
		/* do nothing */;
	return ret;
  800ced:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800cf0:	c9                   	leave  
  800cf1:	c3                   	ret    

00800cf2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cf2:	55                   	push   %ebp
  800cf3:	89 e5                	mov    %esp,%ebp
  800cf5:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfb:	89 04 24             	mov    %eax,(%esp)
  800cfe:	e8 69 ff ff ff       	call   800c6c <strlen>
  800d03:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800d06:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800d09:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0c:	01 c2                	add    %eax,%edx
  800d0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d11:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d15:	89 14 24             	mov    %edx,(%esp)
  800d18:	e8 a5 ff ff ff       	call   800cc2 <strcpy>
	return dst;
  800d1d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d20:	c9                   	leave  
  800d21:	c3                   	ret    

00800d22 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800d28:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2b:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800d2e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800d35:	eb 23                	jmp    800d5a <strncpy+0x38>
		*dst++ = *src;
  800d37:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3a:	8d 50 01             	lea    0x1(%eax),%edx
  800d3d:	89 55 08             	mov    %edx,0x8(%ebp)
  800d40:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d43:	0f b6 12             	movzbl (%edx),%edx
  800d46:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800d48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d4b:	0f b6 00             	movzbl (%eax),%eax
  800d4e:	84 c0                	test   %al,%al
  800d50:	74 04                	je     800d56 <strncpy+0x34>
			src++;
  800d52:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d56:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d5a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d5d:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d60:	72 d5                	jb     800d37 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800d62:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d65:	c9                   	leave  
  800d66:	c3                   	ret    

00800d67 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800d6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d70:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800d73:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d77:	74 33                	je     800dac <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d79:	eb 17                	jmp    800d92 <strlcpy+0x2b>
			*dst++ = *src++;
  800d7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7e:	8d 50 01             	lea    0x1(%eax),%edx
  800d81:	89 55 08             	mov    %edx,0x8(%ebp)
  800d84:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d87:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d8a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d8d:	0f b6 12             	movzbl (%edx),%edx
  800d90:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d92:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d96:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d9a:	74 0a                	je     800da6 <strlcpy+0x3f>
  800d9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d9f:	0f b6 00             	movzbl (%eax),%eax
  800da2:	84 c0                	test   %al,%al
  800da4:	75 d5                	jne    800d7b <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800da6:	8b 45 08             	mov    0x8(%ebp),%eax
  800da9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800dac:	8b 55 08             	mov    0x8(%ebp),%edx
  800daf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800db2:	29 c2                	sub    %eax,%edx
  800db4:	89 d0                	mov    %edx,%eax
}
  800db6:	c9                   	leave  
  800db7:	c3                   	ret    

00800db8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800dbb:	eb 08                	jmp    800dc5 <strcmp+0xd>
		p++, q++;
  800dbd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dc1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800dc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc8:	0f b6 00             	movzbl (%eax),%eax
  800dcb:	84 c0                	test   %al,%al
  800dcd:	74 10                	je     800ddf <strcmp+0x27>
  800dcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd2:	0f b6 10             	movzbl (%eax),%edx
  800dd5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd8:	0f b6 00             	movzbl (%eax),%eax
  800ddb:	38 c2                	cmp    %al,%dl
  800ddd:	74 de                	je     800dbd <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ddf:	8b 45 08             	mov    0x8(%ebp),%eax
  800de2:	0f b6 00             	movzbl (%eax),%eax
  800de5:	0f b6 d0             	movzbl %al,%edx
  800de8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800deb:	0f b6 00             	movzbl (%eax),%eax
  800dee:	0f b6 c0             	movzbl %al,%eax
  800df1:	29 c2                	sub    %eax,%edx
  800df3:	89 d0                	mov    %edx,%eax
}
  800df5:	5d                   	pop    %ebp
  800df6:	c3                   	ret    

00800df7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800dfa:	eb 0c                	jmp    800e08 <strncmp+0x11>
		n--, p++, q++;
  800dfc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800e00:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e04:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e08:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e0c:	74 1a                	je     800e28 <strncmp+0x31>
  800e0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e11:	0f b6 00             	movzbl (%eax),%eax
  800e14:	84 c0                	test   %al,%al
  800e16:	74 10                	je     800e28 <strncmp+0x31>
  800e18:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1b:	0f b6 10             	movzbl (%eax),%edx
  800e1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e21:	0f b6 00             	movzbl (%eax),%eax
  800e24:	38 c2                	cmp    %al,%dl
  800e26:	74 d4                	je     800dfc <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800e28:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e2c:	75 07                	jne    800e35 <strncmp+0x3e>
		return 0;
  800e2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e33:	eb 16                	jmp    800e4b <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e35:	8b 45 08             	mov    0x8(%ebp),%eax
  800e38:	0f b6 00             	movzbl (%eax),%eax
  800e3b:	0f b6 d0             	movzbl %al,%edx
  800e3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e41:	0f b6 00             	movzbl (%eax),%eax
  800e44:	0f b6 c0             	movzbl %al,%eax
  800e47:	29 c2                	sub    %eax,%edx
  800e49:	89 d0                	mov    %edx,%eax
}
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	83 ec 04             	sub    $0x4,%esp
  800e53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e56:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e59:	eb 14                	jmp    800e6f <strchr+0x22>
		if (*s == c)
  800e5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5e:	0f b6 00             	movzbl (%eax),%eax
  800e61:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e64:	75 05                	jne    800e6b <strchr+0x1e>
			return (char *) s;
  800e66:	8b 45 08             	mov    0x8(%ebp),%eax
  800e69:	eb 13                	jmp    800e7e <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e6b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e72:	0f b6 00             	movzbl (%eax),%eax
  800e75:	84 c0                	test   %al,%al
  800e77:	75 e2                	jne    800e5b <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e79:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e7e:	c9                   	leave  
  800e7f:	c3                   	ret    

00800e80 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	83 ec 04             	sub    $0x4,%esp
  800e86:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e89:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e8c:	eb 11                	jmp    800e9f <strfind+0x1f>
		if (*s == c)
  800e8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e91:	0f b6 00             	movzbl (%eax),%eax
  800e94:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e97:	75 02                	jne    800e9b <strfind+0x1b>
			break;
  800e99:	eb 0e                	jmp    800ea9 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e9b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea2:	0f b6 00             	movzbl (%eax),%eax
  800ea5:	84 c0                	test   %al,%al
  800ea7:	75 e5                	jne    800e8e <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800ea9:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800eac:	c9                   	leave  
  800ead:	c3                   	ret    

00800eae <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	57                   	push   %edi
	char *p;

	if (n == 0)
  800eb2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800eb6:	75 05                	jne    800ebd <memset+0xf>
		return v;
  800eb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebb:	eb 5c                	jmp    800f19 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800ebd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec0:	83 e0 03             	and    $0x3,%eax
  800ec3:	85 c0                	test   %eax,%eax
  800ec5:	75 41                	jne    800f08 <memset+0x5a>
  800ec7:	8b 45 10             	mov    0x10(%ebp),%eax
  800eca:	83 e0 03             	and    $0x3,%eax
  800ecd:	85 c0                	test   %eax,%eax
  800ecf:	75 37                	jne    800f08 <memset+0x5a>
		c &= 0xFF;
  800ed1:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ed8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800edb:	c1 e0 18             	shl    $0x18,%eax
  800ede:	89 c2                	mov    %eax,%edx
  800ee0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee3:	c1 e0 10             	shl    $0x10,%eax
  800ee6:	09 c2                	or     %eax,%edx
  800ee8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eeb:	c1 e0 08             	shl    $0x8,%eax
  800eee:	09 d0                	or     %edx,%eax
  800ef0:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ef3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ef6:	c1 e8 02             	shr    $0x2,%eax
  800ef9:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800efb:	8b 55 08             	mov    0x8(%ebp),%edx
  800efe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f01:	89 d7                	mov    %edx,%edi
  800f03:	fc                   	cld    
  800f04:	f3 ab                	rep stos %eax,%es:(%edi)
  800f06:	eb 0e                	jmp    800f16 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f08:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f11:	89 d7                	mov    %edx,%edi
  800f13:	fc                   	cld    
  800f14:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800f16:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f19:	5f                   	pop    %edi
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    

00800f1c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	57                   	push   %edi
  800f20:	56                   	push   %esi
  800f21:	53                   	push   %ebx
  800f22:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800f25:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f28:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800f2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2e:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800f31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f34:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f37:	73 6d                	jae    800fa6 <memmove+0x8a>
  800f39:	8b 45 10             	mov    0x10(%ebp),%eax
  800f3c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f3f:	01 d0                	add    %edx,%eax
  800f41:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f44:	76 60                	jbe    800fa6 <memmove+0x8a>
		s += n;
  800f46:	8b 45 10             	mov    0x10(%ebp),%eax
  800f49:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800f4c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f4f:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f55:	83 e0 03             	and    $0x3,%eax
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	75 2f                	jne    800f8b <memmove+0x6f>
  800f5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f5f:	83 e0 03             	and    $0x3,%eax
  800f62:	85 c0                	test   %eax,%eax
  800f64:	75 25                	jne    800f8b <memmove+0x6f>
  800f66:	8b 45 10             	mov    0x10(%ebp),%eax
  800f69:	83 e0 03             	and    $0x3,%eax
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	75 1b                	jne    800f8b <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f70:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f73:	83 e8 04             	sub    $0x4,%eax
  800f76:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f79:	83 ea 04             	sub    $0x4,%edx
  800f7c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f7f:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f82:	89 c7                	mov    %eax,%edi
  800f84:	89 d6                	mov    %edx,%esi
  800f86:	fd                   	std    
  800f87:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f89:	eb 18                	jmp    800fa3 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f8e:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f91:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f94:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f97:	8b 45 10             	mov    0x10(%ebp),%eax
  800f9a:	89 d7                	mov    %edx,%edi
  800f9c:	89 de                	mov    %ebx,%esi
  800f9e:	89 c1                	mov    %eax,%ecx
  800fa0:	fd                   	std    
  800fa1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fa3:	fc                   	cld    
  800fa4:	eb 45                	jmp    800feb <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fa9:	83 e0 03             	and    $0x3,%eax
  800fac:	85 c0                	test   %eax,%eax
  800fae:	75 2b                	jne    800fdb <memmove+0xbf>
  800fb0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fb3:	83 e0 03             	and    $0x3,%eax
  800fb6:	85 c0                	test   %eax,%eax
  800fb8:	75 21                	jne    800fdb <memmove+0xbf>
  800fba:	8b 45 10             	mov    0x10(%ebp),%eax
  800fbd:	83 e0 03             	and    $0x3,%eax
  800fc0:	85 c0                	test   %eax,%eax
  800fc2:	75 17                	jne    800fdb <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800fc4:	8b 45 10             	mov    0x10(%ebp),%eax
  800fc7:	c1 e8 02             	shr    $0x2,%eax
  800fca:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800fcc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fcf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fd2:	89 c7                	mov    %eax,%edi
  800fd4:	89 d6                	mov    %edx,%esi
  800fd6:	fc                   	cld    
  800fd7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fd9:	eb 10                	jmp    800feb <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fdb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fde:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fe1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fe4:	89 c7                	mov    %eax,%edi
  800fe6:	89 d6                	mov    %edx,%esi
  800fe8:	fc                   	cld    
  800fe9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800feb:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800fee:	83 c4 10             	add    $0x10,%esp
  800ff1:	5b                   	pop    %ebx
  800ff2:	5e                   	pop    %esi
  800ff3:	5f                   	pop    %edi
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    

00800ff6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ffc:	8b 45 10             	mov    0x10(%ebp),%eax
  800fff:	89 44 24 08          	mov    %eax,0x8(%esp)
  801003:	8b 45 0c             	mov    0xc(%ebp),%eax
  801006:	89 44 24 04          	mov    %eax,0x4(%esp)
  80100a:	8b 45 08             	mov    0x8(%ebp),%eax
  80100d:	89 04 24             	mov    %eax,(%esp)
  801010:	e8 07 ff ff ff       	call   800f1c <memmove>
}
  801015:	c9                   	leave  
  801016:	c3                   	ret    

00801017 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801017:	55                   	push   %ebp
  801018:	89 e5                	mov    %esp,%ebp
  80101a:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  80101d:	8b 45 08             	mov    0x8(%ebp),%eax
  801020:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  801023:	8b 45 0c             	mov    0xc(%ebp),%eax
  801026:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  801029:	eb 30                	jmp    80105b <memcmp+0x44>
		if (*s1 != *s2)
  80102b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80102e:	0f b6 10             	movzbl (%eax),%edx
  801031:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801034:	0f b6 00             	movzbl (%eax),%eax
  801037:	38 c2                	cmp    %al,%dl
  801039:	74 18                	je     801053 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  80103b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80103e:	0f b6 00             	movzbl (%eax),%eax
  801041:	0f b6 d0             	movzbl %al,%edx
  801044:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801047:	0f b6 00             	movzbl (%eax),%eax
  80104a:	0f b6 c0             	movzbl %al,%eax
  80104d:	29 c2                	sub    %eax,%edx
  80104f:	89 d0                	mov    %edx,%eax
  801051:	eb 1a                	jmp    80106d <memcmp+0x56>
		s1++, s2++;
  801053:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  801057:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80105b:	8b 45 10             	mov    0x10(%ebp),%eax
  80105e:	8d 50 ff             	lea    -0x1(%eax),%edx
  801061:	89 55 10             	mov    %edx,0x10(%ebp)
  801064:	85 c0                	test   %eax,%eax
  801066:	75 c3                	jne    80102b <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801068:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80106d:	c9                   	leave  
  80106e:	c3                   	ret    

0080106f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80106f:	55                   	push   %ebp
  801070:	89 e5                	mov    %esp,%ebp
  801072:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  801075:	8b 45 10             	mov    0x10(%ebp),%eax
  801078:	8b 55 08             	mov    0x8(%ebp),%edx
  80107b:	01 d0                	add    %edx,%eax
  80107d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801080:	eb 13                	jmp    801095 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801082:	8b 45 08             	mov    0x8(%ebp),%eax
  801085:	0f b6 10             	movzbl (%eax),%edx
  801088:	8b 45 0c             	mov    0xc(%ebp),%eax
  80108b:	38 c2                	cmp    %al,%dl
  80108d:	75 02                	jne    801091 <memfind+0x22>
			break;
  80108f:	eb 0c                	jmp    80109d <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801091:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801095:	8b 45 08             	mov    0x8(%ebp),%eax
  801098:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  80109b:	72 e5                	jb     801082 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  80109d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8010a0:	c9                   	leave  
  8010a1:	c3                   	ret    

008010a2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  8010a8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  8010af:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010b6:	eb 04                	jmp    8010bc <strtol+0x1a>
		s++;
  8010b8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010bf:	0f b6 00             	movzbl (%eax),%eax
  8010c2:	3c 20                	cmp    $0x20,%al
  8010c4:	74 f2                	je     8010b8 <strtol+0x16>
  8010c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c9:	0f b6 00             	movzbl (%eax),%eax
  8010cc:	3c 09                	cmp    $0x9,%al
  8010ce:	74 e8                	je     8010b8 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  8010d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d3:	0f b6 00             	movzbl (%eax),%eax
  8010d6:	3c 2b                	cmp    $0x2b,%al
  8010d8:	75 06                	jne    8010e0 <strtol+0x3e>
		s++;
  8010da:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010de:	eb 15                	jmp    8010f5 <strtol+0x53>
	else if (*s == '-')
  8010e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e3:	0f b6 00             	movzbl (%eax),%eax
  8010e6:	3c 2d                	cmp    $0x2d,%al
  8010e8:	75 0b                	jne    8010f5 <strtol+0x53>
		s++, neg = 1;
  8010ea:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010ee:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010f5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010f9:	74 06                	je     801101 <strtol+0x5f>
  8010fb:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8010ff:	75 24                	jne    801125 <strtol+0x83>
  801101:	8b 45 08             	mov    0x8(%ebp),%eax
  801104:	0f b6 00             	movzbl (%eax),%eax
  801107:	3c 30                	cmp    $0x30,%al
  801109:	75 1a                	jne    801125 <strtol+0x83>
  80110b:	8b 45 08             	mov    0x8(%ebp),%eax
  80110e:	83 c0 01             	add    $0x1,%eax
  801111:	0f b6 00             	movzbl (%eax),%eax
  801114:	3c 78                	cmp    $0x78,%al
  801116:	75 0d                	jne    801125 <strtol+0x83>
		s += 2, base = 16;
  801118:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  80111c:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  801123:	eb 2a                	jmp    80114f <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  801125:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801129:	75 17                	jne    801142 <strtol+0xa0>
  80112b:	8b 45 08             	mov    0x8(%ebp),%eax
  80112e:	0f b6 00             	movzbl (%eax),%eax
  801131:	3c 30                	cmp    $0x30,%al
  801133:	75 0d                	jne    801142 <strtol+0xa0>
		s++, base = 8;
  801135:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801139:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801140:	eb 0d                	jmp    80114f <strtol+0xad>
	else if (base == 0)
  801142:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801146:	75 07                	jne    80114f <strtol+0xad>
		base = 10;
  801148:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80114f:	8b 45 08             	mov    0x8(%ebp),%eax
  801152:	0f b6 00             	movzbl (%eax),%eax
  801155:	3c 2f                	cmp    $0x2f,%al
  801157:	7e 1b                	jle    801174 <strtol+0xd2>
  801159:	8b 45 08             	mov    0x8(%ebp),%eax
  80115c:	0f b6 00             	movzbl (%eax),%eax
  80115f:	3c 39                	cmp    $0x39,%al
  801161:	7f 11                	jg     801174 <strtol+0xd2>
			dig = *s - '0';
  801163:	8b 45 08             	mov    0x8(%ebp),%eax
  801166:	0f b6 00             	movzbl (%eax),%eax
  801169:	0f be c0             	movsbl %al,%eax
  80116c:	83 e8 30             	sub    $0x30,%eax
  80116f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801172:	eb 48                	jmp    8011bc <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  801174:	8b 45 08             	mov    0x8(%ebp),%eax
  801177:	0f b6 00             	movzbl (%eax),%eax
  80117a:	3c 60                	cmp    $0x60,%al
  80117c:	7e 1b                	jle    801199 <strtol+0xf7>
  80117e:	8b 45 08             	mov    0x8(%ebp),%eax
  801181:	0f b6 00             	movzbl (%eax),%eax
  801184:	3c 7a                	cmp    $0x7a,%al
  801186:	7f 11                	jg     801199 <strtol+0xf7>
			dig = *s - 'a' + 10;
  801188:	8b 45 08             	mov    0x8(%ebp),%eax
  80118b:	0f b6 00             	movzbl (%eax),%eax
  80118e:	0f be c0             	movsbl %al,%eax
  801191:	83 e8 57             	sub    $0x57,%eax
  801194:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801197:	eb 23                	jmp    8011bc <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  801199:	8b 45 08             	mov    0x8(%ebp),%eax
  80119c:	0f b6 00             	movzbl (%eax),%eax
  80119f:	3c 40                	cmp    $0x40,%al
  8011a1:	7e 3d                	jle    8011e0 <strtol+0x13e>
  8011a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a6:	0f b6 00             	movzbl (%eax),%eax
  8011a9:	3c 5a                	cmp    $0x5a,%al
  8011ab:	7f 33                	jg     8011e0 <strtol+0x13e>
			dig = *s - 'A' + 10;
  8011ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b0:	0f b6 00             	movzbl (%eax),%eax
  8011b3:	0f be c0             	movsbl %al,%eax
  8011b6:	83 e8 37             	sub    $0x37,%eax
  8011b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  8011bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011bf:	3b 45 10             	cmp    0x10(%ebp),%eax
  8011c2:	7c 02                	jl     8011c6 <strtol+0x124>
			break;
  8011c4:	eb 1a                	jmp    8011e0 <strtol+0x13e>
		s++, val = (val * base) + dig;
  8011c6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8011ca:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011cd:	0f af 45 10          	imul   0x10(%ebp),%eax
  8011d1:	89 c2                	mov    %eax,%edx
  8011d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011d6:	01 d0                	add    %edx,%eax
  8011d8:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  8011db:	e9 6f ff ff ff       	jmp    80114f <strtol+0xad>

	if (endptr)
  8011e0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011e4:	74 08                	je     8011ee <strtol+0x14c>
		*endptr = (char *) s;
  8011e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ec:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8011ee:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8011f2:	74 07                	je     8011fb <strtol+0x159>
  8011f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011f7:	f7 d8                	neg    %eax
  8011f9:	eb 03                	jmp    8011fe <strtol+0x15c>
  8011fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8011fe:	c9                   	leave  
  8011ff:	c3                   	ret    

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
