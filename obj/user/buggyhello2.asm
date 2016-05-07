
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
  8000dd:	c7 44 24 08 98 14 80 	movl   $0x801498,0x8(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000ec:	00 
  8000ed:	c7 04 24 b5 14 80 00 	movl   $0x8014b5,(%esp)
  8000f4:	e8 b3 03 00 00       	call   8004ac <_panic>

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
  8004aa:	c9                   	leave  
  8004ab:	c3                   	ret    

008004ac <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004ac:	55                   	push   %ebp
  8004ad:	89 e5                	mov    %esp,%ebp
  8004af:	53                   	push   %ebx
  8004b0:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8004b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8004b6:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004b9:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  8004bf:	e8 09 fd ff ff       	call   8001cd <sys_getenvid>
  8004c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004c7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8004cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8004ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004d2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004da:	c7 04 24 c4 14 80 00 	movl   $0x8014c4,(%esp)
  8004e1:	e8 e1 00 00 00       	call   8005c7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8004e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8004f0:	89 04 24             	mov    %eax,(%esp)
  8004f3:	e8 6b 00 00 00       	call   800563 <vcprintf>
	cprintf("\n");
  8004f8:	c7 04 24 e7 14 80 00 	movl   $0x8014e7,(%esp)
  8004ff:	e8 c3 00 00 00       	call   8005c7 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800504:	cc                   	int3   
  800505:	eb fd                	jmp    800504 <_panic+0x58>

00800507 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800507:	55                   	push   %ebp
  800508:	89 e5                	mov    %esp,%ebp
  80050a:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  80050d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800510:	8b 00                	mov    (%eax),%eax
  800512:	8d 48 01             	lea    0x1(%eax),%ecx
  800515:	8b 55 0c             	mov    0xc(%ebp),%edx
  800518:	89 0a                	mov    %ecx,(%edx)
  80051a:	8b 55 08             	mov    0x8(%ebp),%edx
  80051d:	89 d1                	mov    %edx,%ecx
  80051f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800522:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800526:	8b 45 0c             	mov    0xc(%ebp),%eax
  800529:	8b 00                	mov    (%eax),%eax
  80052b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800530:	75 20                	jne    800552 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800532:	8b 45 0c             	mov    0xc(%ebp),%eax
  800535:	8b 00                	mov    (%eax),%eax
  800537:	8b 55 0c             	mov    0xc(%ebp),%edx
  80053a:	83 c2 08             	add    $0x8,%edx
  80053d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800541:	89 14 24             	mov    %edx,(%esp)
  800544:	e8 bb fb ff ff       	call   800104 <sys_cputs>
		b->idx = 0;
  800549:	8b 45 0c             	mov    0xc(%ebp),%eax
  80054c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800552:	8b 45 0c             	mov    0xc(%ebp),%eax
  800555:	8b 40 04             	mov    0x4(%eax),%eax
  800558:	8d 50 01             	lea    0x1(%eax),%edx
  80055b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80055e:	89 50 04             	mov    %edx,0x4(%eax)
}
  800561:	c9                   	leave  
  800562:	c3                   	ret    

00800563 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800563:	55                   	push   %ebp
  800564:	89 e5                	mov    %esp,%ebp
  800566:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80056c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800573:	00 00 00 
	b.cnt = 0;
  800576:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80057d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800580:	8b 45 0c             	mov    0xc(%ebp),%eax
  800583:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800587:	8b 45 08             	mov    0x8(%ebp),%eax
  80058a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80058e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800594:	89 44 24 04          	mov    %eax,0x4(%esp)
  800598:	c7 04 24 07 05 80 00 	movl   $0x800507,(%esp)
  80059f:	e8 bd 01 00 00       	call   800761 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005a4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8005aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ae:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005b4:	83 c0 08             	add    $0x8,%eax
  8005b7:	89 04 24             	mov    %eax,(%esp)
  8005ba:	e8 45 fb ff ff       	call   800104 <sys_cputs>

	return b.cnt;
  8005bf:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8005c5:	c9                   	leave  
  8005c6:	c3                   	ret    

008005c7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005c7:	55                   	push   %ebp
  8005c8:	89 e5                	mov    %esp,%ebp
  8005ca:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005cd:	8d 45 0c             	lea    0xc(%ebp),%eax
  8005d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8005d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005da:	8b 45 08             	mov    0x8(%ebp),%eax
  8005dd:	89 04 24             	mov    %eax,(%esp)
  8005e0:	e8 7e ff ff ff       	call   800563 <vcprintf>
  8005e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8005e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8005eb:	c9                   	leave  
  8005ec:	c3                   	ret    

008005ed <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005ed:	55                   	push   %ebp
  8005ee:	89 e5                	mov    %esp,%ebp
  8005f0:	53                   	push   %ebx
  8005f1:	83 ec 34             	sub    $0x34,%esp
  8005f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8005f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800600:	8b 45 18             	mov    0x18(%ebp),%eax
  800603:	ba 00 00 00 00       	mov    $0x0,%edx
  800608:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80060b:	77 72                	ja     80067f <printnum+0x92>
  80060d:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800610:	72 05                	jb     800617 <printnum+0x2a>
  800612:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800615:	77 68                	ja     80067f <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800617:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80061a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80061d:	8b 45 18             	mov    0x18(%ebp),%eax
  800620:	ba 00 00 00 00       	mov    $0x0,%edx
  800625:	89 44 24 08          	mov    %eax,0x8(%esp)
  800629:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80062d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800630:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800633:	89 04 24             	mov    %eax,(%esp)
  800636:	89 54 24 04          	mov    %edx,0x4(%esp)
  80063a:	e8 a1 0b 00 00       	call   8011e0 <__udivdi3>
  80063f:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800642:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800646:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80064a:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80064d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800651:	89 44 24 08          	mov    %eax,0x8(%esp)
  800655:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800659:	8b 45 0c             	mov    0xc(%ebp),%eax
  80065c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800660:	8b 45 08             	mov    0x8(%ebp),%eax
  800663:	89 04 24             	mov    %eax,(%esp)
  800666:	e8 82 ff ff ff       	call   8005ed <printnum>
  80066b:	eb 1c                	jmp    800689 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80066d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800670:	89 44 24 04          	mov    %eax,0x4(%esp)
  800674:	8b 45 20             	mov    0x20(%ebp),%eax
  800677:	89 04 24             	mov    %eax,(%esp)
  80067a:	8b 45 08             	mov    0x8(%ebp),%eax
  80067d:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80067f:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800683:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800687:	7f e4                	jg     80066d <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800689:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80068c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800691:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800694:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800697:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80069b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80069f:	89 04 24             	mov    %eax,(%esp)
  8006a2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006a6:	e8 65 0c 00 00       	call   801310 <__umoddi3>
  8006ab:	05 c8 15 80 00       	add    $0x8015c8,%eax
  8006b0:	0f b6 00             	movzbl (%eax),%eax
  8006b3:	0f be c0             	movsbl %al,%eax
  8006b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006b9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006bd:	89 04 24             	mov    %eax,(%esp)
  8006c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c3:	ff d0                	call   *%eax
}
  8006c5:	83 c4 34             	add    $0x34,%esp
  8006c8:	5b                   	pop    %ebx
  8006c9:	5d                   	pop    %ebp
  8006ca:	c3                   	ret    

008006cb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8006cb:	55                   	push   %ebp
  8006cc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006ce:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8006d2:	7e 14                	jle    8006e8 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8006d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d7:	8b 00                	mov    (%eax),%eax
  8006d9:	8d 48 08             	lea    0x8(%eax),%ecx
  8006dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8006df:	89 0a                	mov    %ecx,(%edx)
  8006e1:	8b 50 04             	mov    0x4(%eax),%edx
  8006e4:	8b 00                	mov    (%eax),%eax
  8006e6:	eb 30                	jmp    800718 <getuint+0x4d>
	else if (lflag)
  8006e8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006ec:	74 16                	je     800704 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8006ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f1:	8b 00                	mov    (%eax),%eax
  8006f3:	8d 48 04             	lea    0x4(%eax),%ecx
  8006f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8006f9:	89 0a                	mov    %ecx,(%edx)
  8006fb:	8b 00                	mov    (%eax),%eax
  8006fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800702:	eb 14                	jmp    800718 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800704:	8b 45 08             	mov    0x8(%ebp),%eax
  800707:	8b 00                	mov    (%eax),%eax
  800709:	8d 48 04             	lea    0x4(%eax),%ecx
  80070c:	8b 55 08             	mov    0x8(%ebp),%edx
  80070f:	89 0a                	mov    %ecx,(%edx)
  800711:	8b 00                	mov    (%eax),%eax
  800713:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800718:	5d                   	pop    %ebp
  800719:	c3                   	ret    

0080071a <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80071a:	55                   	push   %ebp
  80071b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80071d:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800721:	7e 14                	jle    800737 <getint+0x1d>
		return va_arg(*ap, long long);
  800723:	8b 45 08             	mov    0x8(%ebp),%eax
  800726:	8b 00                	mov    (%eax),%eax
  800728:	8d 48 08             	lea    0x8(%eax),%ecx
  80072b:	8b 55 08             	mov    0x8(%ebp),%edx
  80072e:	89 0a                	mov    %ecx,(%edx)
  800730:	8b 50 04             	mov    0x4(%eax),%edx
  800733:	8b 00                	mov    (%eax),%eax
  800735:	eb 28                	jmp    80075f <getint+0x45>
	else if (lflag)
  800737:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80073b:	74 12                	je     80074f <getint+0x35>
		return va_arg(*ap, long);
  80073d:	8b 45 08             	mov    0x8(%ebp),%eax
  800740:	8b 00                	mov    (%eax),%eax
  800742:	8d 48 04             	lea    0x4(%eax),%ecx
  800745:	8b 55 08             	mov    0x8(%ebp),%edx
  800748:	89 0a                	mov    %ecx,(%edx)
  80074a:	8b 00                	mov    (%eax),%eax
  80074c:	99                   	cltd   
  80074d:	eb 10                	jmp    80075f <getint+0x45>
	else
		return va_arg(*ap, int);
  80074f:	8b 45 08             	mov    0x8(%ebp),%eax
  800752:	8b 00                	mov    (%eax),%eax
  800754:	8d 48 04             	lea    0x4(%eax),%ecx
  800757:	8b 55 08             	mov    0x8(%ebp),%edx
  80075a:	89 0a                	mov    %ecx,(%edx)
  80075c:	8b 00                	mov    (%eax),%eax
  80075e:	99                   	cltd   
}
  80075f:	5d                   	pop    %ebp
  800760:	c3                   	ret    

00800761 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	56                   	push   %esi
  800765:	53                   	push   %ebx
  800766:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800769:	eb 18                	jmp    800783 <vprintfmt+0x22>
			if (ch == '\0')
  80076b:	85 db                	test   %ebx,%ebx
  80076d:	75 05                	jne    800774 <vprintfmt+0x13>
				return;
  80076f:	e9 cc 03 00 00       	jmp    800b40 <vprintfmt+0x3df>
			putch(ch, putdat);
  800774:	8b 45 0c             	mov    0xc(%ebp),%eax
  800777:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077b:	89 1c 24             	mov    %ebx,(%esp)
  80077e:	8b 45 08             	mov    0x8(%ebp),%eax
  800781:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800783:	8b 45 10             	mov    0x10(%ebp),%eax
  800786:	8d 50 01             	lea    0x1(%eax),%edx
  800789:	89 55 10             	mov    %edx,0x10(%ebp)
  80078c:	0f b6 00             	movzbl (%eax),%eax
  80078f:	0f b6 d8             	movzbl %al,%ebx
  800792:	83 fb 25             	cmp    $0x25,%ebx
  800795:	75 d4                	jne    80076b <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800797:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80079b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8007a2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8007a9:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8007b0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ba:	8d 50 01             	lea    0x1(%eax),%edx
  8007bd:	89 55 10             	mov    %edx,0x10(%ebp)
  8007c0:	0f b6 00             	movzbl (%eax),%eax
  8007c3:	0f b6 d8             	movzbl %al,%ebx
  8007c6:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8007c9:	83 f8 55             	cmp    $0x55,%eax
  8007cc:	0f 87 3d 03 00 00    	ja     800b0f <vprintfmt+0x3ae>
  8007d2:	8b 04 85 ec 15 80 00 	mov    0x8015ec(,%eax,4),%eax
  8007d9:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8007db:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8007df:	eb d6                	jmp    8007b7 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8007e1:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8007e5:	eb d0                	jmp    8007b7 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007e7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8007ee:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007f1:	89 d0                	mov    %edx,%eax
  8007f3:	c1 e0 02             	shl    $0x2,%eax
  8007f6:	01 d0                	add    %edx,%eax
  8007f8:	01 c0                	add    %eax,%eax
  8007fa:	01 d8                	add    %ebx,%eax
  8007fc:	83 e8 30             	sub    $0x30,%eax
  8007ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800802:	8b 45 10             	mov    0x10(%ebp),%eax
  800805:	0f b6 00             	movzbl (%eax),%eax
  800808:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  80080b:	83 fb 2f             	cmp    $0x2f,%ebx
  80080e:	7e 0b                	jle    80081b <vprintfmt+0xba>
  800810:	83 fb 39             	cmp    $0x39,%ebx
  800813:	7f 06                	jg     80081b <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800815:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800819:	eb d3                	jmp    8007ee <vprintfmt+0x8d>
			goto process_precision;
  80081b:	eb 33                	jmp    800850 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  80081d:	8b 45 14             	mov    0x14(%ebp),%eax
  800820:	8d 50 04             	lea    0x4(%eax),%edx
  800823:	89 55 14             	mov    %edx,0x14(%ebp)
  800826:	8b 00                	mov    (%eax),%eax
  800828:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80082b:	eb 23                	jmp    800850 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  80082d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800831:	79 0c                	jns    80083f <vprintfmt+0xde>
				width = 0;
  800833:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  80083a:	e9 78 ff ff ff       	jmp    8007b7 <vprintfmt+0x56>
  80083f:	e9 73 ff ff ff       	jmp    8007b7 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800844:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80084b:	e9 67 ff ff ff       	jmp    8007b7 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800850:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800854:	79 12                	jns    800868 <vprintfmt+0x107>
				width = precision, precision = -1;
  800856:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800859:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80085c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800863:	e9 4f ff ff ff       	jmp    8007b7 <vprintfmt+0x56>
  800868:	e9 4a ff ff ff       	jmp    8007b7 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80086d:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800871:	e9 41 ff ff ff       	jmp    8007b7 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800876:	8b 45 14             	mov    0x14(%ebp),%eax
  800879:	8d 50 04             	lea    0x4(%eax),%edx
  80087c:	89 55 14             	mov    %edx,0x14(%ebp)
  80087f:	8b 00                	mov    (%eax),%eax
  800881:	8b 55 0c             	mov    0xc(%ebp),%edx
  800884:	89 54 24 04          	mov    %edx,0x4(%esp)
  800888:	89 04 24             	mov    %eax,(%esp)
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	ff d0                	call   *%eax
			break;
  800890:	e9 a5 02 00 00       	jmp    800b3a <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800895:	8b 45 14             	mov    0x14(%ebp),%eax
  800898:	8d 50 04             	lea    0x4(%eax),%edx
  80089b:	89 55 14             	mov    %edx,0x14(%ebp)
  80089e:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8008a0:	85 db                	test   %ebx,%ebx
  8008a2:	79 02                	jns    8008a6 <vprintfmt+0x145>
				err = -err;
  8008a4:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8008a6:	83 fb 09             	cmp    $0x9,%ebx
  8008a9:	7f 0b                	jg     8008b6 <vprintfmt+0x155>
  8008ab:	8b 34 9d a0 15 80 00 	mov    0x8015a0(,%ebx,4),%esi
  8008b2:	85 f6                	test   %esi,%esi
  8008b4:	75 23                	jne    8008d9 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8008b6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8008ba:	c7 44 24 08 d9 15 80 	movl   $0x8015d9,0x8(%esp)
  8008c1:	00 
  8008c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	89 04 24             	mov    %eax,(%esp)
  8008cf:	e8 73 02 00 00       	call   800b47 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8008d4:	e9 61 02 00 00       	jmp    800b3a <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8008d9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008dd:	c7 44 24 08 e2 15 80 	movl   $0x8015e2,0x8(%esp)
  8008e4:	00 
  8008e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ef:	89 04 24             	mov    %eax,(%esp)
  8008f2:	e8 50 02 00 00       	call   800b47 <printfmt>
			break;
  8008f7:	e9 3e 02 00 00       	jmp    800b3a <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ff:	8d 50 04             	lea    0x4(%eax),%edx
  800902:	89 55 14             	mov    %edx,0x14(%ebp)
  800905:	8b 30                	mov    (%eax),%esi
  800907:	85 f6                	test   %esi,%esi
  800909:	75 05                	jne    800910 <vprintfmt+0x1af>
				p = "(null)";
  80090b:	be e5 15 80 00       	mov    $0x8015e5,%esi
			if (width > 0 && padc != '-')
  800910:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800914:	7e 37                	jle    80094d <vprintfmt+0x1ec>
  800916:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  80091a:	74 31                	je     80094d <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  80091c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80091f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800923:	89 34 24             	mov    %esi,(%esp)
  800926:	e8 39 03 00 00       	call   800c64 <strnlen>
  80092b:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80092e:	eb 17                	jmp    800947 <vprintfmt+0x1e6>
					putch(padc, putdat);
  800930:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800934:	8b 55 0c             	mov    0xc(%ebp),%edx
  800937:	89 54 24 04          	mov    %edx,0x4(%esp)
  80093b:	89 04 24             	mov    %eax,(%esp)
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800943:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800947:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80094b:	7f e3                	jg     800930 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80094d:	eb 38                	jmp    800987 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  80094f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800953:	74 1f                	je     800974 <vprintfmt+0x213>
  800955:	83 fb 1f             	cmp    $0x1f,%ebx
  800958:	7e 05                	jle    80095f <vprintfmt+0x1fe>
  80095a:	83 fb 7e             	cmp    $0x7e,%ebx
  80095d:	7e 15                	jle    800974 <vprintfmt+0x213>
					putch('?', putdat);
  80095f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800962:	89 44 24 04          	mov    %eax,0x4(%esp)
  800966:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	ff d0                	call   *%eax
  800972:	eb 0f                	jmp    800983 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800974:	8b 45 0c             	mov    0xc(%ebp),%eax
  800977:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097b:	89 1c 24             	mov    %ebx,(%esp)
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800983:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800987:	89 f0                	mov    %esi,%eax
  800989:	8d 70 01             	lea    0x1(%eax),%esi
  80098c:	0f b6 00             	movzbl (%eax),%eax
  80098f:	0f be d8             	movsbl %al,%ebx
  800992:	85 db                	test   %ebx,%ebx
  800994:	74 10                	je     8009a6 <vprintfmt+0x245>
  800996:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80099a:	78 b3                	js     80094f <vprintfmt+0x1ee>
  80099c:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8009a0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009a4:	79 a9                	jns    80094f <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009a6:	eb 17                	jmp    8009bf <vprintfmt+0x25e>
				putch(' ', putdat);
  8009a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009af:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b9:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009bb:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8009bf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009c3:	7f e3                	jg     8009a8 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8009c5:	e9 70 01 00 00       	jmp    800b3a <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d1:	8d 45 14             	lea    0x14(%ebp),%eax
  8009d4:	89 04 24             	mov    %eax,(%esp)
  8009d7:	e8 3e fd ff ff       	call   80071a <getint>
  8009dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009df:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8009e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009e8:	85 d2                	test   %edx,%edx
  8009ea:	79 26                	jns    800a12 <vprintfmt+0x2b1>
				putch('-', putdat);
  8009ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	ff d0                	call   *%eax
				num = -(long long) num;
  8009ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a02:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a05:	f7 d8                	neg    %eax
  800a07:	83 d2 00             	adc    $0x0,%edx
  800a0a:	f7 da                	neg    %edx
  800a0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a0f:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800a12:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a19:	e9 a8 00 00 00       	jmp    800ac6 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a1e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a21:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a25:	8d 45 14             	lea    0x14(%ebp),%eax
  800a28:	89 04 24             	mov    %eax,(%esp)
  800a2b:	e8 9b fc ff ff       	call   8006cb <getuint>
  800a30:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a33:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800a36:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a3d:	e9 84 00 00 00       	jmp    800ac6 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a42:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a45:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a49:	8d 45 14             	lea    0x14(%ebp),%eax
  800a4c:	89 04 24             	mov    %eax,(%esp)
  800a4f:	e8 77 fc ff ff       	call   8006cb <getuint>
  800a54:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a57:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800a5a:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800a61:	eb 63                	jmp    800ac6 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a63:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a66:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a6a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a71:	8b 45 08             	mov    0x8(%ebp),%eax
  800a74:	ff d0                	call   *%eax
			putch('x', putdat);
  800a76:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a79:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a7d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a84:	8b 45 08             	mov    0x8(%ebp),%eax
  800a87:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a89:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8c:	8d 50 04             	lea    0x4(%eax),%edx
  800a8f:	89 55 14             	mov    %edx,0x14(%ebp)
  800a92:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a94:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a9e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800aa5:	eb 1f                	jmp    800ac6 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800aa7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800aaa:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aae:	8d 45 14             	lea    0x14(%ebp),%eax
  800ab1:	89 04 24             	mov    %eax,(%esp)
  800ab4:	e8 12 fc ff ff       	call   8006cb <getuint>
  800ab9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800abc:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800abf:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ac6:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800aca:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800acd:	89 54 24 18          	mov    %edx,0x18(%esp)
  800ad1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ad4:	89 54 24 14          	mov    %edx,0x14(%esp)
  800ad8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800adc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800adf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ae2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ae6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800aea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aed:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af1:	8b 45 08             	mov    0x8(%ebp),%eax
  800af4:	89 04 24             	mov    %eax,(%esp)
  800af7:	e8 f1 fa ff ff       	call   8005ed <printnum>
			break;
  800afc:	eb 3c                	jmp    800b3a <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800afe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b01:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b05:	89 1c 24             	mov    %ebx,(%esp)
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0b:	ff d0                	call   *%eax
			break;
  800b0d:	eb 2b                	jmp    800b3a <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b12:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b16:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b20:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b22:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b26:	eb 04                	jmp    800b2c <vprintfmt+0x3cb>
  800b28:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b2c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b2f:	83 e8 01             	sub    $0x1,%eax
  800b32:	0f b6 00             	movzbl (%eax),%eax
  800b35:	3c 25                	cmp    $0x25,%al
  800b37:	75 ef                	jne    800b28 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800b39:	90                   	nop
		}
	}
  800b3a:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b3b:	e9 43 fc ff ff       	jmp    800783 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800b40:	83 c4 40             	add    $0x40,%esp
  800b43:	5b                   	pop    %ebx
  800b44:	5e                   	pop    %esi
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b4d:	8d 45 14             	lea    0x14(%ebp),%eax
  800b50:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b56:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b5a:	8b 45 10             	mov    0x10(%ebp),%eax
  800b5d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b64:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b68:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6b:	89 04 24             	mov    %eax,(%esp)
  800b6e:	e8 ee fb ff ff       	call   800761 <vprintfmt>
	va_end(ap);
}
  800b73:	c9                   	leave  
  800b74:	c3                   	ret    

00800b75 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800b78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7b:	8b 40 08             	mov    0x8(%eax),%eax
  800b7e:	8d 50 01             	lea    0x1(%eax),%edx
  800b81:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b84:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b8a:	8b 10                	mov    (%eax),%edx
  800b8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b8f:	8b 40 04             	mov    0x4(%eax),%eax
  800b92:	39 c2                	cmp    %eax,%edx
  800b94:	73 12                	jae    800ba8 <sprintputch+0x33>
		*b->buf++ = ch;
  800b96:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b99:	8b 00                	mov    (%eax),%eax
  800b9b:	8d 48 01             	lea    0x1(%eax),%ecx
  800b9e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba1:	89 0a                	mov    %ecx,(%edx)
  800ba3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba6:	88 10                	mov    %dl,(%eax)
}
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb9:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbf:	01 d0                	add    %edx,%eax
  800bc1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800bc4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bcb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800bcf:	74 06                	je     800bd7 <vsnprintf+0x2d>
  800bd1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd5:	7f 07                	jg     800bde <vsnprintf+0x34>
		return -E_INVAL;
  800bd7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bdc:	eb 2a                	jmp    800c08 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bde:	8b 45 14             	mov    0x14(%ebp),%eax
  800be1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800be5:	8b 45 10             	mov    0x10(%ebp),%eax
  800be8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bec:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bef:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bf3:	c7 04 24 75 0b 80 00 	movl   $0x800b75,(%esp)
  800bfa:	e8 62 fb ff ff       	call   800761 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bff:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c02:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c08:	c9                   	leave  
  800c09:	c3                   	ret    

00800c0a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c10:	8d 45 14             	lea    0x14(%ebp),%eax
  800c13:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800c16:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c1d:	8b 45 10             	mov    0x10(%ebp),%eax
  800c20:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c27:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2e:	89 04 24             	mov    %eax,(%esp)
  800c31:	e8 74 ff ff ff       	call   800baa <vsnprintf>
  800c36:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c3c:	c9                   	leave  
  800c3d:	c3                   	ret    

00800c3e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800c44:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c4b:	eb 08                	jmp    800c55 <strlen+0x17>
		n++;
  800c4d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c51:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c55:	8b 45 08             	mov    0x8(%ebp),%eax
  800c58:	0f b6 00             	movzbl (%eax),%eax
  800c5b:	84 c0                	test   %al,%al
  800c5d:	75 ee                	jne    800c4d <strlen+0xf>
		n++;
	return n;
  800c5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c62:	c9                   	leave  
  800c63:	c3                   	ret    

00800c64 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c6a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c71:	eb 0c                	jmp    800c7f <strnlen+0x1b>
		n++;
  800c73:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c77:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c7b:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800c7f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c83:	74 0a                	je     800c8f <strnlen+0x2b>
  800c85:	8b 45 08             	mov    0x8(%ebp),%eax
  800c88:	0f b6 00             	movzbl (%eax),%eax
  800c8b:	84 c0                	test   %al,%al
  800c8d:	75 e4                	jne    800c73 <strnlen+0xf>
		n++;
	return n;
  800c8f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c92:	c9                   	leave  
  800c93:	c3                   	ret    

00800c94 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800ca0:	90                   	nop
  800ca1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca4:	8d 50 01             	lea    0x1(%eax),%edx
  800ca7:	89 55 08             	mov    %edx,0x8(%ebp)
  800caa:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cad:	8d 4a 01             	lea    0x1(%edx),%ecx
  800cb0:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800cb3:	0f b6 12             	movzbl (%edx),%edx
  800cb6:	88 10                	mov    %dl,(%eax)
  800cb8:	0f b6 00             	movzbl (%eax),%eax
  800cbb:	84 c0                	test   %al,%al
  800cbd:	75 e2                	jne    800ca1 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800cbf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800cc2:	c9                   	leave  
  800cc3:	c3                   	ret    

00800cc4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800cca:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccd:	89 04 24             	mov    %eax,(%esp)
  800cd0:	e8 69 ff ff ff       	call   800c3e <strlen>
  800cd5:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800cd8:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cde:	01 c2                	add    %eax,%edx
  800ce0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ce7:	89 14 24             	mov    %edx,(%esp)
  800cea:	e8 a5 ff ff ff       	call   800c94 <strcpy>
	return dst;
  800cef:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cf2:	c9                   	leave  
  800cf3:	c3                   	ret    

00800cf4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800cfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfd:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800d00:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800d07:	eb 23                	jmp    800d2c <strncpy+0x38>
		*dst++ = *src;
  800d09:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0c:	8d 50 01             	lea    0x1(%eax),%edx
  800d0f:	89 55 08             	mov    %edx,0x8(%ebp)
  800d12:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d15:	0f b6 12             	movzbl (%edx),%edx
  800d18:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800d1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1d:	0f b6 00             	movzbl (%eax),%eax
  800d20:	84 c0                	test   %al,%al
  800d22:	74 04                	je     800d28 <strncpy+0x34>
			src++;
  800d24:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d28:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d2c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d2f:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d32:	72 d5                	jb     800d09 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800d34:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d37:	c9                   	leave  
  800d38:	c3                   	ret    

00800d39 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d42:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800d45:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d49:	74 33                	je     800d7e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d4b:	eb 17                	jmp    800d64 <strlcpy+0x2b>
			*dst++ = *src++;
  800d4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d50:	8d 50 01             	lea    0x1(%eax),%edx
  800d53:	89 55 08             	mov    %edx,0x8(%ebp)
  800d56:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d59:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d5c:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d5f:	0f b6 12             	movzbl (%edx),%edx
  800d62:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d64:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d68:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d6c:	74 0a                	je     800d78 <strlcpy+0x3f>
  800d6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d71:	0f b6 00             	movzbl (%eax),%eax
  800d74:	84 c0                	test   %al,%al
  800d76:	75 d5                	jne    800d4d <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800d78:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d81:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d84:	29 c2                	sub    %eax,%edx
  800d86:	89 d0                	mov    %edx,%eax
}
  800d88:	c9                   	leave  
  800d89:	c3                   	ret    

00800d8a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d8d:	eb 08                	jmp    800d97 <strcmp+0xd>
		p++, q++;
  800d8f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d93:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d97:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9a:	0f b6 00             	movzbl (%eax),%eax
  800d9d:	84 c0                	test   %al,%al
  800d9f:	74 10                	je     800db1 <strcmp+0x27>
  800da1:	8b 45 08             	mov    0x8(%ebp),%eax
  800da4:	0f b6 10             	movzbl (%eax),%edx
  800da7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800daa:	0f b6 00             	movzbl (%eax),%eax
  800dad:	38 c2                	cmp    %al,%dl
  800daf:	74 de                	je     800d8f <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800db1:	8b 45 08             	mov    0x8(%ebp),%eax
  800db4:	0f b6 00             	movzbl (%eax),%eax
  800db7:	0f b6 d0             	movzbl %al,%edx
  800dba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dbd:	0f b6 00             	movzbl (%eax),%eax
  800dc0:	0f b6 c0             	movzbl %al,%eax
  800dc3:	29 c2                	sub    %eax,%edx
  800dc5:	89 d0                	mov    %edx,%eax
}
  800dc7:	5d                   	pop    %ebp
  800dc8:	c3                   	ret    

00800dc9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800dc9:	55                   	push   %ebp
  800dca:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800dcc:	eb 0c                	jmp    800dda <strncmp+0x11>
		n--, p++, q++;
  800dce:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800dd2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dd6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dda:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dde:	74 1a                	je     800dfa <strncmp+0x31>
  800de0:	8b 45 08             	mov    0x8(%ebp),%eax
  800de3:	0f b6 00             	movzbl (%eax),%eax
  800de6:	84 c0                	test   %al,%al
  800de8:	74 10                	je     800dfa <strncmp+0x31>
  800dea:	8b 45 08             	mov    0x8(%ebp),%eax
  800ded:	0f b6 10             	movzbl (%eax),%edx
  800df0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df3:	0f b6 00             	movzbl (%eax),%eax
  800df6:	38 c2                	cmp    %al,%dl
  800df8:	74 d4                	je     800dce <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800dfa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dfe:	75 07                	jne    800e07 <strncmp+0x3e>
		return 0;
  800e00:	b8 00 00 00 00       	mov    $0x0,%eax
  800e05:	eb 16                	jmp    800e1d <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e07:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0a:	0f b6 00             	movzbl (%eax),%eax
  800e0d:	0f b6 d0             	movzbl %al,%edx
  800e10:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e13:	0f b6 00             	movzbl (%eax),%eax
  800e16:	0f b6 c0             	movzbl %al,%eax
  800e19:	29 c2                	sub    %eax,%edx
  800e1b:	89 d0                	mov    %edx,%eax
}
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    

00800e1f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	83 ec 04             	sub    $0x4,%esp
  800e25:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e28:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e2b:	eb 14                	jmp    800e41 <strchr+0x22>
		if (*s == c)
  800e2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e30:	0f b6 00             	movzbl (%eax),%eax
  800e33:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e36:	75 05                	jne    800e3d <strchr+0x1e>
			return (char *) s;
  800e38:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3b:	eb 13                	jmp    800e50 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e3d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e41:	8b 45 08             	mov    0x8(%ebp),%eax
  800e44:	0f b6 00             	movzbl (%eax),%eax
  800e47:	84 c0                	test   %al,%al
  800e49:	75 e2                	jne    800e2d <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e50:	c9                   	leave  
  800e51:	c3                   	ret    

00800e52 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
  800e55:	83 ec 04             	sub    $0x4,%esp
  800e58:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5b:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e5e:	eb 11                	jmp    800e71 <strfind+0x1f>
		if (*s == c)
  800e60:	8b 45 08             	mov    0x8(%ebp),%eax
  800e63:	0f b6 00             	movzbl (%eax),%eax
  800e66:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e69:	75 02                	jne    800e6d <strfind+0x1b>
			break;
  800e6b:	eb 0e                	jmp    800e7b <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e6d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e71:	8b 45 08             	mov    0x8(%ebp),%eax
  800e74:	0f b6 00             	movzbl (%eax),%eax
  800e77:	84 c0                	test   %al,%al
  800e79:	75 e5                	jne    800e60 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800e7b:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e7e:	c9                   	leave  
  800e7f:	c3                   	ret    

00800e80 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e84:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e88:	75 05                	jne    800e8f <memset+0xf>
		return v;
  800e8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8d:	eb 5c                	jmp    800eeb <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e92:	83 e0 03             	and    $0x3,%eax
  800e95:	85 c0                	test   %eax,%eax
  800e97:	75 41                	jne    800eda <memset+0x5a>
  800e99:	8b 45 10             	mov    0x10(%ebp),%eax
  800e9c:	83 e0 03             	and    $0x3,%eax
  800e9f:	85 c0                	test   %eax,%eax
  800ea1:	75 37                	jne    800eda <memset+0x5a>
		c &= 0xFF;
  800ea3:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800eaa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ead:	c1 e0 18             	shl    $0x18,%eax
  800eb0:	89 c2                	mov    %eax,%edx
  800eb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eb5:	c1 e0 10             	shl    $0x10,%eax
  800eb8:	09 c2                	or     %eax,%edx
  800eba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ebd:	c1 e0 08             	shl    $0x8,%eax
  800ec0:	09 d0                	or     %edx,%eax
  800ec2:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ec5:	8b 45 10             	mov    0x10(%ebp),%eax
  800ec8:	c1 e8 02             	shr    $0x2,%eax
  800ecb:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ecd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed3:	89 d7                	mov    %edx,%edi
  800ed5:	fc                   	cld    
  800ed6:	f3 ab                	rep stos %eax,%es:(%edi)
  800ed8:	eb 0e                	jmp    800ee8 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800eda:	8b 55 08             	mov    0x8(%ebp),%edx
  800edd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ee3:	89 d7                	mov    %edx,%edi
  800ee5:	fc                   	cld    
  800ee6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800ee8:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800eeb:	5f                   	pop    %edi
  800eec:	5d                   	pop    %ebp
  800eed:	c3                   	ret    

00800eee <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
  800ef1:	57                   	push   %edi
  800ef2:	56                   	push   %esi
  800ef3:	53                   	push   %ebx
  800ef4:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800ef7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800efa:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800efd:	8b 45 08             	mov    0x8(%ebp),%eax
  800f00:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800f03:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f06:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f09:	73 6d                	jae    800f78 <memmove+0x8a>
  800f0b:	8b 45 10             	mov    0x10(%ebp),%eax
  800f0e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f11:	01 d0                	add    %edx,%eax
  800f13:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f16:	76 60                	jbe    800f78 <memmove+0x8a>
		s += n;
  800f18:	8b 45 10             	mov    0x10(%ebp),%eax
  800f1b:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800f1e:	8b 45 10             	mov    0x10(%ebp),%eax
  800f21:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f24:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f27:	83 e0 03             	and    $0x3,%eax
  800f2a:	85 c0                	test   %eax,%eax
  800f2c:	75 2f                	jne    800f5d <memmove+0x6f>
  800f2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f31:	83 e0 03             	and    $0x3,%eax
  800f34:	85 c0                	test   %eax,%eax
  800f36:	75 25                	jne    800f5d <memmove+0x6f>
  800f38:	8b 45 10             	mov    0x10(%ebp),%eax
  800f3b:	83 e0 03             	and    $0x3,%eax
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	75 1b                	jne    800f5d <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f42:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f45:	83 e8 04             	sub    $0x4,%eax
  800f48:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f4b:	83 ea 04             	sub    $0x4,%edx
  800f4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f51:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f54:	89 c7                	mov    %eax,%edi
  800f56:	89 d6                	mov    %edx,%esi
  800f58:	fd                   	std    
  800f59:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f5b:	eb 18                	jmp    800f75 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f5d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f60:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f66:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f69:	8b 45 10             	mov    0x10(%ebp),%eax
  800f6c:	89 d7                	mov    %edx,%edi
  800f6e:	89 de                	mov    %ebx,%esi
  800f70:	89 c1                	mov    %eax,%ecx
  800f72:	fd                   	std    
  800f73:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f75:	fc                   	cld    
  800f76:	eb 45                	jmp    800fbd <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f78:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f7b:	83 e0 03             	and    $0x3,%eax
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	75 2b                	jne    800fad <memmove+0xbf>
  800f82:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f85:	83 e0 03             	and    $0x3,%eax
  800f88:	85 c0                	test   %eax,%eax
  800f8a:	75 21                	jne    800fad <memmove+0xbf>
  800f8c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f8f:	83 e0 03             	and    $0x3,%eax
  800f92:	85 c0                	test   %eax,%eax
  800f94:	75 17                	jne    800fad <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f96:	8b 45 10             	mov    0x10(%ebp),%eax
  800f99:	c1 e8 02             	shr    $0x2,%eax
  800f9c:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fa1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fa4:	89 c7                	mov    %eax,%edi
  800fa6:	89 d6                	mov    %edx,%esi
  800fa8:	fc                   	cld    
  800fa9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fab:	eb 10                	jmp    800fbd <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fad:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fb0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fb3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fb6:	89 c7                	mov    %eax,%edi
  800fb8:	89 d6                	mov    %edx,%esi
  800fba:	fc                   	cld    
  800fbb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800fbd:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800fc0:	83 c4 10             	add    $0x10,%esp
  800fc3:	5b                   	pop    %ebx
  800fc4:	5e                   	pop    %esi
  800fc5:	5f                   	pop    %edi
  800fc6:	5d                   	pop    %ebp
  800fc7:	c3                   	ret    

00800fc8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800fc8:	55                   	push   %ebp
  800fc9:	89 e5                	mov    %esp,%ebp
  800fcb:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800fce:	8b 45 10             	mov    0x10(%ebp),%eax
  800fd1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fd5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdf:	89 04 24             	mov    %eax,(%esp)
  800fe2:	e8 07 ff ff ff       	call   800eee <memmove>
}
  800fe7:	c9                   	leave  
  800fe8:	c3                   	ret    

00800fe9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800fef:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800ff5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff8:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800ffb:	eb 30                	jmp    80102d <memcmp+0x44>
		if (*s1 != *s2)
  800ffd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801000:	0f b6 10             	movzbl (%eax),%edx
  801003:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801006:	0f b6 00             	movzbl (%eax),%eax
  801009:	38 c2                	cmp    %al,%dl
  80100b:	74 18                	je     801025 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  80100d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801010:	0f b6 00             	movzbl (%eax),%eax
  801013:	0f b6 d0             	movzbl %al,%edx
  801016:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801019:	0f b6 00             	movzbl (%eax),%eax
  80101c:	0f b6 c0             	movzbl %al,%eax
  80101f:	29 c2                	sub    %eax,%edx
  801021:	89 d0                	mov    %edx,%eax
  801023:	eb 1a                	jmp    80103f <memcmp+0x56>
		s1++, s2++;
  801025:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  801029:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80102d:	8b 45 10             	mov    0x10(%ebp),%eax
  801030:	8d 50 ff             	lea    -0x1(%eax),%edx
  801033:	89 55 10             	mov    %edx,0x10(%ebp)
  801036:	85 c0                	test   %eax,%eax
  801038:	75 c3                	jne    800ffd <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80103a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80103f:	c9                   	leave  
  801040:	c3                   	ret    

00801041 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  801047:	8b 45 10             	mov    0x10(%ebp),%eax
  80104a:	8b 55 08             	mov    0x8(%ebp),%edx
  80104d:	01 d0                	add    %edx,%eax
  80104f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801052:	eb 13                	jmp    801067 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801054:	8b 45 08             	mov    0x8(%ebp),%eax
  801057:	0f b6 10             	movzbl (%eax),%edx
  80105a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80105d:	38 c2                	cmp    %al,%dl
  80105f:	75 02                	jne    801063 <memfind+0x22>
			break;
  801061:	eb 0c                	jmp    80106f <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801063:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801067:	8b 45 08             	mov    0x8(%ebp),%eax
  80106a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  80106d:	72 e5                	jb     801054 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  80106f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801072:	c9                   	leave  
  801073:	c3                   	ret    

00801074 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  80107a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  801081:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801088:	eb 04                	jmp    80108e <strtol+0x1a>
		s++;
  80108a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80108e:	8b 45 08             	mov    0x8(%ebp),%eax
  801091:	0f b6 00             	movzbl (%eax),%eax
  801094:	3c 20                	cmp    $0x20,%al
  801096:	74 f2                	je     80108a <strtol+0x16>
  801098:	8b 45 08             	mov    0x8(%ebp),%eax
  80109b:	0f b6 00             	movzbl (%eax),%eax
  80109e:	3c 09                	cmp    $0x9,%al
  8010a0:	74 e8                	je     80108a <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  8010a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a5:	0f b6 00             	movzbl (%eax),%eax
  8010a8:	3c 2b                	cmp    $0x2b,%al
  8010aa:	75 06                	jne    8010b2 <strtol+0x3e>
		s++;
  8010ac:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010b0:	eb 15                	jmp    8010c7 <strtol+0x53>
	else if (*s == '-')
  8010b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b5:	0f b6 00             	movzbl (%eax),%eax
  8010b8:	3c 2d                	cmp    $0x2d,%al
  8010ba:	75 0b                	jne    8010c7 <strtol+0x53>
		s++, neg = 1;
  8010bc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010c0:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010c7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010cb:	74 06                	je     8010d3 <strtol+0x5f>
  8010cd:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8010d1:	75 24                	jne    8010f7 <strtol+0x83>
  8010d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d6:	0f b6 00             	movzbl (%eax),%eax
  8010d9:	3c 30                	cmp    $0x30,%al
  8010db:	75 1a                	jne    8010f7 <strtol+0x83>
  8010dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e0:	83 c0 01             	add    $0x1,%eax
  8010e3:	0f b6 00             	movzbl (%eax),%eax
  8010e6:	3c 78                	cmp    $0x78,%al
  8010e8:	75 0d                	jne    8010f7 <strtol+0x83>
		s += 2, base = 16;
  8010ea:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8010ee:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8010f5:	eb 2a                	jmp    801121 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  8010f7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010fb:	75 17                	jne    801114 <strtol+0xa0>
  8010fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801100:	0f b6 00             	movzbl (%eax),%eax
  801103:	3c 30                	cmp    $0x30,%al
  801105:	75 0d                	jne    801114 <strtol+0xa0>
		s++, base = 8;
  801107:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80110b:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801112:	eb 0d                	jmp    801121 <strtol+0xad>
	else if (base == 0)
  801114:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801118:	75 07                	jne    801121 <strtol+0xad>
		base = 10;
  80111a:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801121:	8b 45 08             	mov    0x8(%ebp),%eax
  801124:	0f b6 00             	movzbl (%eax),%eax
  801127:	3c 2f                	cmp    $0x2f,%al
  801129:	7e 1b                	jle    801146 <strtol+0xd2>
  80112b:	8b 45 08             	mov    0x8(%ebp),%eax
  80112e:	0f b6 00             	movzbl (%eax),%eax
  801131:	3c 39                	cmp    $0x39,%al
  801133:	7f 11                	jg     801146 <strtol+0xd2>
			dig = *s - '0';
  801135:	8b 45 08             	mov    0x8(%ebp),%eax
  801138:	0f b6 00             	movzbl (%eax),%eax
  80113b:	0f be c0             	movsbl %al,%eax
  80113e:	83 e8 30             	sub    $0x30,%eax
  801141:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801144:	eb 48                	jmp    80118e <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  801146:	8b 45 08             	mov    0x8(%ebp),%eax
  801149:	0f b6 00             	movzbl (%eax),%eax
  80114c:	3c 60                	cmp    $0x60,%al
  80114e:	7e 1b                	jle    80116b <strtol+0xf7>
  801150:	8b 45 08             	mov    0x8(%ebp),%eax
  801153:	0f b6 00             	movzbl (%eax),%eax
  801156:	3c 7a                	cmp    $0x7a,%al
  801158:	7f 11                	jg     80116b <strtol+0xf7>
			dig = *s - 'a' + 10;
  80115a:	8b 45 08             	mov    0x8(%ebp),%eax
  80115d:	0f b6 00             	movzbl (%eax),%eax
  801160:	0f be c0             	movsbl %al,%eax
  801163:	83 e8 57             	sub    $0x57,%eax
  801166:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801169:	eb 23                	jmp    80118e <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  80116b:	8b 45 08             	mov    0x8(%ebp),%eax
  80116e:	0f b6 00             	movzbl (%eax),%eax
  801171:	3c 40                	cmp    $0x40,%al
  801173:	7e 3d                	jle    8011b2 <strtol+0x13e>
  801175:	8b 45 08             	mov    0x8(%ebp),%eax
  801178:	0f b6 00             	movzbl (%eax),%eax
  80117b:	3c 5a                	cmp    $0x5a,%al
  80117d:	7f 33                	jg     8011b2 <strtol+0x13e>
			dig = *s - 'A' + 10;
  80117f:	8b 45 08             	mov    0x8(%ebp),%eax
  801182:	0f b6 00             	movzbl (%eax),%eax
  801185:	0f be c0             	movsbl %al,%eax
  801188:	83 e8 37             	sub    $0x37,%eax
  80118b:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  80118e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801191:	3b 45 10             	cmp    0x10(%ebp),%eax
  801194:	7c 02                	jl     801198 <strtol+0x124>
			break;
  801196:	eb 1a                	jmp    8011b2 <strtol+0x13e>
		s++, val = (val * base) + dig;
  801198:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80119c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80119f:	0f af 45 10          	imul   0x10(%ebp),%eax
  8011a3:	89 c2                	mov    %eax,%edx
  8011a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a8:	01 d0                	add    %edx,%eax
  8011aa:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  8011ad:	e9 6f ff ff ff       	jmp    801121 <strtol+0xad>

	if (endptr)
  8011b2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011b6:	74 08                	je     8011c0 <strtol+0x14c>
		*endptr = (char *) s;
  8011b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8011be:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8011c0:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8011c4:	74 07                	je     8011cd <strtol+0x159>
  8011c6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011c9:	f7 d8                	neg    %eax
  8011cb:	eb 03                	jmp    8011d0 <strtol+0x15c>
  8011cd:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8011d0:	c9                   	leave  
  8011d1:	c3                   	ret    
  8011d2:	66 90                	xchg   %ax,%ax
  8011d4:	66 90                	xchg   %ax,%ax
  8011d6:	66 90                	xchg   %ax,%ax
  8011d8:	66 90                	xchg   %ax,%ax
  8011da:	66 90                	xchg   %ax,%ax
  8011dc:	66 90                	xchg   %ax,%ax
  8011de:	66 90                	xchg   %ax,%ax

008011e0 <__udivdi3>:
  8011e0:	55                   	push   %ebp
  8011e1:	57                   	push   %edi
  8011e2:	56                   	push   %esi
  8011e3:	83 ec 0c             	sub    $0xc,%esp
  8011e6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8011ea:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8011ee:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8011f2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8011f6:	85 c0                	test   %eax,%eax
  8011f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011fc:	89 ea                	mov    %ebp,%edx
  8011fe:	89 0c 24             	mov    %ecx,(%esp)
  801201:	75 2d                	jne    801230 <__udivdi3+0x50>
  801203:	39 e9                	cmp    %ebp,%ecx
  801205:	77 61                	ja     801268 <__udivdi3+0x88>
  801207:	85 c9                	test   %ecx,%ecx
  801209:	89 ce                	mov    %ecx,%esi
  80120b:	75 0b                	jne    801218 <__udivdi3+0x38>
  80120d:	b8 01 00 00 00       	mov    $0x1,%eax
  801212:	31 d2                	xor    %edx,%edx
  801214:	f7 f1                	div    %ecx
  801216:	89 c6                	mov    %eax,%esi
  801218:	31 d2                	xor    %edx,%edx
  80121a:	89 e8                	mov    %ebp,%eax
  80121c:	f7 f6                	div    %esi
  80121e:	89 c5                	mov    %eax,%ebp
  801220:	89 f8                	mov    %edi,%eax
  801222:	f7 f6                	div    %esi
  801224:	89 ea                	mov    %ebp,%edx
  801226:	83 c4 0c             	add    $0xc,%esp
  801229:	5e                   	pop    %esi
  80122a:	5f                   	pop    %edi
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    
  80122d:	8d 76 00             	lea    0x0(%esi),%esi
  801230:	39 e8                	cmp    %ebp,%eax
  801232:	77 24                	ja     801258 <__udivdi3+0x78>
  801234:	0f bd e8             	bsr    %eax,%ebp
  801237:	83 f5 1f             	xor    $0x1f,%ebp
  80123a:	75 3c                	jne    801278 <__udivdi3+0x98>
  80123c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801240:	39 34 24             	cmp    %esi,(%esp)
  801243:	0f 86 9f 00 00 00    	jbe    8012e8 <__udivdi3+0x108>
  801249:	39 d0                	cmp    %edx,%eax
  80124b:	0f 82 97 00 00 00    	jb     8012e8 <__udivdi3+0x108>
  801251:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801258:	31 d2                	xor    %edx,%edx
  80125a:	31 c0                	xor    %eax,%eax
  80125c:	83 c4 0c             	add    $0xc,%esp
  80125f:	5e                   	pop    %esi
  801260:	5f                   	pop    %edi
  801261:	5d                   	pop    %ebp
  801262:	c3                   	ret    
  801263:	90                   	nop
  801264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801268:	89 f8                	mov    %edi,%eax
  80126a:	f7 f1                	div    %ecx
  80126c:	31 d2                	xor    %edx,%edx
  80126e:	83 c4 0c             	add    $0xc,%esp
  801271:	5e                   	pop    %esi
  801272:	5f                   	pop    %edi
  801273:	5d                   	pop    %ebp
  801274:	c3                   	ret    
  801275:	8d 76 00             	lea    0x0(%esi),%esi
  801278:	89 e9                	mov    %ebp,%ecx
  80127a:	8b 3c 24             	mov    (%esp),%edi
  80127d:	d3 e0                	shl    %cl,%eax
  80127f:	89 c6                	mov    %eax,%esi
  801281:	b8 20 00 00 00       	mov    $0x20,%eax
  801286:	29 e8                	sub    %ebp,%eax
  801288:	89 c1                	mov    %eax,%ecx
  80128a:	d3 ef                	shr    %cl,%edi
  80128c:	89 e9                	mov    %ebp,%ecx
  80128e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801292:	8b 3c 24             	mov    (%esp),%edi
  801295:	09 74 24 08          	or     %esi,0x8(%esp)
  801299:	89 d6                	mov    %edx,%esi
  80129b:	d3 e7                	shl    %cl,%edi
  80129d:	89 c1                	mov    %eax,%ecx
  80129f:	89 3c 24             	mov    %edi,(%esp)
  8012a2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012a6:	d3 ee                	shr    %cl,%esi
  8012a8:	89 e9                	mov    %ebp,%ecx
  8012aa:	d3 e2                	shl    %cl,%edx
  8012ac:	89 c1                	mov    %eax,%ecx
  8012ae:	d3 ef                	shr    %cl,%edi
  8012b0:	09 d7                	or     %edx,%edi
  8012b2:	89 f2                	mov    %esi,%edx
  8012b4:	89 f8                	mov    %edi,%eax
  8012b6:	f7 74 24 08          	divl   0x8(%esp)
  8012ba:	89 d6                	mov    %edx,%esi
  8012bc:	89 c7                	mov    %eax,%edi
  8012be:	f7 24 24             	mull   (%esp)
  8012c1:	39 d6                	cmp    %edx,%esi
  8012c3:	89 14 24             	mov    %edx,(%esp)
  8012c6:	72 30                	jb     8012f8 <__udivdi3+0x118>
  8012c8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012cc:	89 e9                	mov    %ebp,%ecx
  8012ce:	d3 e2                	shl    %cl,%edx
  8012d0:	39 c2                	cmp    %eax,%edx
  8012d2:	73 05                	jae    8012d9 <__udivdi3+0xf9>
  8012d4:	3b 34 24             	cmp    (%esp),%esi
  8012d7:	74 1f                	je     8012f8 <__udivdi3+0x118>
  8012d9:	89 f8                	mov    %edi,%eax
  8012db:	31 d2                	xor    %edx,%edx
  8012dd:	e9 7a ff ff ff       	jmp    80125c <__udivdi3+0x7c>
  8012e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012e8:	31 d2                	xor    %edx,%edx
  8012ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8012ef:	e9 68 ff ff ff       	jmp    80125c <__udivdi3+0x7c>
  8012f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012f8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8012fb:	31 d2                	xor    %edx,%edx
  8012fd:	83 c4 0c             	add    $0xc,%esp
  801300:	5e                   	pop    %esi
  801301:	5f                   	pop    %edi
  801302:	5d                   	pop    %ebp
  801303:	c3                   	ret    
  801304:	66 90                	xchg   %ax,%ax
  801306:	66 90                	xchg   %ax,%ax
  801308:	66 90                	xchg   %ax,%ax
  80130a:	66 90                	xchg   %ax,%ax
  80130c:	66 90                	xchg   %ax,%ax
  80130e:	66 90                	xchg   %ax,%ax

00801310 <__umoddi3>:
  801310:	55                   	push   %ebp
  801311:	57                   	push   %edi
  801312:	56                   	push   %esi
  801313:	83 ec 14             	sub    $0x14,%esp
  801316:	8b 44 24 28          	mov    0x28(%esp),%eax
  80131a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80131e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801322:	89 c7                	mov    %eax,%edi
  801324:	89 44 24 04          	mov    %eax,0x4(%esp)
  801328:	8b 44 24 30          	mov    0x30(%esp),%eax
  80132c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801330:	89 34 24             	mov    %esi,(%esp)
  801333:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801337:	85 c0                	test   %eax,%eax
  801339:	89 c2                	mov    %eax,%edx
  80133b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80133f:	75 17                	jne    801358 <__umoddi3+0x48>
  801341:	39 fe                	cmp    %edi,%esi
  801343:	76 4b                	jbe    801390 <__umoddi3+0x80>
  801345:	89 c8                	mov    %ecx,%eax
  801347:	89 fa                	mov    %edi,%edx
  801349:	f7 f6                	div    %esi
  80134b:	89 d0                	mov    %edx,%eax
  80134d:	31 d2                	xor    %edx,%edx
  80134f:	83 c4 14             	add    $0x14,%esp
  801352:	5e                   	pop    %esi
  801353:	5f                   	pop    %edi
  801354:	5d                   	pop    %ebp
  801355:	c3                   	ret    
  801356:	66 90                	xchg   %ax,%ax
  801358:	39 f8                	cmp    %edi,%eax
  80135a:	77 54                	ja     8013b0 <__umoddi3+0xa0>
  80135c:	0f bd e8             	bsr    %eax,%ebp
  80135f:	83 f5 1f             	xor    $0x1f,%ebp
  801362:	75 5c                	jne    8013c0 <__umoddi3+0xb0>
  801364:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801368:	39 3c 24             	cmp    %edi,(%esp)
  80136b:	0f 87 e7 00 00 00    	ja     801458 <__umoddi3+0x148>
  801371:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801375:	29 f1                	sub    %esi,%ecx
  801377:	19 c7                	sbb    %eax,%edi
  801379:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80137d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801381:	8b 44 24 08          	mov    0x8(%esp),%eax
  801385:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801389:	83 c4 14             	add    $0x14,%esp
  80138c:	5e                   	pop    %esi
  80138d:	5f                   	pop    %edi
  80138e:	5d                   	pop    %ebp
  80138f:	c3                   	ret    
  801390:	85 f6                	test   %esi,%esi
  801392:	89 f5                	mov    %esi,%ebp
  801394:	75 0b                	jne    8013a1 <__umoddi3+0x91>
  801396:	b8 01 00 00 00       	mov    $0x1,%eax
  80139b:	31 d2                	xor    %edx,%edx
  80139d:	f7 f6                	div    %esi
  80139f:	89 c5                	mov    %eax,%ebp
  8013a1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8013a5:	31 d2                	xor    %edx,%edx
  8013a7:	f7 f5                	div    %ebp
  8013a9:	89 c8                	mov    %ecx,%eax
  8013ab:	f7 f5                	div    %ebp
  8013ad:	eb 9c                	jmp    80134b <__umoddi3+0x3b>
  8013af:	90                   	nop
  8013b0:	89 c8                	mov    %ecx,%eax
  8013b2:	89 fa                	mov    %edi,%edx
  8013b4:	83 c4 14             	add    $0x14,%esp
  8013b7:	5e                   	pop    %esi
  8013b8:	5f                   	pop    %edi
  8013b9:	5d                   	pop    %ebp
  8013ba:	c3                   	ret    
  8013bb:	90                   	nop
  8013bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013c0:	8b 04 24             	mov    (%esp),%eax
  8013c3:	be 20 00 00 00       	mov    $0x20,%esi
  8013c8:	89 e9                	mov    %ebp,%ecx
  8013ca:	29 ee                	sub    %ebp,%esi
  8013cc:	d3 e2                	shl    %cl,%edx
  8013ce:	89 f1                	mov    %esi,%ecx
  8013d0:	d3 e8                	shr    %cl,%eax
  8013d2:	89 e9                	mov    %ebp,%ecx
  8013d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d8:	8b 04 24             	mov    (%esp),%eax
  8013db:	09 54 24 04          	or     %edx,0x4(%esp)
  8013df:	89 fa                	mov    %edi,%edx
  8013e1:	d3 e0                	shl    %cl,%eax
  8013e3:	89 f1                	mov    %esi,%ecx
  8013e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013e9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8013ed:	d3 ea                	shr    %cl,%edx
  8013ef:	89 e9                	mov    %ebp,%ecx
  8013f1:	d3 e7                	shl    %cl,%edi
  8013f3:	89 f1                	mov    %esi,%ecx
  8013f5:	d3 e8                	shr    %cl,%eax
  8013f7:	89 e9                	mov    %ebp,%ecx
  8013f9:	09 f8                	or     %edi,%eax
  8013fb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8013ff:	f7 74 24 04          	divl   0x4(%esp)
  801403:	d3 e7                	shl    %cl,%edi
  801405:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801409:	89 d7                	mov    %edx,%edi
  80140b:	f7 64 24 08          	mull   0x8(%esp)
  80140f:	39 d7                	cmp    %edx,%edi
  801411:	89 c1                	mov    %eax,%ecx
  801413:	89 14 24             	mov    %edx,(%esp)
  801416:	72 2c                	jb     801444 <__umoddi3+0x134>
  801418:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80141c:	72 22                	jb     801440 <__umoddi3+0x130>
  80141e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801422:	29 c8                	sub    %ecx,%eax
  801424:	19 d7                	sbb    %edx,%edi
  801426:	89 e9                	mov    %ebp,%ecx
  801428:	89 fa                	mov    %edi,%edx
  80142a:	d3 e8                	shr    %cl,%eax
  80142c:	89 f1                	mov    %esi,%ecx
  80142e:	d3 e2                	shl    %cl,%edx
  801430:	89 e9                	mov    %ebp,%ecx
  801432:	d3 ef                	shr    %cl,%edi
  801434:	09 d0                	or     %edx,%eax
  801436:	89 fa                	mov    %edi,%edx
  801438:	83 c4 14             	add    $0x14,%esp
  80143b:	5e                   	pop    %esi
  80143c:	5f                   	pop    %edi
  80143d:	5d                   	pop    %ebp
  80143e:	c3                   	ret    
  80143f:	90                   	nop
  801440:	39 d7                	cmp    %edx,%edi
  801442:	75 da                	jne    80141e <__umoddi3+0x10e>
  801444:	8b 14 24             	mov    (%esp),%edx
  801447:	89 c1                	mov    %eax,%ecx
  801449:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80144d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801451:	eb cb                	jmp    80141e <__umoddi3+0x10e>
  801453:	90                   	nop
  801454:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801458:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80145c:	0f 82 0f ff ff ff    	jb     801371 <__umoddi3+0x61>
  801462:	e9 1a ff ff ff       	jmp    801381 <__umoddi3+0x71>
