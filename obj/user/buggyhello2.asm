
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	sys_cputs(hello, 1024*1024);
  800039:	a1 00 20 80 00       	mov    0x802000,%eax
  80003e:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800045:	00 
  800046:	89 04 24             	mov    %eax,(%esp)
  800049:	e8 b6 00 00 00       	call   800104 <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800056:	e8 72 01 00 00       	call   8001cd <sys_getenvid>
  80005b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800060:	c1 e0 02             	shl    $0x2,%eax
  800063:	89 c2                	mov    %eax,%edx
  800065:	c1 e2 05             	shl    $0x5,%edx
  800068:	29 c2                	sub    %eax,%edx
  80006a:	89 d0                	mov    %edx,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 08 20 80 00       	mov    %eax,0x802008
	// save the name of the program so that panic() can use it
	// if (argc > 0)
	// 	binaryname = argv[0];

	// call user main routine
	umain(argc, argv);
  800076:	8b 45 0c             	mov    0xc(%ebp),%eax
  800079:	89 44 24 04          	mov    %eax,0x4(%esp)
  80007d:	8b 45 08             	mov    0x8(%ebp),%eax
  800080:	89 04 24             	mov    %eax,(%esp)
  800083:	e8 ab ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800088:	e8 02 00 00 00       	call   80008f <exit>
}
  80008d:	c9                   	leave  
  80008e:	c3                   	ret    

0080008f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008f:	55                   	push   %ebp
  800090:	89 e5                	mov    %esp,%ebp
  800092:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800095:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80009c:	e8 e9 00 00 00       	call   80018a <sys_env_destroy>
}
  8000a1:	c9                   	leave  
  8000a2:	c3                   	ret    

008000a3 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000a3:	55                   	push   %ebp
  8000a4:	89 e5                	mov    %esp,%ebp
  8000a6:	57                   	push   %edi
  8000a7:	56                   	push   %esi
  8000a8:	53                   	push   %ebx
  8000a9:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8000af:	8b 55 10             	mov    0x10(%ebp),%edx
  8000b2:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8000b5:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8000b8:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  8000bb:	8b 75 20             	mov    0x20(%ebp),%esi
  8000be:	cd 30                	int    $0x30
  8000c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000c3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8000c7:	74 30                	je     8000f9 <syscall+0x56>
  8000c9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000cd:	7e 2a                	jle    8000f9 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000d2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8000d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000dd:	c7 44 24 08 d8 14 80 	movl   $0x8014d8,0x8(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000ec:	00 
  8000ed:	c7 04 24 f5 14 80 00 	movl   $0x8014f5,(%esp)
  8000f4:	e8 f7 03 00 00       	call   8004f0 <_panic>

	return ret;
  8000f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8000fc:	83 c4 3c             	add    $0x3c,%esp
  8000ff:	5b                   	pop    %ebx
  800100:	5e                   	pop    %esi
  800101:	5f                   	pop    %edi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80010a:	8b 45 08             	mov    0x8(%ebp),%eax
  80010d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800114:	00 
  800115:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80011c:	00 
  80011d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800124:	00 
  800125:	8b 55 0c             	mov    0xc(%ebp),%edx
  800128:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80012c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800130:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800137:	00 
  800138:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80013f:	e8 5f ff ff ff       	call   8000a3 <syscall>
}
  800144:	c9                   	leave  
  800145:	c3                   	ret    

00800146 <sys_cgetc>:

int
sys_cgetc(void)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80014c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800153:	00 
  800154:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80015b:	00 
  80015c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800163:	00 
  800164:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80016b:	00 
  80016c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800173:	00 
  800174:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80017b:	00 
  80017c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800183:	e8 1b ff ff ff       	call   8000a3 <syscall>
}
  800188:	c9                   	leave  
  800189:	c3                   	ret    

0080018a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80018a:	55                   	push   %ebp
  80018b:	89 e5                	mov    %esp,%ebp
  80018d:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800190:	8b 45 08             	mov    0x8(%ebp),%eax
  800193:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80019a:	00 
  80019b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001a2:	00 
  8001a3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001aa:	00 
  8001ab:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001b2:	00 
  8001b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001be:	00 
  8001bf:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8001c6:	e8 d8 fe ff ff       	call   8000a3 <syscall>
}
  8001cb:	c9                   	leave  
  8001cc:	c3                   	ret    

008001cd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8001d3:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001da:	00 
  8001db:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001e2:	00 
  8001e3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001ea:	00 
  8001eb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001f2:	00 
  8001f3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001fa:	00 
  8001fb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800202:	00 
  800203:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80020a:	e8 94 fe ff ff       	call   8000a3 <syscall>
}
  80020f:	c9                   	leave  
  800210:	c3                   	ret    

00800211 <sys_yield>:

void
sys_yield(void)
{
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
  800214:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800217:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80021e:	00 
  80021f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800226:	00 
  800227:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80022e:	00 
  80022f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800236:	00 
  800237:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80023e:	00 
  80023f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800246:	00 
  800247:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80024e:	e8 50 fe ff ff       	call   8000a3 <syscall>
}
  800253:	c9                   	leave  
  800254:	c3                   	ret    

00800255 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800255:	55                   	push   %ebp
  800256:	89 e5                	mov    %esp,%ebp
  800258:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80025b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80025e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800261:	8b 45 08             	mov    0x8(%ebp),%eax
  800264:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80026b:	00 
  80026c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800273:	00 
  800274:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800278:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80027c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800280:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800287:	00 
  800288:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  80028f:	e8 0f fe ff ff       	call   8000a3 <syscall>
}
  800294:	c9                   	leave  
  800295:	c3                   	ret    

00800296 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	56                   	push   %esi
  80029a:	53                   	push   %ebx
  80029b:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  80029e:	8b 75 18             	mov    0x18(%ebp),%esi
  8002a1:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ad:	89 74 24 18          	mov    %esi,0x18(%esp)
  8002b1:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002b5:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002b9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002c8:	00 
  8002c9:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8002d0:	e8 ce fd ff ff       	call   8000a3 <syscall>
}
  8002d5:	83 c4 20             	add    $0x20,%esp
  8002d8:	5b                   	pop    %ebx
  8002d9:	5e                   	pop    %esi
  8002da:	5d                   	pop    %ebp
  8002db:	c3                   	ret    

008002dc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
  8002df:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8002e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e8:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8002ef:	00 
  8002f0:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8002f7:	00 
  8002f8:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8002ff:	00 
  800300:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800304:	89 44 24 08          	mov    %eax,0x8(%esp)
  800308:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80030f:	00 
  800310:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  800317:	e8 87 fd ff ff       	call   8000a3 <syscall>
}
  80031c:	c9                   	leave  
  80031d:	c3                   	ret    

0080031e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80031e:	55                   	push   %ebp
  80031f:	89 e5                	mov    %esp,%ebp
  800321:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800324:	8b 55 0c             	mov    0xc(%ebp),%edx
  800327:	8b 45 08             	mov    0x8(%ebp),%eax
  80032a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800331:	00 
  800332:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800339:	00 
  80033a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800341:	00 
  800342:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800346:	89 44 24 08          	mov    %eax,0x8(%esp)
  80034a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800351:	00 
  800352:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800359:	e8 45 fd ff ff       	call   8000a3 <syscall>
}
  80035e:	c9                   	leave  
  80035f:	c3                   	ret    

00800360 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800366:	8b 55 0c             	mov    0xc(%ebp),%edx
  800369:	8b 45 08             	mov    0x8(%ebp),%eax
  80036c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800373:	00 
  800374:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80037b:	00 
  80037c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800383:	00 
  800384:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800388:	89 44 24 08          	mov    %eax,0x8(%esp)
  80038c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800393:	00 
  800394:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  80039b:	e8 03 fd ff ff       	call   8000a3 <syscall>
}
  8003a0:	c9                   	leave  
  8003a1:	c3                   	ret    

008003a2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003a2:	55                   	push   %ebp
  8003a3:	89 e5                	mov    %esp,%ebp
  8003a5:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8003a8:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003ab:	8b 55 10             	mov    0x10(%ebp),%edx
  8003ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b1:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003b8:	00 
  8003b9:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8003bd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003cc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003d3:	00 
  8003d4:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8003db:	e8 c3 fc ff ff       	call   8000a3 <syscall>
}
  8003e0:	c9                   	leave  
  8003e1:	c3                   	ret    

008003e2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003e2:	55                   	push   %ebp
  8003e3:	89 e5                	mov    %esp,%ebp
  8003e5:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8003e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003eb:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003f2:	00 
  8003f3:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8003fa:	00 
  8003fb:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800402:	00 
  800403:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80040a:	00 
  80040b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80040f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800416:	00 
  800417:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  80041e:	e8 80 fc ff ff       	call   8000a3 <syscall>
}
  800423:	c9                   	leave  
  800424:	c3                   	ret    

00800425 <sys_exec>:

void sys_exec(char* buf){
  800425:	55                   	push   %ebp
  800426:	89 e5                	mov    %esp,%ebp
  800428:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  80042b:	8b 45 08             	mov    0x8(%ebp),%eax
  80042e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800435:	00 
  800436:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80043d:	00 
  80043e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800445:	00 
  800446:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80044d:	00 
  80044e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800452:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800459:	00 
  80045a:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  800461:	e8 3d fc ff ff       	call   8000a3 <syscall>
}
  800466:	c9                   	leave  
  800467:	c3                   	ret    

00800468 <sys_wait>:

void sys_wait(){
  800468:	55                   	push   %ebp
  800469:	89 e5                	mov    %esp,%ebp
  80046b:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_wait, 0, 0, 0, 0, 0, 0);
  80046e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800475:	00 
  800476:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80047d:	00 
  80047e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800485:	00 
  800486:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80048d:	00 
  80048e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800495:	00 
  800496:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80049d:	00 
  80049e:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  8004a5:	e8 f9 fb ff ff       	call   8000a3 <syscall>
}
  8004aa:	c9                   	leave  
  8004ab:	c3                   	ret    

008004ac <sys_guest>:

void sys_guest(){
  8004ac:	55                   	push   %ebp
  8004ad:	89 e5                	mov    %esp,%ebp
  8004af:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_guest, 0, 0, 0, 0, 0, 0);
  8004b2:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8004b9:	00 
  8004ba:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8004c1:	00 
  8004c2:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8004c9:	00 
  8004ca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004d1:	00 
  8004d2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004d9:	00 
  8004da:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004e1:	00 
  8004e2:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
  8004e9:	e8 b5 fb ff ff       	call   8000a3 <syscall>
  8004ee:	c9                   	leave  
  8004ef:	c3                   	ret    

008004f0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
  8004f3:	53                   	push   %ebx
  8004f4:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8004f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8004fa:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004fd:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  800503:	e8 c5 fc ff ff       	call   8001cd <sys_getenvid>
  800508:	8b 55 0c             	mov    0xc(%ebp),%edx
  80050b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80050f:	8b 55 08             	mov    0x8(%ebp),%edx
  800512:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800516:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80051a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051e:	c7 04 24 04 15 80 00 	movl   $0x801504,(%esp)
  800525:	e8 e1 00 00 00       	call   80060b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80052a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80052d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800531:	8b 45 10             	mov    0x10(%ebp),%eax
  800534:	89 04 24             	mov    %eax,(%esp)
  800537:	e8 6b 00 00 00       	call   8005a7 <vcprintf>
	cprintf("\n");
  80053c:	c7 04 24 27 15 80 00 	movl   $0x801527,(%esp)
  800543:	e8 c3 00 00 00       	call   80060b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800548:	cc                   	int3   
  800549:	eb fd                	jmp    800548 <_panic+0x58>

0080054b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80054b:	55                   	push   %ebp
  80054c:	89 e5                	mov    %esp,%ebp
  80054e:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800551:	8b 45 0c             	mov    0xc(%ebp),%eax
  800554:	8b 00                	mov    (%eax),%eax
  800556:	8d 48 01             	lea    0x1(%eax),%ecx
  800559:	8b 55 0c             	mov    0xc(%ebp),%edx
  80055c:	89 0a                	mov    %ecx,(%edx)
  80055e:	8b 55 08             	mov    0x8(%ebp),%edx
  800561:	89 d1                	mov    %edx,%ecx
  800563:	8b 55 0c             	mov    0xc(%ebp),%edx
  800566:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  80056a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80056d:	8b 00                	mov    (%eax),%eax
  80056f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800574:	75 20                	jne    800596 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800576:	8b 45 0c             	mov    0xc(%ebp),%eax
  800579:	8b 00                	mov    (%eax),%eax
  80057b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80057e:	83 c2 08             	add    $0x8,%edx
  800581:	89 44 24 04          	mov    %eax,0x4(%esp)
  800585:	89 14 24             	mov    %edx,(%esp)
  800588:	e8 77 fb ff ff       	call   800104 <sys_cputs>
		b->idx = 0;
  80058d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800590:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800596:	8b 45 0c             	mov    0xc(%ebp),%eax
  800599:	8b 40 04             	mov    0x4(%eax),%eax
  80059c:	8d 50 01             	lea    0x1(%eax),%edx
  80059f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005a2:	89 50 04             	mov    %edx,0x4(%eax)
}
  8005a5:	c9                   	leave  
  8005a6:	c3                   	ret    

008005a7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8005a7:	55                   	push   %ebp
  8005a8:	89 e5                	mov    %esp,%ebp
  8005aa:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8005b0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8005b7:	00 00 00 
	b.cnt = 0;
  8005ba:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8005c1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8005c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005d2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005dc:	c7 04 24 4b 05 80 00 	movl   $0x80054b,(%esp)
  8005e3:	e8 bd 01 00 00       	call   8007a5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005e8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8005ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005f8:	83 c0 08             	add    $0x8,%eax
  8005fb:	89 04 24             	mov    %eax,(%esp)
  8005fe:	e8 01 fb ff ff       	call   800104 <sys_cputs>

	return b.cnt;
  800603:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800609:	c9                   	leave  
  80060a:	c3                   	ret    

0080060b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80060b:	55                   	push   %ebp
  80060c:	89 e5                	mov    %esp,%ebp
  80060e:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800611:	8d 45 0c             	lea    0xc(%ebp),%eax
  800614:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800617:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80061a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061e:	8b 45 08             	mov    0x8(%ebp),%eax
  800621:	89 04 24             	mov    %eax,(%esp)
  800624:	e8 7e ff ff ff       	call   8005a7 <vcprintf>
  800629:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  80062c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80062f:	c9                   	leave  
  800630:	c3                   	ret    

00800631 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800631:	55                   	push   %ebp
  800632:	89 e5                	mov    %esp,%ebp
  800634:	53                   	push   %ebx
  800635:	83 ec 34             	sub    $0x34,%esp
  800638:	8b 45 10             	mov    0x10(%ebp),%eax
  80063b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800644:	8b 45 18             	mov    0x18(%ebp),%eax
  800647:	ba 00 00 00 00       	mov    $0x0,%edx
  80064c:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80064f:	77 72                	ja     8006c3 <printnum+0x92>
  800651:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800654:	72 05                	jb     80065b <printnum+0x2a>
  800656:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800659:	77 68                	ja     8006c3 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80065b:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80065e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800661:	8b 45 18             	mov    0x18(%ebp),%eax
  800664:	ba 00 00 00 00       	mov    $0x0,%edx
  800669:	89 44 24 08          	mov    %eax,0x8(%esp)
  80066d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800671:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800674:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800677:	89 04 24             	mov    %eax,(%esp)
  80067a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80067e:	e8 9d 0b 00 00       	call   801220 <__udivdi3>
  800683:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800686:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  80068a:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80068e:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800691:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800695:	89 44 24 08          	mov    %eax,0x8(%esp)
  800699:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80069d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a7:	89 04 24             	mov    %eax,(%esp)
  8006aa:	e8 82 ff ff ff       	call   800631 <printnum>
  8006af:	eb 1c                	jmp    8006cd <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8006b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b8:	8b 45 20             	mov    0x20(%ebp),%eax
  8006bb:	89 04 24             	mov    %eax,(%esp)
  8006be:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c1:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006c3:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8006c7:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8006cb:	7f e4                	jg     8006b1 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006cd:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8006d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006db:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006df:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006e3:	89 04 24             	mov    %eax,(%esp)
  8006e6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006ea:	e8 61 0c 00 00       	call   801350 <__umoddi3>
  8006ef:	05 08 16 80 00       	add    $0x801608,%eax
  8006f4:	0f b6 00             	movzbl (%eax),%eax
  8006f7:	0f be c0             	movsbl %al,%eax
  8006fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006fd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800701:	89 04 24             	mov    %eax,(%esp)
  800704:	8b 45 08             	mov    0x8(%ebp),%eax
  800707:	ff d0                	call   *%eax
}
  800709:	83 c4 34             	add    $0x34,%esp
  80070c:	5b                   	pop    %ebx
  80070d:	5d                   	pop    %ebp
  80070e:	c3                   	ret    

0080070f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800712:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800716:	7e 14                	jle    80072c <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800718:	8b 45 08             	mov    0x8(%ebp),%eax
  80071b:	8b 00                	mov    (%eax),%eax
  80071d:	8d 48 08             	lea    0x8(%eax),%ecx
  800720:	8b 55 08             	mov    0x8(%ebp),%edx
  800723:	89 0a                	mov    %ecx,(%edx)
  800725:	8b 50 04             	mov    0x4(%eax),%edx
  800728:	8b 00                	mov    (%eax),%eax
  80072a:	eb 30                	jmp    80075c <getuint+0x4d>
	else if (lflag)
  80072c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800730:	74 16                	je     800748 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800732:	8b 45 08             	mov    0x8(%ebp),%eax
  800735:	8b 00                	mov    (%eax),%eax
  800737:	8d 48 04             	lea    0x4(%eax),%ecx
  80073a:	8b 55 08             	mov    0x8(%ebp),%edx
  80073d:	89 0a                	mov    %ecx,(%edx)
  80073f:	8b 00                	mov    (%eax),%eax
  800741:	ba 00 00 00 00       	mov    $0x0,%edx
  800746:	eb 14                	jmp    80075c <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800748:	8b 45 08             	mov    0x8(%ebp),%eax
  80074b:	8b 00                	mov    (%eax),%eax
  80074d:	8d 48 04             	lea    0x4(%eax),%ecx
  800750:	8b 55 08             	mov    0x8(%ebp),%edx
  800753:	89 0a                	mov    %ecx,(%edx)
  800755:	8b 00                	mov    (%eax),%eax
  800757:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80075c:	5d                   	pop    %ebp
  80075d:	c3                   	ret    

0080075e <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800761:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800765:	7e 14                	jle    80077b <getint+0x1d>
		return va_arg(*ap, long long);
  800767:	8b 45 08             	mov    0x8(%ebp),%eax
  80076a:	8b 00                	mov    (%eax),%eax
  80076c:	8d 48 08             	lea    0x8(%eax),%ecx
  80076f:	8b 55 08             	mov    0x8(%ebp),%edx
  800772:	89 0a                	mov    %ecx,(%edx)
  800774:	8b 50 04             	mov    0x4(%eax),%edx
  800777:	8b 00                	mov    (%eax),%eax
  800779:	eb 28                	jmp    8007a3 <getint+0x45>
	else if (lflag)
  80077b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80077f:	74 12                	je     800793 <getint+0x35>
		return va_arg(*ap, long);
  800781:	8b 45 08             	mov    0x8(%ebp),%eax
  800784:	8b 00                	mov    (%eax),%eax
  800786:	8d 48 04             	lea    0x4(%eax),%ecx
  800789:	8b 55 08             	mov    0x8(%ebp),%edx
  80078c:	89 0a                	mov    %ecx,(%edx)
  80078e:	8b 00                	mov    (%eax),%eax
  800790:	99                   	cltd   
  800791:	eb 10                	jmp    8007a3 <getint+0x45>
	else
		return va_arg(*ap, int);
  800793:	8b 45 08             	mov    0x8(%ebp),%eax
  800796:	8b 00                	mov    (%eax),%eax
  800798:	8d 48 04             	lea    0x4(%eax),%ecx
  80079b:	8b 55 08             	mov    0x8(%ebp),%edx
  80079e:	89 0a                	mov    %ecx,(%edx)
  8007a0:	8b 00                	mov    (%eax),%eax
  8007a2:	99                   	cltd   
}
  8007a3:	5d                   	pop    %ebp
  8007a4:	c3                   	ret    

008007a5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	56                   	push   %esi
  8007a9:	53                   	push   %ebx
  8007aa:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007ad:	eb 18                	jmp    8007c7 <vprintfmt+0x22>
			if (ch == '\0')
  8007af:	85 db                	test   %ebx,%ebx
  8007b1:	75 05                	jne    8007b8 <vprintfmt+0x13>
				return;
  8007b3:	e9 cc 03 00 00       	jmp    800b84 <vprintfmt+0x3df>
			putch(ch, putdat);
  8007b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007bf:	89 1c 24             	mov    %ebx,(%esp)
  8007c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c5:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ca:	8d 50 01             	lea    0x1(%eax),%edx
  8007cd:	89 55 10             	mov    %edx,0x10(%ebp)
  8007d0:	0f b6 00             	movzbl (%eax),%eax
  8007d3:	0f b6 d8             	movzbl %al,%ebx
  8007d6:	83 fb 25             	cmp    $0x25,%ebx
  8007d9:	75 d4                	jne    8007af <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8007db:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8007df:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8007e6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8007ed:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8007f4:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007fb:	8b 45 10             	mov    0x10(%ebp),%eax
  8007fe:	8d 50 01             	lea    0x1(%eax),%edx
  800801:	89 55 10             	mov    %edx,0x10(%ebp)
  800804:	0f b6 00             	movzbl (%eax),%eax
  800807:	0f b6 d8             	movzbl %al,%ebx
  80080a:	8d 43 dd             	lea    -0x23(%ebx),%eax
  80080d:	83 f8 55             	cmp    $0x55,%eax
  800810:	0f 87 3d 03 00 00    	ja     800b53 <vprintfmt+0x3ae>
  800816:	8b 04 85 2c 16 80 00 	mov    0x80162c(,%eax,4),%eax
  80081d:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  80081f:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800823:	eb d6                	jmp    8007fb <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800825:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800829:	eb d0                	jmp    8007fb <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80082b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800832:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800835:	89 d0                	mov    %edx,%eax
  800837:	c1 e0 02             	shl    $0x2,%eax
  80083a:	01 d0                	add    %edx,%eax
  80083c:	01 c0                	add    %eax,%eax
  80083e:	01 d8                	add    %ebx,%eax
  800840:	83 e8 30             	sub    $0x30,%eax
  800843:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800846:	8b 45 10             	mov    0x10(%ebp),%eax
  800849:	0f b6 00             	movzbl (%eax),%eax
  80084c:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  80084f:	83 fb 2f             	cmp    $0x2f,%ebx
  800852:	7e 0b                	jle    80085f <vprintfmt+0xba>
  800854:	83 fb 39             	cmp    $0x39,%ebx
  800857:	7f 06                	jg     80085f <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800859:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80085d:	eb d3                	jmp    800832 <vprintfmt+0x8d>
			goto process_precision;
  80085f:	eb 33                	jmp    800894 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800861:	8b 45 14             	mov    0x14(%ebp),%eax
  800864:	8d 50 04             	lea    0x4(%eax),%edx
  800867:	89 55 14             	mov    %edx,0x14(%ebp)
  80086a:	8b 00                	mov    (%eax),%eax
  80086c:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80086f:	eb 23                	jmp    800894 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800871:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800875:	79 0c                	jns    800883 <vprintfmt+0xde>
				width = 0;
  800877:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  80087e:	e9 78 ff ff ff       	jmp    8007fb <vprintfmt+0x56>
  800883:	e9 73 ff ff ff       	jmp    8007fb <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800888:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80088f:	e9 67 ff ff ff       	jmp    8007fb <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800894:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800898:	79 12                	jns    8008ac <vprintfmt+0x107>
				width = precision, precision = -1;
  80089a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80089d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008a0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8008a7:	e9 4f ff ff ff       	jmp    8007fb <vprintfmt+0x56>
  8008ac:	e9 4a ff ff ff       	jmp    8007fb <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008b1:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8008b5:	e9 41 ff ff ff       	jmp    8007fb <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bd:	8d 50 04             	lea    0x4(%eax),%edx
  8008c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c3:	8b 00                	mov    (%eax),%eax
  8008c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008cc:	89 04 24             	mov    %eax,(%esp)
  8008cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d2:	ff d0                	call   *%eax
			break;
  8008d4:	e9 a5 02 00 00       	jmp    800b7e <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008dc:	8d 50 04             	lea    0x4(%eax),%edx
  8008df:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e2:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8008e4:	85 db                	test   %ebx,%ebx
  8008e6:	79 02                	jns    8008ea <vprintfmt+0x145>
				err = -err;
  8008e8:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8008ea:	83 fb 09             	cmp    $0x9,%ebx
  8008ed:	7f 0b                	jg     8008fa <vprintfmt+0x155>
  8008ef:	8b 34 9d e0 15 80 00 	mov    0x8015e0(,%ebx,4),%esi
  8008f6:	85 f6                	test   %esi,%esi
  8008f8:	75 23                	jne    80091d <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8008fa:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8008fe:	c7 44 24 08 19 16 80 	movl   $0x801619,0x8(%esp)
  800905:	00 
  800906:	8b 45 0c             	mov    0xc(%ebp),%eax
  800909:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090d:	8b 45 08             	mov    0x8(%ebp),%eax
  800910:	89 04 24             	mov    %eax,(%esp)
  800913:	e8 73 02 00 00       	call   800b8b <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800918:	e9 61 02 00 00       	jmp    800b7e <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80091d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800921:	c7 44 24 08 22 16 80 	movl   $0x801622,0x8(%esp)
  800928:	00 
  800929:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
  800933:	89 04 24             	mov    %eax,(%esp)
  800936:	e8 50 02 00 00       	call   800b8b <printfmt>
			break;
  80093b:	e9 3e 02 00 00       	jmp    800b7e <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800940:	8b 45 14             	mov    0x14(%ebp),%eax
  800943:	8d 50 04             	lea    0x4(%eax),%edx
  800946:	89 55 14             	mov    %edx,0x14(%ebp)
  800949:	8b 30                	mov    (%eax),%esi
  80094b:	85 f6                	test   %esi,%esi
  80094d:	75 05                	jne    800954 <vprintfmt+0x1af>
				p = "(null)";
  80094f:	be 25 16 80 00       	mov    $0x801625,%esi
			if (width > 0 && padc != '-')
  800954:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800958:	7e 37                	jle    800991 <vprintfmt+0x1ec>
  80095a:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  80095e:	74 31                	je     800991 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800960:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800963:	89 44 24 04          	mov    %eax,0x4(%esp)
  800967:	89 34 24             	mov    %esi,(%esp)
  80096a:	e8 39 03 00 00       	call   800ca8 <strnlen>
  80096f:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800972:	eb 17                	jmp    80098b <vprintfmt+0x1e6>
					putch(padc, putdat);
  800974:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800978:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80097f:	89 04 24             	mov    %eax,(%esp)
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800987:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80098b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80098f:	7f e3                	jg     800974 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800991:	eb 38                	jmp    8009cb <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800993:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800997:	74 1f                	je     8009b8 <vprintfmt+0x213>
  800999:	83 fb 1f             	cmp    $0x1f,%ebx
  80099c:	7e 05                	jle    8009a3 <vprintfmt+0x1fe>
  80099e:	83 fb 7e             	cmp    $0x7e,%ebx
  8009a1:	7e 15                	jle    8009b8 <vprintfmt+0x213>
					putch('?', putdat);
  8009a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009aa:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	ff d0                	call   *%eax
  8009b6:	eb 0f                	jmp    8009c7 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8009b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009bf:	89 1c 24             	mov    %ebx,(%esp)
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009c7:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8009cb:	89 f0                	mov    %esi,%eax
  8009cd:	8d 70 01             	lea    0x1(%eax),%esi
  8009d0:	0f b6 00             	movzbl (%eax),%eax
  8009d3:	0f be d8             	movsbl %al,%ebx
  8009d6:	85 db                	test   %ebx,%ebx
  8009d8:	74 10                	je     8009ea <vprintfmt+0x245>
  8009da:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009de:	78 b3                	js     800993 <vprintfmt+0x1ee>
  8009e0:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8009e4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009e8:	79 a9                	jns    800993 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009ea:	eb 17                	jmp    800a03 <vprintfmt+0x25e>
				putch(' ', putdat);
  8009ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009ff:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800a03:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a07:	7f e3                	jg     8009ec <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800a09:	e9 70 01 00 00       	jmp    800b7e <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a11:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a15:	8d 45 14             	lea    0x14(%ebp),%eax
  800a18:	89 04 24             	mov    %eax,(%esp)
  800a1b:	e8 3e fd ff ff       	call   80075e <getint>
  800a20:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a23:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800a26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a29:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a2c:	85 d2                	test   %edx,%edx
  800a2e:	79 26                	jns    800a56 <vprintfmt+0x2b1>
				putch('-', putdat);
  800a30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a33:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a37:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a41:	ff d0                	call   *%eax
				num = -(long long) num;
  800a43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a46:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a49:	f7 d8                	neg    %eax
  800a4b:	83 d2 00             	adc    $0x0,%edx
  800a4e:	f7 da                	neg    %edx
  800a50:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a53:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800a56:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a5d:	e9 a8 00 00 00       	jmp    800b0a <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a62:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a65:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a69:	8d 45 14             	lea    0x14(%ebp),%eax
  800a6c:	89 04 24             	mov    %eax,(%esp)
  800a6f:	e8 9b fc ff ff       	call   80070f <getuint>
  800a74:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a77:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800a7a:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a81:	e9 84 00 00 00       	jmp    800b0a <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a86:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a89:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a8d:	8d 45 14             	lea    0x14(%ebp),%eax
  800a90:	89 04 24             	mov    %eax,(%esp)
  800a93:	e8 77 fc ff ff       	call   80070f <getuint>
  800a98:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a9b:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800a9e:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800aa5:	eb 63                	jmp    800b0a <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800aa7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aaa:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aae:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800ab5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab8:	ff d0                	call   *%eax
			putch('x', putdat);
  800aba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac1:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800ac8:	8b 45 08             	mov    0x8(%ebp),%eax
  800acb:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800acd:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad0:	8d 50 04             	lea    0x4(%eax),%edx
  800ad3:	89 55 14             	mov    %edx,0x14(%ebp)
  800ad6:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800ad8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800adb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800ae2:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800ae9:	eb 1f                	jmp    800b0a <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800aeb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800aee:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af2:	8d 45 14             	lea    0x14(%ebp),%eax
  800af5:	89 04 24             	mov    %eax,(%esp)
  800af8:	e8 12 fc ff ff       	call   80070f <getuint>
  800afd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b00:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800b03:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b0a:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800b0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b11:	89 54 24 18          	mov    %edx,0x18(%esp)
  800b15:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b18:	89 54 24 14          	mov    %edx,0x14(%esp)
  800b1c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b20:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b23:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b26:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b2a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b31:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b35:	8b 45 08             	mov    0x8(%ebp),%eax
  800b38:	89 04 24             	mov    %eax,(%esp)
  800b3b:	e8 f1 fa ff ff       	call   800631 <printnum>
			break;
  800b40:	eb 3c                	jmp    800b7e <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b45:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b49:	89 1c 24             	mov    %ebx,(%esp)
  800b4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4f:	ff d0                	call   *%eax
			break;
  800b51:	eb 2b                	jmp    800b7e <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b56:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b5a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b61:	8b 45 08             	mov    0x8(%ebp),%eax
  800b64:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b66:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b6a:	eb 04                	jmp    800b70 <vprintfmt+0x3cb>
  800b6c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b70:	8b 45 10             	mov    0x10(%ebp),%eax
  800b73:	83 e8 01             	sub    $0x1,%eax
  800b76:	0f b6 00             	movzbl (%eax),%eax
  800b79:	3c 25                	cmp    $0x25,%al
  800b7b:	75 ef                	jne    800b6c <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800b7d:	90                   	nop
		}
	}
  800b7e:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b7f:	e9 43 fc ff ff       	jmp    8007c7 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800b84:	83 c4 40             	add    $0x40,%esp
  800b87:	5b                   	pop    %ebx
  800b88:	5e                   	pop    %esi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b91:	8d 45 14             	lea    0x14(%ebp),%eax
  800b94:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b9a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b9e:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ba5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bac:	8b 45 08             	mov    0x8(%ebp),%eax
  800baf:	89 04 24             	mov    %eax,(%esp)
  800bb2:	e8 ee fb ff ff       	call   8007a5 <vprintfmt>
	va_end(ap);
}
  800bb7:	c9                   	leave  
  800bb8:	c3                   	ret    

00800bb9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800bbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbf:	8b 40 08             	mov    0x8(%eax),%eax
  800bc2:	8d 50 01             	lea    0x1(%eax),%edx
  800bc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc8:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800bcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bce:	8b 10                	mov    (%eax),%edx
  800bd0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd3:	8b 40 04             	mov    0x4(%eax),%eax
  800bd6:	39 c2                	cmp    %eax,%edx
  800bd8:	73 12                	jae    800bec <sprintputch+0x33>
		*b->buf++ = ch;
  800bda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bdd:	8b 00                	mov    (%eax),%eax
  800bdf:	8d 48 01             	lea    0x1(%eax),%ecx
  800be2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800be5:	89 0a                	mov    %ecx,(%edx)
  800be7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bea:	88 10                	mov    %dl,(%eax)
}
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    

00800bee <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bfd:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c00:	8b 45 08             	mov    0x8(%ebp),%eax
  800c03:	01 d0                	add    %edx,%eax
  800c05:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c08:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c0f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800c13:	74 06                	je     800c1b <vsnprintf+0x2d>
  800c15:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c19:	7f 07                	jg     800c22 <vsnprintf+0x34>
		return -E_INVAL;
  800c1b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c20:	eb 2a                	jmp    800c4c <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c22:	8b 45 14             	mov    0x14(%ebp),%eax
  800c25:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c29:	8b 45 10             	mov    0x10(%ebp),%eax
  800c2c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c30:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c33:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c37:	c7 04 24 b9 0b 80 00 	movl   $0x800bb9,(%esp)
  800c3e:	e8 62 fb ff ff       	call   8007a5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c43:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c46:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c4c:	c9                   	leave  
  800c4d:	c3                   	ret    

00800c4e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c54:	8d 45 14             	lea    0x14(%ebp),%eax
  800c57:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800c5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c5d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c61:	8b 45 10             	mov    0x10(%ebp),%eax
  800c64:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c72:	89 04 24             	mov    %eax,(%esp)
  800c75:	e8 74 ff ff ff       	call   800bee <vsnprintf>
  800c7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800c7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c80:	c9                   	leave  
  800c81:	c3                   	ret    

00800c82 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800c88:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c8f:	eb 08                	jmp    800c99 <strlen+0x17>
		n++;
  800c91:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c95:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c99:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9c:	0f b6 00             	movzbl (%eax),%eax
  800c9f:	84 c0                	test   %al,%al
  800ca1:	75 ee                	jne    800c91 <strlen+0xf>
		n++;
	return n;
  800ca3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800ca6:	c9                   	leave  
  800ca7:	c3                   	ret    

00800ca8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cae:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800cb5:	eb 0c                	jmp    800cc3 <strnlen+0x1b>
		n++;
  800cb7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cbb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cbf:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800cc3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cc7:	74 0a                	je     800cd3 <strnlen+0x2b>
  800cc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccc:	0f b6 00             	movzbl (%eax),%eax
  800ccf:	84 c0                	test   %al,%al
  800cd1:	75 e4                	jne    800cb7 <strnlen+0xf>
		n++;
	return n;
  800cd3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800cd6:	c9                   	leave  
  800cd7:	c3                   	ret    

00800cd8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800cde:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce1:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800ce4:	90                   	nop
  800ce5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce8:	8d 50 01             	lea    0x1(%eax),%edx
  800ceb:	89 55 08             	mov    %edx,0x8(%ebp)
  800cee:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cf1:	8d 4a 01             	lea    0x1(%edx),%ecx
  800cf4:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800cf7:	0f b6 12             	movzbl (%edx),%edx
  800cfa:	88 10                	mov    %dl,(%eax)
  800cfc:	0f b6 00             	movzbl (%eax),%eax
  800cff:	84 c0                	test   %al,%al
  800d01:	75 e2                	jne    800ce5 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800d03:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800d06:	c9                   	leave  
  800d07:	c3                   	ret    

00800d08 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800d0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d11:	89 04 24             	mov    %eax,(%esp)
  800d14:	e8 69 ff ff ff       	call   800c82 <strlen>
  800d19:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800d1c:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800d1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d22:	01 c2                	add    %eax,%edx
  800d24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d27:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d2b:	89 14 24             	mov    %edx,(%esp)
  800d2e:	e8 a5 ff ff ff       	call   800cd8 <strcpy>
	return dst;
  800d33:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d36:	c9                   	leave  
  800d37:	c3                   	ret    

00800d38 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800d3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d41:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800d44:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800d4b:	eb 23                	jmp    800d70 <strncpy+0x38>
		*dst++ = *src;
  800d4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d50:	8d 50 01             	lea    0x1(%eax),%edx
  800d53:	89 55 08             	mov    %edx,0x8(%ebp)
  800d56:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d59:	0f b6 12             	movzbl (%edx),%edx
  800d5c:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800d5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d61:	0f b6 00             	movzbl (%eax),%eax
  800d64:	84 c0                	test   %al,%al
  800d66:	74 04                	je     800d6c <strncpy+0x34>
			src++;
  800d68:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d6c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d70:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d73:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d76:	72 d5                	jb     800d4d <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800d78:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d7b:	c9                   	leave  
  800d7c:	c3                   	ret    

00800d7d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800d83:	8b 45 08             	mov    0x8(%ebp),%eax
  800d86:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800d89:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d8d:	74 33                	je     800dc2 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d8f:	eb 17                	jmp    800da8 <strlcpy+0x2b>
			*dst++ = *src++;
  800d91:	8b 45 08             	mov    0x8(%ebp),%eax
  800d94:	8d 50 01             	lea    0x1(%eax),%edx
  800d97:	89 55 08             	mov    %edx,0x8(%ebp)
  800d9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d9d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800da0:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800da3:	0f b6 12             	movzbl (%edx),%edx
  800da6:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800da8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800dac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800db0:	74 0a                	je     800dbc <strlcpy+0x3f>
  800db2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db5:	0f b6 00             	movzbl (%eax),%eax
  800db8:	84 c0                	test   %al,%al
  800dba:	75 d5                	jne    800d91 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800dbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbf:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800dc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800dc8:	29 c2                	sub    %eax,%edx
  800dca:	89 d0                	mov    %edx,%eax
}
  800dcc:	c9                   	leave  
  800dcd:	c3                   	ret    

00800dce <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800dd1:	eb 08                	jmp    800ddb <strcmp+0xd>
		p++, q++;
  800dd3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dd7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ddb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dde:	0f b6 00             	movzbl (%eax),%eax
  800de1:	84 c0                	test   %al,%al
  800de3:	74 10                	je     800df5 <strcmp+0x27>
  800de5:	8b 45 08             	mov    0x8(%ebp),%eax
  800de8:	0f b6 10             	movzbl (%eax),%edx
  800deb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dee:	0f b6 00             	movzbl (%eax),%eax
  800df1:	38 c2                	cmp    %al,%dl
  800df3:	74 de                	je     800dd3 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800df5:	8b 45 08             	mov    0x8(%ebp),%eax
  800df8:	0f b6 00             	movzbl (%eax),%eax
  800dfb:	0f b6 d0             	movzbl %al,%edx
  800dfe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e01:	0f b6 00             	movzbl (%eax),%eax
  800e04:	0f b6 c0             	movzbl %al,%eax
  800e07:	29 c2                	sub    %eax,%edx
  800e09:	89 d0                	mov    %edx,%eax
}
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800e10:	eb 0c                	jmp    800e1e <strncmp+0x11>
		n--, p++, q++;
  800e12:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800e16:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e1a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e1e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e22:	74 1a                	je     800e3e <strncmp+0x31>
  800e24:	8b 45 08             	mov    0x8(%ebp),%eax
  800e27:	0f b6 00             	movzbl (%eax),%eax
  800e2a:	84 c0                	test   %al,%al
  800e2c:	74 10                	je     800e3e <strncmp+0x31>
  800e2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e31:	0f b6 10             	movzbl (%eax),%edx
  800e34:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e37:	0f b6 00             	movzbl (%eax),%eax
  800e3a:	38 c2                	cmp    %al,%dl
  800e3c:	74 d4                	je     800e12 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800e3e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e42:	75 07                	jne    800e4b <strncmp+0x3e>
		return 0;
  800e44:	b8 00 00 00 00       	mov    $0x0,%eax
  800e49:	eb 16                	jmp    800e61 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4e:	0f b6 00             	movzbl (%eax),%eax
  800e51:	0f b6 d0             	movzbl %al,%edx
  800e54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e57:	0f b6 00             	movzbl (%eax),%eax
  800e5a:	0f b6 c0             	movzbl %al,%eax
  800e5d:	29 c2                	sub    %eax,%edx
  800e5f:	89 d0                	mov    %edx,%eax
}
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    

00800e63 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	83 ec 04             	sub    $0x4,%esp
  800e69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6c:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e6f:	eb 14                	jmp    800e85 <strchr+0x22>
		if (*s == c)
  800e71:	8b 45 08             	mov    0x8(%ebp),%eax
  800e74:	0f b6 00             	movzbl (%eax),%eax
  800e77:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e7a:	75 05                	jne    800e81 <strchr+0x1e>
			return (char *) s;
  800e7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7f:	eb 13                	jmp    800e94 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e81:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e85:	8b 45 08             	mov    0x8(%ebp),%eax
  800e88:	0f b6 00             	movzbl (%eax),%eax
  800e8b:	84 c0                	test   %al,%al
  800e8d:	75 e2                	jne    800e71 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e94:	c9                   	leave  
  800e95:	c3                   	ret    

00800e96 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	83 ec 04             	sub    $0x4,%esp
  800e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9f:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800ea2:	eb 11                	jmp    800eb5 <strfind+0x1f>
		if (*s == c)
  800ea4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea7:	0f b6 00             	movzbl (%eax),%eax
  800eaa:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800ead:	75 02                	jne    800eb1 <strfind+0x1b>
			break;
  800eaf:	eb 0e                	jmp    800ebf <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800eb1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800eb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb8:	0f b6 00             	movzbl (%eax),%eax
  800ebb:	84 c0                	test   %al,%al
  800ebd:	75 e5                	jne    800ea4 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800ebf:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ec2:	c9                   	leave  
  800ec3:	c3                   	ret    

00800ec4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	57                   	push   %edi
	char *p;

	if (n == 0)
  800ec8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ecc:	75 05                	jne    800ed3 <memset+0xf>
		return v;
  800ece:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed1:	eb 5c                	jmp    800f2f <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800ed3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed6:	83 e0 03             	and    $0x3,%eax
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	75 41                	jne    800f1e <memset+0x5a>
  800edd:	8b 45 10             	mov    0x10(%ebp),%eax
  800ee0:	83 e0 03             	and    $0x3,%eax
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	75 37                	jne    800f1e <memset+0x5a>
		c &= 0xFF;
  800ee7:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800eee:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef1:	c1 e0 18             	shl    $0x18,%eax
  800ef4:	89 c2                	mov    %eax,%edx
  800ef6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef9:	c1 e0 10             	shl    $0x10,%eax
  800efc:	09 c2                	or     %eax,%edx
  800efe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f01:	c1 e0 08             	shl    $0x8,%eax
  800f04:	09 d0                	or     %edx,%eax
  800f06:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800f09:	8b 45 10             	mov    0x10(%ebp),%eax
  800f0c:	c1 e8 02             	shr    $0x2,%eax
  800f0f:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800f11:	8b 55 08             	mov    0x8(%ebp),%edx
  800f14:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f17:	89 d7                	mov    %edx,%edi
  800f19:	fc                   	cld    
  800f1a:	f3 ab                	rep stos %eax,%es:(%edi)
  800f1c:	eb 0e                	jmp    800f2c <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f21:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f24:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f27:	89 d7                	mov    %edx,%edi
  800f29:	fc                   	cld    
  800f2a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800f2c:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f2f:	5f                   	pop    %edi
  800f30:	5d                   	pop    %ebp
  800f31:	c3                   	ret    

00800f32 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	57                   	push   %edi
  800f36:	56                   	push   %esi
  800f37:	53                   	push   %ebx
  800f38:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800f3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800f41:	8b 45 08             	mov    0x8(%ebp),%eax
  800f44:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800f47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f4a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f4d:	73 6d                	jae    800fbc <memmove+0x8a>
  800f4f:	8b 45 10             	mov    0x10(%ebp),%eax
  800f52:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f55:	01 d0                	add    %edx,%eax
  800f57:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f5a:	76 60                	jbe    800fbc <memmove+0x8a>
		s += n;
  800f5c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f5f:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800f62:	8b 45 10             	mov    0x10(%ebp),%eax
  800f65:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f6b:	83 e0 03             	and    $0x3,%eax
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	75 2f                	jne    800fa1 <memmove+0x6f>
  800f72:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f75:	83 e0 03             	and    $0x3,%eax
  800f78:	85 c0                	test   %eax,%eax
  800f7a:	75 25                	jne    800fa1 <memmove+0x6f>
  800f7c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f7f:	83 e0 03             	and    $0x3,%eax
  800f82:	85 c0                	test   %eax,%eax
  800f84:	75 1b                	jne    800fa1 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f86:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f89:	83 e8 04             	sub    $0x4,%eax
  800f8c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f8f:	83 ea 04             	sub    $0x4,%edx
  800f92:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f95:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f98:	89 c7                	mov    %eax,%edi
  800f9a:	89 d6                	mov    %edx,%esi
  800f9c:	fd                   	std    
  800f9d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f9f:	eb 18                	jmp    800fb9 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800fa1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fa4:	8d 50 ff             	lea    -0x1(%eax),%edx
  800fa7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800faa:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800fad:	8b 45 10             	mov    0x10(%ebp),%eax
  800fb0:	89 d7                	mov    %edx,%edi
  800fb2:	89 de                	mov    %ebx,%esi
  800fb4:	89 c1                	mov    %eax,%ecx
  800fb6:	fd                   	std    
  800fb7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fb9:	fc                   	cld    
  800fba:	eb 45                	jmp    801001 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fbf:	83 e0 03             	and    $0x3,%eax
  800fc2:	85 c0                	test   %eax,%eax
  800fc4:	75 2b                	jne    800ff1 <memmove+0xbf>
  800fc6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fc9:	83 e0 03             	and    $0x3,%eax
  800fcc:	85 c0                	test   %eax,%eax
  800fce:	75 21                	jne    800ff1 <memmove+0xbf>
  800fd0:	8b 45 10             	mov    0x10(%ebp),%eax
  800fd3:	83 e0 03             	and    $0x3,%eax
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	75 17                	jne    800ff1 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800fda:	8b 45 10             	mov    0x10(%ebp),%eax
  800fdd:	c1 e8 02             	shr    $0x2,%eax
  800fe0:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800fe2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fe5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fe8:	89 c7                	mov    %eax,%edi
  800fea:	89 d6                	mov    %edx,%esi
  800fec:	fc                   	cld    
  800fed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fef:	eb 10                	jmp    801001 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ff1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ff4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ff7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ffa:	89 c7                	mov    %eax,%edi
  800ffc:	89 d6                	mov    %edx,%esi
  800ffe:	fc                   	cld    
  800fff:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  801001:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801004:	83 c4 10             	add    $0x10,%esp
  801007:	5b                   	pop    %ebx
  801008:	5e                   	pop    %esi
  801009:	5f                   	pop    %edi
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    

0080100c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801012:	8b 45 10             	mov    0x10(%ebp),%eax
  801015:	89 44 24 08          	mov    %eax,0x8(%esp)
  801019:	8b 45 0c             	mov    0xc(%ebp),%eax
  80101c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801020:	8b 45 08             	mov    0x8(%ebp),%eax
  801023:	89 04 24             	mov    %eax,(%esp)
  801026:	e8 07 ff ff ff       	call   800f32 <memmove>
}
  80102b:	c9                   	leave  
  80102c:	c3                   	ret    

0080102d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  801033:	8b 45 08             	mov    0x8(%ebp),%eax
  801036:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  801039:	8b 45 0c             	mov    0xc(%ebp),%eax
  80103c:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  80103f:	eb 30                	jmp    801071 <memcmp+0x44>
		if (*s1 != *s2)
  801041:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801044:	0f b6 10             	movzbl (%eax),%edx
  801047:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80104a:	0f b6 00             	movzbl (%eax),%eax
  80104d:	38 c2                	cmp    %al,%dl
  80104f:	74 18                	je     801069 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  801051:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801054:	0f b6 00             	movzbl (%eax),%eax
  801057:	0f b6 d0             	movzbl %al,%edx
  80105a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80105d:	0f b6 00             	movzbl (%eax),%eax
  801060:	0f b6 c0             	movzbl %al,%eax
  801063:	29 c2                	sub    %eax,%edx
  801065:	89 d0                	mov    %edx,%eax
  801067:	eb 1a                	jmp    801083 <memcmp+0x56>
		s1++, s2++;
  801069:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80106d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801071:	8b 45 10             	mov    0x10(%ebp),%eax
  801074:	8d 50 ff             	lea    -0x1(%eax),%edx
  801077:	89 55 10             	mov    %edx,0x10(%ebp)
  80107a:	85 c0                	test   %eax,%eax
  80107c:	75 c3                	jne    801041 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80107e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801083:	c9                   	leave  
  801084:	c3                   	ret    

00801085 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  80108b:	8b 45 10             	mov    0x10(%ebp),%eax
  80108e:	8b 55 08             	mov    0x8(%ebp),%edx
  801091:	01 d0                	add    %edx,%eax
  801093:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801096:	eb 13                	jmp    8010ab <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801098:	8b 45 08             	mov    0x8(%ebp),%eax
  80109b:	0f b6 10             	movzbl (%eax),%edx
  80109e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010a1:	38 c2                	cmp    %al,%dl
  8010a3:	75 02                	jne    8010a7 <memfind+0x22>
			break;
  8010a5:	eb 0c                	jmp    8010b3 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8010a7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ae:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  8010b1:	72 e5                	jb     801098 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  8010b3:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8010b6:	c9                   	leave  
  8010b7:	c3                   	ret    

008010b8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  8010be:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  8010c5:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010cc:	eb 04                	jmp    8010d2 <strtol+0x1a>
		s++;
  8010ce:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d5:	0f b6 00             	movzbl (%eax),%eax
  8010d8:	3c 20                	cmp    $0x20,%al
  8010da:	74 f2                	je     8010ce <strtol+0x16>
  8010dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010df:	0f b6 00             	movzbl (%eax),%eax
  8010e2:	3c 09                	cmp    $0x9,%al
  8010e4:	74 e8                	je     8010ce <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  8010e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e9:	0f b6 00             	movzbl (%eax),%eax
  8010ec:	3c 2b                	cmp    $0x2b,%al
  8010ee:	75 06                	jne    8010f6 <strtol+0x3e>
		s++;
  8010f0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010f4:	eb 15                	jmp    80110b <strtol+0x53>
	else if (*s == '-')
  8010f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f9:	0f b6 00             	movzbl (%eax),%eax
  8010fc:	3c 2d                	cmp    $0x2d,%al
  8010fe:	75 0b                	jne    80110b <strtol+0x53>
		s++, neg = 1;
  801100:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801104:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80110b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80110f:	74 06                	je     801117 <strtol+0x5f>
  801111:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  801115:	75 24                	jne    80113b <strtol+0x83>
  801117:	8b 45 08             	mov    0x8(%ebp),%eax
  80111a:	0f b6 00             	movzbl (%eax),%eax
  80111d:	3c 30                	cmp    $0x30,%al
  80111f:	75 1a                	jne    80113b <strtol+0x83>
  801121:	8b 45 08             	mov    0x8(%ebp),%eax
  801124:	83 c0 01             	add    $0x1,%eax
  801127:	0f b6 00             	movzbl (%eax),%eax
  80112a:	3c 78                	cmp    $0x78,%al
  80112c:	75 0d                	jne    80113b <strtol+0x83>
		s += 2, base = 16;
  80112e:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  801132:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  801139:	eb 2a                	jmp    801165 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  80113b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80113f:	75 17                	jne    801158 <strtol+0xa0>
  801141:	8b 45 08             	mov    0x8(%ebp),%eax
  801144:	0f b6 00             	movzbl (%eax),%eax
  801147:	3c 30                	cmp    $0x30,%al
  801149:	75 0d                	jne    801158 <strtol+0xa0>
		s++, base = 8;
  80114b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80114f:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801156:	eb 0d                	jmp    801165 <strtol+0xad>
	else if (base == 0)
  801158:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80115c:	75 07                	jne    801165 <strtol+0xad>
		base = 10;
  80115e:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801165:	8b 45 08             	mov    0x8(%ebp),%eax
  801168:	0f b6 00             	movzbl (%eax),%eax
  80116b:	3c 2f                	cmp    $0x2f,%al
  80116d:	7e 1b                	jle    80118a <strtol+0xd2>
  80116f:	8b 45 08             	mov    0x8(%ebp),%eax
  801172:	0f b6 00             	movzbl (%eax),%eax
  801175:	3c 39                	cmp    $0x39,%al
  801177:	7f 11                	jg     80118a <strtol+0xd2>
			dig = *s - '0';
  801179:	8b 45 08             	mov    0x8(%ebp),%eax
  80117c:	0f b6 00             	movzbl (%eax),%eax
  80117f:	0f be c0             	movsbl %al,%eax
  801182:	83 e8 30             	sub    $0x30,%eax
  801185:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801188:	eb 48                	jmp    8011d2 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  80118a:	8b 45 08             	mov    0x8(%ebp),%eax
  80118d:	0f b6 00             	movzbl (%eax),%eax
  801190:	3c 60                	cmp    $0x60,%al
  801192:	7e 1b                	jle    8011af <strtol+0xf7>
  801194:	8b 45 08             	mov    0x8(%ebp),%eax
  801197:	0f b6 00             	movzbl (%eax),%eax
  80119a:	3c 7a                	cmp    $0x7a,%al
  80119c:	7f 11                	jg     8011af <strtol+0xf7>
			dig = *s - 'a' + 10;
  80119e:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a1:	0f b6 00             	movzbl (%eax),%eax
  8011a4:	0f be c0             	movsbl %al,%eax
  8011a7:	83 e8 57             	sub    $0x57,%eax
  8011aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8011ad:	eb 23                	jmp    8011d2 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  8011af:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b2:	0f b6 00             	movzbl (%eax),%eax
  8011b5:	3c 40                	cmp    $0x40,%al
  8011b7:	7e 3d                	jle    8011f6 <strtol+0x13e>
  8011b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011bc:	0f b6 00             	movzbl (%eax),%eax
  8011bf:	3c 5a                	cmp    $0x5a,%al
  8011c1:	7f 33                	jg     8011f6 <strtol+0x13e>
			dig = *s - 'A' + 10;
  8011c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c6:	0f b6 00             	movzbl (%eax),%eax
  8011c9:	0f be c0             	movsbl %al,%eax
  8011cc:	83 e8 37             	sub    $0x37,%eax
  8011cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  8011d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011d5:	3b 45 10             	cmp    0x10(%ebp),%eax
  8011d8:	7c 02                	jl     8011dc <strtol+0x124>
			break;
  8011da:	eb 1a                	jmp    8011f6 <strtol+0x13e>
		s++, val = (val * base) + dig;
  8011dc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8011e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011e3:	0f af 45 10          	imul   0x10(%ebp),%eax
  8011e7:	89 c2                	mov    %eax,%edx
  8011e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ec:	01 d0                	add    %edx,%eax
  8011ee:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  8011f1:	e9 6f ff ff ff       	jmp    801165 <strtol+0xad>

	if (endptr)
  8011f6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011fa:	74 08                	je     801204 <strtol+0x14c>
		*endptr = (char *) s;
  8011fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801202:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801204:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  801208:	74 07                	je     801211 <strtol+0x159>
  80120a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80120d:	f7 d8                	neg    %eax
  80120f:	eb 03                	jmp    801214 <strtol+0x15c>
  801211:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  801214:	c9                   	leave  
  801215:	c3                   	ret    
  801216:	66 90                	xchg   %ax,%ax
  801218:	66 90                	xchg   %ax,%ax
  80121a:	66 90                	xchg   %ax,%ax
  80121c:	66 90                	xchg   %ax,%ax
  80121e:	66 90                	xchg   %ax,%ax

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
