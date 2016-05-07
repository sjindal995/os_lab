
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
  800049:	e8 72 01 00 00       	call   8001c0 <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	c1 e0 02             	shl    $0x2,%eax
  800056:	89 c2                	mov    %eax,%edx
  800058:	c1 e2 05             	shl    $0x5,%edx
  80005b:	29 c2                	sub    %eax,%edx
  80005d:	89 d0                	mov    %edx,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	// if (argc > 0)
	// 	binaryname = argv[0];

	// call user main routine
	umain(argc, argv);
  800069:	8b 45 0c             	mov    0xc(%ebp),%eax
  80006c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800070:	8b 45 08             	mov    0x8(%ebp),%eax
  800073:	89 04 24             	mov    %eax,(%esp)
  800076:	e8 b8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007b:	e8 02 00 00 00       	call   800082 <exit>
}
  800080:	c9                   	leave  
  800081:	c3                   	ret    

00800082 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800082:	55                   	push   %ebp
  800083:	89 e5                	mov    %esp,%ebp
  800085:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800088:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80008f:	e8 e9 00 00 00       	call   80017d <sys_env_destroy>
}
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	57                   	push   %edi
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
  80009c:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009f:	8b 45 08             	mov    0x8(%ebp),%eax
  8000a2:	8b 55 10             	mov    0x10(%ebp),%edx
  8000a5:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8000a8:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8000ab:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  8000ae:	8b 75 20             	mov    0x20(%ebp),%esi
  8000b1:	cd 30                	int    $0x30
  8000b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000b6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8000ba:	74 30                	je     8000ec <syscall+0x56>
  8000bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c0:	7e 2a                	jle    8000ec <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000c5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8000cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000d0:	c7 44 24 08 6a 14 80 	movl   $0x80146a,0x8(%esp)
  8000d7:	00 
  8000d8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000df:	00 
  8000e0:	c7 04 24 87 14 80 00 	movl   $0x801487,(%esp)
  8000e7:	e8 b3 03 00 00       	call   80049f <_panic>

	return ret;
  8000ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8000ef:	83 c4 3c             	add    $0x3c,%esp
  8000f2:	5b                   	pop    %ebx
  8000f3:	5e                   	pop    %esi
  8000f4:	5f                   	pop    %edi
  8000f5:	5d                   	pop    %ebp
  8000f6:	c3                   	ret    

008000f7 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800100:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800107:	00 
  800108:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80010f:	00 
  800110:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800117:	00 
  800118:	8b 55 0c             	mov    0xc(%ebp),%edx
  80011b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80011f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800123:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80012a:	00 
  80012b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800132:	e8 5f ff ff ff       	call   800096 <syscall>
}
  800137:	c9                   	leave  
  800138:	c3                   	ret    

00800139 <sys_cgetc>:

int
sys_cgetc(void)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80013f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800146:	00 
  800147:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80014e:	00 
  80014f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800156:	00 
  800157:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80015e:	00 
  80015f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800166:	00 
  800167:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80016e:	00 
  80016f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800176:	e8 1b ff ff ff       	call   800096 <syscall>
}
  80017b:	c9                   	leave  
  80017c:	c3                   	ret    

0080017d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80017d:	55                   	push   %ebp
  80017e:	89 e5                	mov    %esp,%ebp
  800180:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800183:	8b 45 08             	mov    0x8(%ebp),%eax
  800186:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80018d:	00 
  80018e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800195:	00 
  800196:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80019d:	00 
  80019e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001a5:	00 
  8001a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001aa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001b1:	00 
  8001b2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8001b9:	e8 d8 fe ff ff       	call   800096 <syscall>
}
  8001be:	c9                   	leave  
  8001bf:	c3                   	ret    

008001c0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8001c6:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001cd:	00 
  8001ce:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001d5:	00 
  8001d6:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001dd:	00 
  8001de:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001e5:	00 
  8001e6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001ed:	00 
  8001ee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001f5:	00 
  8001f6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8001fd:	e8 94 fe ff ff       	call   800096 <syscall>
}
  800202:	c9                   	leave  
  800203:	c3                   	ret    

00800204 <sys_yield>:

void
sys_yield(void)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80020a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800211:	00 
  800212:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800219:	00 
  80021a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800221:	00 
  800222:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800229:	00 
  80022a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800231:	00 
  800232:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800239:	00 
  80023a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800241:	e8 50 fe ff ff       	call   800096 <syscall>
}
  800246:	c9                   	leave  
  800247:	c3                   	ret    

00800248 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80024e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800251:	8b 55 0c             	mov    0xc(%ebp),%edx
  800254:	8b 45 08             	mov    0x8(%ebp),%eax
  800257:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80025e:	00 
  80025f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800266:	00 
  800267:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80026b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80026f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800273:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80027a:	00 
  80027b:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800282:	e8 0f fe ff ff       	call   800096 <syscall>
}
  800287:	c9                   	leave  
  800288:	c3                   	ret    

00800289 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	56                   	push   %esi
  80028d:	53                   	push   %ebx
  80028e:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800291:	8b 75 18             	mov    0x18(%ebp),%esi
  800294:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800297:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80029a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80029d:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a0:	89 74 24 18          	mov    %esi,0x18(%esp)
  8002a4:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002a8:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002bb:	00 
  8002bc:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8002c3:	e8 ce fd ff ff       	call   800096 <syscall>
}
  8002c8:	83 c4 20             	add    $0x20,%esp
  8002cb:	5b                   	pop    %ebx
  8002cc:	5e                   	pop    %esi
  8002cd:	5d                   	pop    %ebp
  8002ce:	c3                   	ret    

008002cf <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
  8002d2:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8002d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002db:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8002e2:	00 
  8002e3:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8002ea:	00 
  8002eb:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8002f2:	00 
  8002f3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002fb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800302:	00 
  800303:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  80030a:	e8 87 fd ff ff       	call   800096 <syscall>
}
  80030f:	c9                   	leave  
  800310:	c3                   	ret    

00800311 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800317:	8b 55 0c             	mov    0xc(%ebp),%edx
  80031a:	8b 45 08             	mov    0x8(%ebp),%eax
  80031d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800324:	00 
  800325:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80032c:	00 
  80032d:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800334:	00 
  800335:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800339:	89 44 24 08          	mov    %eax,0x8(%esp)
  80033d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800344:	00 
  800345:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  80034c:	e8 45 fd ff ff       	call   800096 <syscall>
}
  800351:	c9                   	leave  
  800352:	c3                   	ret    

00800353 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800353:	55                   	push   %ebp
  800354:	89 e5                	mov    %esp,%ebp
  800356:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800359:	8b 55 0c             	mov    0xc(%ebp),%edx
  80035c:	8b 45 08             	mov    0x8(%ebp),%eax
  80035f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800366:	00 
  800367:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80036e:	00 
  80036f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800376:	00 
  800377:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80037b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800386:	00 
  800387:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  80038e:	e8 03 fd ff ff       	call   800096 <syscall>
}
  800393:	c9                   	leave  
  800394:	c3                   	ret    

00800395 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80039b:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80039e:	8b 55 10             	mov    0x10(%ebp),%edx
  8003a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a4:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003ab:	00 
  8003ac:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8003b0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003b7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003c6:	00 
  8003c7:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8003ce:	e8 c3 fc ff ff       	call   800096 <syscall>
}
  8003d3:	c9                   	leave  
  8003d4:	c3                   	ret    

008003d5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003d5:	55                   	push   %ebp
  8003d6:	89 e5                	mov    %esp,%ebp
  8003d8:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8003db:	8b 45 08             	mov    0x8(%ebp),%eax
  8003de:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003e5:	00 
  8003e6:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8003ed:	00 
  8003ee:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8003f5:	00 
  8003f6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003fd:	00 
  8003fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800402:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800409:	00 
  80040a:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  800411:	e8 80 fc ff ff       	call   800096 <syscall>
}
  800416:	c9                   	leave  
  800417:	c3                   	ret    

00800418 <sys_exec>:

void sys_exec(char* buf){
  800418:	55                   	push   %ebp
  800419:	89 e5                	mov    %esp,%ebp
  80041b:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  80041e:	8b 45 08             	mov    0x8(%ebp),%eax
  800421:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800428:	00 
  800429:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800430:	00 
  800431:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800438:	00 
  800439:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800440:	00 
  800441:	89 44 24 08          	mov    %eax,0x8(%esp)
  800445:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80044c:	00 
  80044d:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  800454:	e8 3d fc ff ff       	call   800096 <syscall>
}
  800459:	c9                   	leave  
  80045a:	c3                   	ret    

0080045b <sys_wait>:

void sys_wait(){
  80045b:	55                   	push   %ebp
  80045c:	89 e5                	mov    %esp,%ebp
  80045e:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_wait, 0, 0, 0, 0, 0, 0);
  800461:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800468:	00 
  800469:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800470:	00 
  800471:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800478:	00 
  800479:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800480:	00 
  800481:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800488:	00 
  800489:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800490:	00 
  800491:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
  800498:	e8 f9 fb ff ff       	call   800096 <syscall>
  80049d:	c9                   	leave  
  80049e:	c3                   	ret    

0080049f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80049f:	55                   	push   %ebp
  8004a0:	89 e5                	mov    %esp,%ebp
  8004a2:	53                   	push   %ebx
  8004a3:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8004a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8004a9:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004ac:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8004b2:	e8 09 fd ff ff       	call   8001c0 <sys_getenvid>
  8004b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ba:	89 54 24 10          	mov    %edx,0x10(%esp)
  8004be:	8b 55 08             	mov    0x8(%ebp),%edx
  8004c1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004c5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004cd:	c7 04 24 98 14 80 00 	movl   $0x801498,(%esp)
  8004d4:	e8 e1 00 00 00       	call   8005ba <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8004dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e3:	89 04 24             	mov    %eax,(%esp)
  8004e6:	e8 6b 00 00 00       	call   800556 <vcprintf>
	cprintf("\n");
  8004eb:	c7 04 24 bb 14 80 00 	movl   $0x8014bb,(%esp)
  8004f2:	e8 c3 00 00 00       	call   8005ba <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004f7:	cc                   	int3   
  8004f8:	eb fd                	jmp    8004f7 <_panic+0x58>

008004fa <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004fa:	55                   	push   %ebp
  8004fb:	89 e5                	mov    %esp,%ebp
  8004fd:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800500:	8b 45 0c             	mov    0xc(%ebp),%eax
  800503:	8b 00                	mov    (%eax),%eax
  800505:	8d 48 01             	lea    0x1(%eax),%ecx
  800508:	8b 55 0c             	mov    0xc(%ebp),%edx
  80050b:	89 0a                	mov    %ecx,(%edx)
  80050d:	8b 55 08             	mov    0x8(%ebp),%edx
  800510:	89 d1                	mov    %edx,%ecx
  800512:	8b 55 0c             	mov    0xc(%ebp),%edx
  800515:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800519:	8b 45 0c             	mov    0xc(%ebp),%eax
  80051c:	8b 00                	mov    (%eax),%eax
  80051e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800523:	75 20                	jne    800545 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800525:	8b 45 0c             	mov    0xc(%ebp),%eax
  800528:	8b 00                	mov    (%eax),%eax
  80052a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80052d:	83 c2 08             	add    $0x8,%edx
  800530:	89 44 24 04          	mov    %eax,0x4(%esp)
  800534:	89 14 24             	mov    %edx,(%esp)
  800537:	e8 bb fb ff ff       	call   8000f7 <sys_cputs>
		b->idx = 0;
  80053c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80053f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800545:	8b 45 0c             	mov    0xc(%ebp),%eax
  800548:	8b 40 04             	mov    0x4(%eax),%eax
  80054b:	8d 50 01             	lea    0x1(%eax),%edx
  80054e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800551:	89 50 04             	mov    %edx,0x4(%eax)
}
  800554:	c9                   	leave  
  800555:	c3                   	ret    

00800556 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800556:	55                   	push   %ebp
  800557:	89 e5                	mov    %esp,%ebp
  800559:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80055f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800566:	00 00 00 
	b.cnt = 0;
  800569:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800570:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800573:	8b 45 0c             	mov    0xc(%ebp),%eax
  800576:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80057a:	8b 45 08             	mov    0x8(%ebp),%eax
  80057d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800581:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800587:	89 44 24 04          	mov    %eax,0x4(%esp)
  80058b:	c7 04 24 fa 04 80 00 	movl   $0x8004fa,(%esp)
  800592:	e8 bd 01 00 00       	call   800754 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800597:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80059d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005a7:	83 c0 08             	add    $0x8,%eax
  8005aa:	89 04 24             	mov    %eax,(%esp)
  8005ad:	e8 45 fb ff ff       	call   8000f7 <sys_cputs>

	return b.cnt;
  8005b2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8005b8:	c9                   	leave  
  8005b9:	c3                   	ret    

008005ba <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005ba:	55                   	push   %ebp
  8005bb:	89 e5                	mov    %esp,%ebp
  8005bd:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005c0:	8d 45 0c             	lea    0xc(%ebp),%eax
  8005c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  8005c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d0:	89 04 24             	mov    %eax,(%esp)
  8005d3:	e8 7e ff ff ff       	call   800556 <vcprintf>
  8005d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  8005db:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8005de:	c9                   	leave  
  8005df:	c3                   	ret    

008005e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005e0:	55                   	push   %ebp
  8005e1:	89 e5                	mov    %esp,%ebp
  8005e3:	53                   	push   %ebx
  8005e4:	83 ec 34             	sub    $0x34,%esp
  8005e7:	8b 45 10             	mov    0x10(%ebp),%eax
  8005ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005f3:	8b 45 18             	mov    0x18(%ebp),%eax
  8005f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8005fb:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005fe:	77 72                	ja     800672 <printnum+0x92>
  800600:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800603:	72 05                	jb     80060a <printnum+0x2a>
  800605:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800608:	77 68                	ja     800672 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80060a:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80060d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800610:	8b 45 18             	mov    0x18(%ebp),%eax
  800613:	ba 00 00 00 00       	mov    $0x0,%edx
  800618:	89 44 24 08          	mov    %eax,0x8(%esp)
  80061c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800620:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800623:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800626:	89 04 24             	mov    %eax,(%esp)
  800629:	89 54 24 04          	mov    %edx,0x4(%esp)
  80062d:	e8 9e 0b 00 00       	call   8011d0 <__udivdi3>
  800632:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800635:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800639:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  80063d:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800640:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800644:	89 44 24 08          	mov    %eax,0x8(%esp)
  800648:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80064c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80064f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800653:	8b 45 08             	mov    0x8(%ebp),%eax
  800656:	89 04 24             	mov    %eax,(%esp)
  800659:	e8 82 ff ff ff       	call   8005e0 <printnum>
  80065e:	eb 1c                	jmp    80067c <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800660:	8b 45 0c             	mov    0xc(%ebp),%eax
  800663:	89 44 24 04          	mov    %eax,0x4(%esp)
  800667:	8b 45 20             	mov    0x20(%ebp),%eax
  80066a:	89 04 24             	mov    %eax,(%esp)
  80066d:	8b 45 08             	mov    0x8(%ebp),%eax
  800670:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800672:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800676:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  80067a:	7f e4                	jg     800660 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80067c:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80067f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800684:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800687:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80068a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80068e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800692:	89 04 24             	mov    %eax,(%esp)
  800695:	89 54 24 04          	mov    %edx,0x4(%esp)
  800699:	e8 62 0c 00 00       	call   801300 <__umoddi3>
  80069e:	05 88 15 80 00       	add    $0x801588,%eax
  8006a3:	0f b6 00             	movzbl (%eax),%eax
  8006a6:	0f be c0             	movsbl %al,%eax
  8006a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006b0:	89 04 24             	mov    %eax,(%esp)
  8006b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b6:	ff d0                	call   *%eax
}
  8006b8:	83 c4 34             	add    $0x34,%esp
  8006bb:	5b                   	pop    %ebx
  8006bc:	5d                   	pop    %ebp
  8006bd:	c3                   	ret    

008006be <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8006be:	55                   	push   %ebp
  8006bf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006c1:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8006c5:	7e 14                	jle    8006db <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  8006c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ca:	8b 00                	mov    (%eax),%eax
  8006cc:	8d 48 08             	lea    0x8(%eax),%ecx
  8006cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d2:	89 0a                	mov    %ecx,(%edx)
  8006d4:	8b 50 04             	mov    0x4(%eax),%edx
  8006d7:	8b 00                	mov    (%eax),%eax
  8006d9:	eb 30                	jmp    80070b <getuint+0x4d>
	else if (lflag)
  8006db:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006df:	74 16                	je     8006f7 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8006e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e4:	8b 00                	mov    (%eax),%eax
  8006e6:	8d 48 04             	lea    0x4(%eax),%ecx
  8006e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8006ec:	89 0a                	mov    %ecx,(%edx)
  8006ee:	8b 00                	mov    (%eax),%eax
  8006f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8006f5:	eb 14                	jmp    80070b <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8006f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fa:	8b 00                	mov    (%eax),%eax
  8006fc:	8d 48 04             	lea    0x4(%eax),%ecx
  8006ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800702:	89 0a                	mov    %ecx,(%edx)
  800704:	8b 00                	mov    (%eax),%eax
  800706:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80070b:	5d                   	pop    %ebp
  80070c:	c3                   	ret    

0080070d <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800710:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800714:	7e 14                	jle    80072a <getint+0x1d>
		return va_arg(*ap, long long);
  800716:	8b 45 08             	mov    0x8(%ebp),%eax
  800719:	8b 00                	mov    (%eax),%eax
  80071b:	8d 48 08             	lea    0x8(%eax),%ecx
  80071e:	8b 55 08             	mov    0x8(%ebp),%edx
  800721:	89 0a                	mov    %ecx,(%edx)
  800723:	8b 50 04             	mov    0x4(%eax),%edx
  800726:	8b 00                	mov    (%eax),%eax
  800728:	eb 28                	jmp    800752 <getint+0x45>
	else if (lflag)
  80072a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80072e:	74 12                	je     800742 <getint+0x35>
		return va_arg(*ap, long);
  800730:	8b 45 08             	mov    0x8(%ebp),%eax
  800733:	8b 00                	mov    (%eax),%eax
  800735:	8d 48 04             	lea    0x4(%eax),%ecx
  800738:	8b 55 08             	mov    0x8(%ebp),%edx
  80073b:	89 0a                	mov    %ecx,(%edx)
  80073d:	8b 00                	mov    (%eax),%eax
  80073f:	99                   	cltd   
  800740:	eb 10                	jmp    800752 <getint+0x45>
	else
		return va_arg(*ap, int);
  800742:	8b 45 08             	mov    0x8(%ebp),%eax
  800745:	8b 00                	mov    (%eax),%eax
  800747:	8d 48 04             	lea    0x4(%eax),%ecx
  80074a:	8b 55 08             	mov    0x8(%ebp),%edx
  80074d:	89 0a                	mov    %ecx,(%edx)
  80074f:	8b 00                	mov    (%eax),%eax
  800751:	99                   	cltd   
}
  800752:	5d                   	pop    %ebp
  800753:	c3                   	ret    

00800754 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	56                   	push   %esi
  800758:	53                   	push   %ebx
  800759:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80075c:	eb 18                	jmp    800776 <vprintfmt+0x22>
			if (ch == '\0')
  80075e:	85 db                	test   %ebx,%ebx
  800760:	75 05                	jne    800767 <vprintfmt+0x13>
				return;
  800762:	e9 cc 03 00 00       	jmp    800b33 <vprintfmt+0x3df>
			putch(ch, putdat);
  800767:	8b 45 0c             	mov    0xc(%ebp),%eax
  80076a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076e:	89 1c 24             	mov    %ebx,(%esp)
  800771:	8b 45 08             	mov    0x8(%ebp),%eax
  800774:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800776:	8b 45 10             	mov    0x10(%ebp),%eax
  800779:	8d 50 01             	lea    0x1(%eax),%edx
  80077c:	89 55 10             	mov    %edx,0x10(%ebp)
  80077f:	0f b6 00             	movzbl (%eax),%eax
  800782:	0f b6 d8             	movzbl %al,%ebx
  800785:	83 fb 25             	cmp    $0x25,%ebx
  800788:	75 d4                	jne    80075e <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  80078a:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80078e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800795:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80079c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8007a3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ad:	8d 50 01             	lea    0x1(%eax),%edx
  8007b0:	89 55 10             	mov    %edx,0x10(%ebp)
  8007b3:	0f b6 00             	movzbl (%eax),%eax
  8007b6:	0f b6 d8             	movzbl %al,%ebx
  8007b9:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8007bc:	83 f8 55             	cmp    $0x55,%eax
  8007bf:	0f 87 3d 03 00 00    	ja     800b02 <vprintfmt+0x3ae>
  8007c5:	8b 04 85 ac 15 80 00 	mov    0x8015ac(,%eax,4),%eax
  8007cc:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8007ce:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8007d2:	eb d6                	jmp    8007aa <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8007d4:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8007d8:	eb d0                	jmp    8007aa <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007da:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8007e1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007e4:	89 d0                	mov    %edx,%eax
  8007e6:	c1 e0 02             	shl    $0x2,%eax
  8007e9:	01 d0                	add    %edx,%eax
  8007eb:	01 c0                	add    %eax,%eax
  8007ed:	01 d8                	add    %ebx,%eax
  8007ef:	83 e8 30             	sub    $0x30,%eax
  8007f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8007f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f8:	0f b6 00             	movzbl (%eax),%eax
  8007fb:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8007fe:	83 fb 2f             	cmp    $0x2f,%ebx
  800801:	7e 0b                	jle    80080e <vprintfmt+0xba>
  800803:	83 fb 39             	cmp    $0x39,%ebx
  800806:	7f 06                	jg     80080e <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800808:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80080c:	eb d3                	jmp    8007e1 <vprintfmt+0x8d>
			goto process_precision;
  80080e:	eb 33                	jmp    800843 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800810:	8b 45 14             	mov    0x14(%ebp),%eax
  800813:	8d 50 04             	lea    0x4(%eax),%edx
  800816:	89 55 14             	mov    %edx,0x14(%ebp)
  800819:	8b 00                	mov    (%eax),%eax
  80081b:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80081e:	eb 23                	jmp    800843 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800820:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800824:	79 0c                	jns    800832 <vprintfmt+0xde>
				width = 0;
  800826:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  80082d:	e9 78 ff ff ff       	jmp    8007aa <vprintfmt+0x56>
  800832:	e9 73 ff ff ff       	jmp    8007aa <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800837:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80083e:	e9 67 ff ff ff       	jmp    8007aa <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800843:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800847:	79 12                	jns    80085b <vprintfmt+0x107>
				width = precision, precision = -1;
  800849:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80084c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80084f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800856:	e9 4f ff ff ff       	jmp    8007aa <vprintfmt+0x56>
  80085b:	e9 4a ff ff ff       	jmp    8007aa <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800860:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800864:	e9 41 ff ff ff       	jmp    8007aa <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800869:	8b 45 14             	mov    0x14(%ebp),%eax
  80086c:	8d 50 04             	lea    0x4(%eax),%edx
  80086f:	89 55 14             	mov    %edx,0x14(%ebp)
  800872:	8b 00                	mov    (%eax),%eax
  800874:	8b 55 0c             	mov    0xc(%ebp),%edx
  800877:	89 54 24 04          	mov    %edx,0x4(%esp)
  80087b:	89 04 24             	mov    %eax,(%esp)
  80087e:	8b 45 08             	mov    0x8(%ebp),%eax
  800881:	ff d0                	call   *%eax
			break;
  800883:	e9 a5 02 00 00       	jmp    800b2d <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800888:	8b 45 14             	mov    0x14(%ebp),%eax
  80088b:	8d 50 04             	lea    0x4(%eax),%edx
  80088e:	89 55 14             	mov    %edx,0x14(%ebp)
  800891:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800893:	85 db                	test   %ebx,%ebx
  800895:	79 02                	jns    800899 <vprintfmt+0x145>
				err = -err;
  800897:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800899:	83 fb 09             	cmp    $0x9,%ebx
  80089c:	7f 0b                	jg     8008a9 <vprintfmt+0x155>
  80089e:	8b 34 9d 60 15 80 00 	mov    0x801560(,%ebx,4),%esi
  8008a5:	85 f6                	test   %esi,%esi
  8008a7:	75 23                	jne    8008cc <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8008a9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8008ad:	c7 44 24 08 99 15 80 	movl   $0x801599,0x8(%esp)
  8008b4:	00 
  8008b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bf:	89 04 24             	mov    %eax,(%esp)
  8008c2:	e8 73 02 00 00       	call   800b3a <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8008c7:	e9 61 02 00 00       	jmp    800b2d <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8008cc:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008d0:	c7 44 24 08 a2 15 80 	movl   $0x8015a2,0x8(%esp)
  8008d7:	00 
  8008d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	89 04 24             	mov    %eax,(%esp)
  8008e5:	e8 50 02 00 00       	call   800b3a <printfmt>
			break;
  8008ea:	e9 3e 02 00 00       	jmp    800b2d <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f2:	8d 50 04             	lea    0x4(%eax),%edx
  8008f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8008f8:	8b 30                	mov    (%eax),%esi
  8008fa:	85 f6                	test   %esi,%esi
  8008fc:	75 05                	jne    800903 <vprintfmt+0x1af>
				p = "(null)";
  8008fe:	be a5 15 80 00       	mov    $0x8015a5,%esi
			if (width > 0 && padc != '-')
  800903:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800907:	7e 37                	jle    800940 <vprintfmt+0x1ec>
  800909:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  80090d:	74 31                	je     800940 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  80090f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800912:	89 44 24 04          	mov    %eax,0x4(%esp)
  800916:	89 34 24             	mov    %esi,(%esp)
  800919:	e8 39 03 00 00       	call   800c57 <strnlen>
  80091e:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800921:	eb 17                	jmp    80093a <vprintfmt+0x1e6>
					putch(padc, putdat);
  800923:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800927:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80092e:	89 04 24             	mov    %eax,(%esp)
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800936:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80093a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80093e:	7f e3                	jg     800923 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800940:	eb 38                	jmp    80097a <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800942:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800946:	74 1f                	je     800967 <vprintfmt+0x213>
  800948:	83 fb 1f             	cmp    $0x1f,%ebx
  80094b:	7e 05                	jle    800952 <vprintfmt+0x1fe>
  80094d:	83 fb 7e             	cmp    $0x7e,%ebx
  800950:	7e 15                	jle    800967 <vprintfmt+0x213>
					putch('?', putdat);
  800952:	8b 45 0c             	mov    0xc(%ebp),%eax
  800955:	89 44 24 04          	mov    %eax,0x4(%esp)
  800959:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	ff d0                	call   *%eax
  800965:	eb 0f                	jmp    800976 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800967:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096e:	89 1c 24             	mov    %ebx,(%esp)
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800976:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80097a:	89 f0                	mov    %esi,%eax
  80097c:	8d 70 01             	lea    0x1(%eax),%esi
  80097f:	0f b6 00             	movzbl (%eax),%eax
  800982:	0f be d8             	movsbl %al,%ebx
  800985:	85 db                	test   %ebx,%ebx
  800987:	74 10                	je     800999 <vprintfmt+0x245>
  800989:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80098d:	78 b3                	js     800942 <vprintfmt+0x1ee>
  80098f:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800993:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800997:	79 a9                	jns    800942 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800999:	eb 17                	jmp    8009b2 <vprintfmt+0x25e>
				putch(' ', putdat);
  80099b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ac:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009ae:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8009b2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009b6:	7f e3                	jg     80099b <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8009b8:	e9 70 01 00 00       	jmp    800b2d <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c4:	8d 45 14             	lea    0x14(%ebp),%eax
  8009c7:	89 04 24             	mov    %eax,(%esp)
  8009ca:	e8 3e fd ff ff       	call   80070d <getint>
  8009cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009d2:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8009d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009db:	85 d2                	test   %edx,%edx
  8009dd:	79 26                	jns    800a05 <vprintfmt+0x2b1>
				putch('-', putdat);
  8009df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	ff d0                	call   *%eax
				num = -(long long) num;
  8009f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009f8:	f7 d8                	neg    %eax
  8009fa:	83 d2 00             	adc    $0x0,%edx
  8009fd:	f7 da                	neg    %edx
  8009ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a02:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800a05:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a0c:	e9 a8 00 00 00       	jmp    800ab9 <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a11:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a14:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a18:	8d 45 14             	lea    0x14(%ebp),%eax
  800a1b:	89 04 24             	mov    %eax,(%esp)
  800a1e:	e8 9b fc ff ff       	call   8006be <getuint>
  800a23:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a26:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800a29:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a30:	e9 84 00 00 00       	jmp    800ab9 <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a35:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a38:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a3c:	8d 45 14             	lea    0x14(%ebp),%eax
  800a3f:	89 04 24             	mov    %eax,(%esp)
  800a42:	e8 77 fc ff ff       	call   8006be <getuint>
  800a47:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a4a:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800a4d:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800a54:	eb 63                	jmp    800ab9 <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a56:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a59:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a5d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a64:	8b 45 08             	mov    0x8(%ebp),%eax
  800a67:	ff d0                	call   *%eax
			putch('x', putdat);
  800a69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a70:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a77:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7a:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a7c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a7f:	8d 50 04             	lea    0x4(%eax),%edx
  800a82:	89 55 14             	mov    %edx,0x14(%ebp)
  800a85:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a87:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a8a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a91:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a98:	eb 1f                	jmp    800ab9 <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a9a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa1:	8d 45 14             	lea    0x14(%ebp),%eax
  800aa4:	89 04 24             	mov    %eax,(%esp)
  800aa7:	e8 12 fc ff ff       	call   8006be <getuint>
  800aac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800aaf:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800ab2:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ab9:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800abd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ac0:	89 54 24 18          	mov    %edx,0x18(%esp)
  800ac4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ac7:	89 54 24 14          	mov    %edx,0x14(%esp)
  800acb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800acf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ad2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ad5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ad9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800add:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae7:	89 04 24             	mov    %eax,(%esp)
  800aea:	e8 f1 fa ff ff       	call   8005e0 <printnum>
			break;
  800aef:	eb 3c                	jmp    800b2d <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800af1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af8:	89 1c 24             	mov    %ebx,(%esp)
  800afb:	8b 45 08             	mov    0x8(%ebp),%eax
  800afe:	ff d0                	call   *%eax
			break;
  800b00:	eb 2b                	jmp    800b2d <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b05:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b09:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b10:	8b 45 08             	mov    0x8(%ebp),%eax
  800b13:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b15:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b19:	eb 04                	jmp    800b1f <vprintfmt+0x3cb>
  800b1b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b1f:	8b 45 10             	mov    0x10(%ebp),%eax
  800b22:	83 e8 01             	sub    $0x1,%eax
  800b25:	0f b6 00             	movzbl (%eax),%eax
  800b28:	3c 25                	cmp    $0x25,%al
  800b2a:	75 ef                	jne    800b1b <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800b2c:	90                   	nop
		}
	}
  800b2d:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b2e:	e9 43 fc ff ff       	jmp    800776 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800b33:	83 c4 40             	add    $0x40,%esp
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b40:	8d 45 14             	lea    0x14(%ebp),%eax
  800b43:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b4d:	8b 45 10             	mov    0x10(%ebp),%eax
  800b50:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b57:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5e:	89 04 24             	mov    %eax,(%esp)
  800b61:	e8 ee fb ff ff       	call   800754 <vprintfmt>
	va_end(ap);
}
  800b66:	c9                   	leave  
  800b67:	c3                   	ret    

00800b68 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800b6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6e:	8b 40 08             	mov    0x8(%eax),%eax
  800b71:	8d 50 01             	lea    0x1(%eax),%edx
  800b74:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b77:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7d:	8b 10                	mov    (%eax),%edx
  800b7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b82:	8b 40 04             	mov    0x4(%eax),%eax
  800b85:	39 c2                	cmp    %eax,%edx
  800b87:	73 12                	jae    800b9b <sprintputch+0x33>
		*b->buf++ = ch;
  800b89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b8c:	8b 00                	mov    (%eax),%eax
  800b8e:	8d 48 01             	lea    0x1(%eax),%ecx
  800b91:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b94:	89 0a                	mov    %ecx,(%edx)
  800b96:	8b 55 08             	mov    0x8(%ebp),%edx
  800b99:	88 10                	mov    %dl,(%eax)
}
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ba3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ba9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bac:	8d 50 ff             	lea    -0x1(%eax),%edx
  800baf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb2:	01 d0                	add    %edx,%eax
  800bb4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800bb7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bbe:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800bc2:	74 06                	je     800bca <vsnprintf+0x2d>
  800bc4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc8:	7f 07                	jg     800bd1 <vsnprintf+0x34>
		return -E_INVAL;
  800bca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bcf:	eb 2a                	jmp    800bfb <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bd1:	8b 45 14             	mov    0x14(%ebp),%eax
  800bd4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bd8:	8b 45 10             	mov    0x10(%ebp),%eax
  800bdb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bdf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800be2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be6:	c7 04 24 68 0b 80 00 	movl   $0x800b68,(%esp)
  800bed:	e8 62 fb ff ff       	call   800754 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bf2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bf5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bfb:	c9                   	leave  
  800bfc:	c3                   	ret    

00800bfd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c03:	8d 45 14             	lea    0x14(%ebp),%eax
  800c06:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800c09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c0c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c10:	8b 45 10             	mov    0x10(%ebp),%eax
  800c13:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c21:	89 04 24             	mov    %eax,(%esp)
  800c24:	e8 74 ff ff ff       	call   800b9d <vsnprintf>
  800c29:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c2f:	c9                   	leave  
  800c30:	c3                   	ret    

00800c31 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800c37:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c3e:	eb 08                	jmp    800c48 <strlen+0x17>
		n++;
  800c40:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c44:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c48:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4b:	0f b6 00             	movzbl (%eax),%eax
  800c4e:	84 c0                	test   %al,%al
  800c50:	75 ee                	jne    800c40 <strlen+0xf>
		n++;
	return n;
  800c52:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c55:	c9                   	leave  
  800c56:	c3                   	ret    

00800c57 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c5d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c64:	eb 0c                	jmp    800c72 <strnlen+0x1b>
		n++;
  800c66:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c6a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c6e:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800c72:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c76:	74 0a                	je     800c82 <strnlen+0x2b>
  800c78:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7b:	0f b6 00             	movzbl (%eax),%eax
  800c7e:	84 c0                	test   %al,%al
  800c80:	75 e4                	jne    800c66 <strnlen+0xf>
		n++;
	return n;
  800c82:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c85:	c9                   	leave  
  800c86:	c3                   	ret    

00800c87 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c90:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c93:	90                   	nop
  800c94:	8b 45 08             	mov    0x8(%ebp),%eax
  800c97:	8d 50 01             	lea    0x1(%eax),%edx
  800c9a:	89 55 08             	mov    %edx,0x8(%ebp)
  800c9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ca0:	8d 4a 01             	lea    0x1(%edx),%ecx
  800ca3:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800ca6:	0f b6 12             	movzbl (%edx),%edx
  800ca9:	88 10                	mov    %dl,(%eax)
  800cab:	0f b6 00             	movzbl (%eax),%eax
  800cae:	84 c0                	test   %al,%al
  800cb0:	75 e2                	jne    800c94 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800cb2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800cb5:	c9                   	leave  
  800cb6:	c3                   	ret    

00800cb7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800cbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc0:	89 04 24             	mov    %eax,(%esp)
  800cc3:	e8 69 ff ff ff       	call   800c31 <strlen>
  800cc8:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800ccb:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800cce:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd1:	01 c2                	add    %eax,%edx
  800cd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cda:	89 14 24             	mov    %edx,(%esp)
  800cdd:	e8 a5 ff ff ff       	call   800c87 <strcpy>
	return dst;
  800ce2:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ce5:	c9                   	leave  
  800ce6:	c3                   	ret    

00800ce7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800ced:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf0:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800cf3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800cfa:	eb 23                	jmp    800d1f <strncpy+0x38>
		*dst++ = *src;
  800cfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cff:	8d 50 01             	lea    0x1(%eax),%edx
  800d02:	89 55 08             	mov    %edx,0x8(%ebp)
  800d05:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d08:	0f b6 12             	movzbl (%edx),%edx
  800d0b:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800d0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d10:	0f b6 00             	movzbl (%eax),%eax
  800d13:	84 c0                	test   %al,%al
  800d15:	74 04                	je     800d1b <strncpy+0x34>
			src++;
  800d17:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d1b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d1f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d22:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d25:	72 d5                	jb     800cfc <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800d27:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d2a:	c9                   	leave  
  800d2b:	c3                   	ret    

00800d2c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800d32:	8b 45 08             	mov    0x8(%ebp),%eax
  800d35:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800d38:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d3c:	74 33                	je     800d71 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d3e:	eb 17                	jmp    800d57 <strlcpy+0x2b>
			*dst++ = *src++;
  800d40:	8b 45 08             	mov    0x8(%ebp),%eax
  800d43:	8d 50 01             	lea    0x1(%eax),%edx
  800d46:	89 55 08             	mov    %edx,0x8(%ebp)
  800d49:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d4c:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d4f:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d52:	0f b6 12             	movzbl (%edx),%edx
  800d55:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d57:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d5b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d5f:	74 0a                	je     800d6b <strlcpy+0x3f>
  800d61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d64:	0f b6 00             	movzbl (%eax),%eax
  800d67:	84 c0                	test   %al,%al
  800d69:	75 d5                	jne    800d40 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d71:	8b 55 08             	mov    0x8(%ebp),%edx
  800d74:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d77:	29 c2                	sub    %eax,%edx
  800d79:	89 d0                	mov    %edx,%eax
}
  800d7b:	c9                   	leave  
  800d7c:	c3                   	ret    

00800d7d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d80:	eb 08                	jmp    800d8a <strcmp+0xd>
		p++, q++;
  800d82:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d86:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8d:	0f b6 00             	movzbl (%eax),%eax
  800d90:	84 c0                	test   %al,%al
  800d92:	74 10                	je     800da4 <strcmp+0x27>
  800d94:	8b 45 08             	mov    0x8(%ebp),%eax
  800d97:	0f b6 10             	movzbl (%eax),%edx
  800d9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d9d:	0f b6 00             	movzbl (%eax),%eax
  800da0:	38 c2                	cmp    %al,%dl
  800da2:	74 de                	je     800d82 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800da4:	8b 45 08             	mov    0x8(%ebp),%eax
  800da7:	0f b6 00             	movzbl (%eax),%eax
  800daa:	0f b6 d0             	movzbl %al,%edx
  800dad:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db0:	0f b6 00             	movzbl (%eax),%eax
  800db3:	0f b6 c0             	movzbl %al,%eax
  800db6:	29 c2                	sub    %eax,%edx
  800db8:	89 d0                	mov    %edx,%eax
}
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    

00800dbc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800dbf:	eb 0c                	jmp    800dcd <strncmp+0x11>
		n--, p++, q++;
  800dc1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800dc5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dc9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dcd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dd1:	74 1a                	je     800ded <strncmp+0x31>
  800dd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd6:	0f b6 00             	movzbl (%eax),%eax
  800dd9:	84 c0                	test   %al,%al
  800ddb:	74 10                	je     800ded <strncmp+0x31>
  800ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  800de0:	0f b6 10             	movzbl (%eax),%edx
  800de3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de6:	0f b6 00             	movzbl (%eax),%eax
  800de9:	38 c2                	cmp    %al,%dl
  800deb:	74 d4                	je     800dc1 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800ded:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800df1:	75 07                	jne    800dfa <strncmp+0x3e>
		return 0;
  800df3:	b8 00 00 00 00       	mov    $0x0,%eax
  800df8:	eb 16                	jmp    800e10 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfd:	0f b6 00             	movzbl (%eax),%eax
  800e00:	0f b6 d0             	movzbl %al,%edx
  800e03:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e06:	0f b6 00             	movzbl (%eax),%eax
  800e09:	0f b6 c0             	movzbl %al,%eax
  800e0c:	29 c2                	sub    %eax,%edx
  800e0e:	89 d0                	mov    %edx,%eax
}
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    

00800e12 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	83 ec 04             	sub    $0x4,%esp
  800e18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e1b:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e1e:	eb 14                	jmp    800e34 <strchr+0x22>
		if (*s == c)
  800e20:	8b 45 08             	mov    0x8(%ebp),%eax
  800e23:	0f b6 00             	movzbl (%eax),%eax
  800e26:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e29:	75 05                	jne    800e30 <strchr+0x1e>
			return (char *) s;
  800e2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2e:	eb 13                	jmp    800e43 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e30:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e34:	8b 45 08             	mov    0x8(%ebp),%eax
  800e37:	0f b6 00             	movzbl (%eax),%eax
  800e3a:	84 c0                	test   %al,%al
  800e3c:	75 e2                	jne    800e20 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e43:	c9                   	leave  
  800e44:	c3                   	ret    

00800e45 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
  800e48:	83 ec 04             	sub    $0x4,%esp
  800e4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e4e:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e51:	eb 11                	jmp    800e64 <strfind+0x1f>
		if (*s == c)
  800e53:	8b 45 08             	mov    0x8(%ebp),%eax
  800e56:	0f b6 00             	movzbl (%eax),%eax
  800e59:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e5c:	75 02                	jne    800e60 <strfind+0x1b>
			break;
  800e5e:	eb 0e                	jmp    800e6e <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e60:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e64:	8b 45 08             	mov    0x8(%ebp),%eax
  800e67:	0f b6 00             	movzbl (%eax),%eax
  800e6a:	84 c0                	test   %al,%al
  800e6c:	75 e5                	jne    800e53 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800e6e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e71:	c9                   	leave  
  800e72:	c3                   	ret    

00800e73 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e73:	55                   	push   %ebp
  800e74:	89 e5                	mov    %esp,%ebp
  800e76:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e77:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e7b:	75 05                	jne    800e82 <memset+0xf>
		return v;
  800e7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e80:	eb 5c                	jmp    800ede <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e82:	8b 45 08             	mov    0x8(%ebp),%eax
  800e85:	83 e0 03             	and    $0x3,%eax
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	75 41                	jne    800ecd <memset+0x5a>
  800e8c:	8b 45 10             	mov    0x10(%ebp),%eax
  800e8f:	83 e0 03             	and    $0x3,%eax
  800e92:	85 c0                	test   %eax,%eax
  800e94:	75 37                	jne    800ecd <memset+0x5a>
		c &= 0xFF;
  800e96:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea0:	c1 e0 18             	shl    $0x18,%eax
  800ea3:	89 c2                	mov    %eax,%edx
  800ea5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea8:	c1 e0 10             	shl    $0x10,%eax
  800eab:	09 c2                	or     %eax,%edx
  800ead:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eb0:	c1 e0 08             	shl    $0x8,%eax
  800eb3:	09 d0                	or     %edx,%eax
  800eb5:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800eb8:	8b 45 10             	mov    0x10(%ebp),%eax
  800ebb:	c1 e8 02             	shr    $0x2,%eax
  800ebe:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ec0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec6:	89 d7                	mov    %edx,%edi
  800ec8:	fc                   	cld    
  800ec9:	f3 ab                	rep stos %eax,%es:(%edi)
  800ecb:	eb 0e                	jmp    800edb <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ecd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ed6:	89 d7                	mov    %edx,%edi
  800ed8:	fc                   	cld    
  800ed9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800edb:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ede:	5f                   	pop    %edi
  800edf:	5d                   	pop    %ebp
  800ee0:	c3                   	ret    

00800ee1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	57                   	push   %edi
  800ee5:	56                   	push   %esi
  800ee6:	53                   	push   %ebx
  800ee7:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800eea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eed:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800ef0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef3:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800ef6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ef9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800efc:	73 6d                	jae    800f6b <memmove+0x8a>
  800efe:	8b 45 10             	mov    0x10(%ebp),%eax
  800f01:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f04:	01 d0                	add    %edx,%eax
  800f06:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f09:	76 60                	jbe    800f6b <memmove+0x8a>
		s += n;
  800f0b:	8b 45 10             	mov    0x10(%ebp),%eax
  800f0e:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800f11:	8b 45 10             	mov    0x10(%ebp),%eax
  800f14:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f17:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f1a:	83 e0 03             	and    $0x3,%eax
  800f1d:	85 c0                	test   %eax,%eax
  800f1f:	75 2f                	jne    800f50 <memmove+0x6f>
  800f21:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f24:	83 e0 03             	and    $0x3,%eax
  800f27:	85 c0                	test   %eax,%eax
  800f29:	75 25                	jne    800f50 <memmove+0x6f>
  800f2b:	8b 45 10             	mov    0x10(%ebp),%eax
  800f2e:	83 e0 03             	and    $0x3,%eax
  800f31:	85 c0                	test   %eax,%eax
  800f33:	75 1b                	jne    800f50 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f35:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f38:	83 e8 04             	sub    $0x4,%eax
  800f3b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f3e:	83 ea 04             	sub    $0x4,%edx
  800f41:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f44:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f47:	89 c7                	mov    %eax,%edi
  800f49:	89 d6                	mov    %edx,%esi
  800f4b:	fd                   	std    
  800f4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f4e:	eb 18                	jmp    800f68 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f50:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f53:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f56:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f59:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f5c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f5f:	89 d7                	mov    %edx,%edi
  800f61:	89 de                	mov    %ebx,%esi
  800f63:	89 c1                	mov    %eax,%ecx
  800f65:	fd                   	std    
  800f66:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f68:	fc                   	cld    
  800f69:	eb 45                	jmp    800fb0 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f6e:	83 e0 03             	and    $0x3,%eax
  800f71:	85 c0                	test   %eax,%eax
  800f73:	75 2b                	jne    800fa0 <memmove+0xbf>
  800f75:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f78:	83 e0 03             	and    $0x3,%eax
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	75 21                	jne    800fa0 <memmove+0xbf>
  800f7f:	8b 45 10             	mov    0x10(%ebp),%eax
  800f82:	83 e0 03             	and    $0x3,%eax
  800f85:	85 c0                	test   %eax,%eax
  800f87:	75 17                	jne    800fa0 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f89:	8b 45 10             	mov    0x10(%ebp),%eax
  800f8c:	c1 e8 02             	shr    $0x2,%eax
  800f8f:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f91:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f94:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f97:	89 c7                	mov    %eax,%edi
  800f99:	89 d6                	mov    %edx,%esi
  800f9b:	fc                   	cld    
  800f9c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f9e:	eb 10                	jmp    800fb0 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fa0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fa3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fa6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fa9:	89 c7                	mov    %eax,%edi
  800fab:	89 d6                	mov    %edx,%esi
  800fad:	fc                   	cld    
  800fae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800fb0:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800fb3:	83 c4 10             	add    $0x10,%esp
  800fb6:	5b                   	pop    %ebx
  800fb7:	5e                   	pop    %esi
  800fb8:	5f                   	pop    %edi
  800fb9:	5d                   	pop    %ebp
  800fba:	c3                   	ret    

00800fbb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800fbb:	55                   	push   %ebp
  800fbc:	89 e5                	mov    %esp,%ebp
  800fbe:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800fc1:	8b 45 10             	mov    0x10(%ebp),%eax
  800fc4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fcb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd2:	89 04 24             	mov    %eax,(%esp)
  800fd5:	e8 07 ff ff ff       	call   800ee1 <memmove>
}
  800fda:	c9                   	leave  
  800fdb:	c3                   	ret    

00800fdc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800fe2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe5:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800fe8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800feb:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800fee:	eb 30                	jmp    801020 <memcmp+0x44>
		if (*s1 != *s2)
  800ff0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ff3:	0f b6 10             	movzbl (%eax),%edx
  800ff6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ff9:	0f b6 00             	movzbl (%eax),%eax
  800ffc:	38 c2                	cmp    %al,%dl
  800ffe:	74 18                	je     801018 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  801000:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801003:	0f b6 00             	movzbl (%eax),%eax
  801006:	0f b6 d0             	movzbl %al,%edx
  801009:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80100c:	0f b6 00             	movzbl (%eax),%eax
  80100f:	0f b6 c0             	movzbl %al,%eax
  801012:	29 c2                	sub    %eax,%edx
  801014:	89 d0                	mov    %edx,%eax
  801016:	eb 1a                	jmp    801032 <memcmp+0x56>
		s1++, s2++;
  801018:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  80101c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801020:	8b 45 10             	mov    0x10(%ebp),%eax
  801023:	8d 50 ff             	lea    -0x1(%eax),%edx
  801026:	89 55 10             	mov    %edx,0x10(%ebp)
  801029:	85 c0                	test   %eax,%eax
  80102b:	75 c3                	jne    800ff0 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80102d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801032:	c9                   	leave  
  801033:	c3                   	ret    

00801034 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  80103a:	8b 45 10             	mov    0x10(%ebp),%eax
  80103d:	8b 55 08             	mov    0x8(%ebp),%edx
  801040:	01 d0                	add    %edx,%eax
  801042:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801045:	eb 13                	jmp    80105a <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801047:	8b 45 08             	mov    0x8(%ebp),%eax
  80104a:	0f b6 10             	movzbl (%eax),%edx
  80104d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801050:	38 c2                	cmp    %al,%dl
  801052:	75 02                	jne    801056 <memfind+0x22>
			break;
  801054:	eb 0c                	jmp    801062 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801056:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80105a:	8b 45 08             	mov    0x8(%ebp),%eax
  80105d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  801060:	72 e5                	jb     801047 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  801062:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801065:	c9                   	leave  
  801066:	c3                   	ret    

00801067 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801067:	55                   	push   %ebp
  801068:	89 e5                	mov    %esp,%ebp
  80106a:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  80106d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  801074:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80107b:	eb 04                	jmp    801081 <strtol+0x1a>
		s++;
  80107d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801081:	8b 45 08             	mov    0x8(%ebp),%eax
  801084:	0f b6 00             	movzbl (%eax),%eax
  801087:	3c 20                	cmp    $0x20,%al
  801089:	74 f2                	je     80107d <strtol+0x16>
  80108b:	8b 45 08             	mov    0x8(%ebp),%eax
  80108e:	0f b6 00             	movzbl (%eax),%eax
  801091:	3c 09                	cmp    $0x9,%al
  801093:	74 e8                	je     80107d <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  801095:	8b 45 08             	mov    0x8(%ebp),%eax
  801098:	0f b6 00             	movzbl (%eax),%eax
  80109b:	3c 2b                	cmp    $0x2b,%al
  80109d:	75 06                	jne    8010a5 <strtol+0x3e>
		s++;
  80109f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010a3:	eb 15                	jmp    8010ba <strtol+0x53>
	else if (*s == '-')
  8010a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a8:	0f b6 00             	movzbl (%eax),%eax
  8010ab:	3c 2d                	cmp    $0x2d,%al
  8010ad:	75 0b                	jne    8010ba <strtol+0x53>
		s++, neg = 1;
  8010af:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010b3:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010ba:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010be:	74 06                	je     8010c6 <strtol+0x5f>
  8010c0:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8010c4:	75 24                	jne    8010ea <strtol+0x83>
  8010c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c9:	0f b6 00             	movzbl (%eax),%eax
  8010cc:	3c 30                	cmp    $0x30,%al
  8010ce:	75 1a                	jne    8010ea <strtol+0x83>
  8010d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d3:	83 c0 01             	add    $0x1,%eax
  8010d6:	0f b6 00             	movzbl (%eax),%eax
  8010d9:	3c 78                	cmp    $0x78,%al
  8010db:	75 0d                	jne    8010ea <strtol+0x83>
		s += 2, base = 16;
  8010dd:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8010e1:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8010e8:	eb 2a                	jmp    801114 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  8010ea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010ee:	75 17                	jne    801107 <strtol+0xa0>
  8010f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f3:	0f b6 00             	movzbl (%eax),%eax
  8010f6:	3c 30                	cmp    $0x30,%al
  8010f8:	75 0d                	jne    801107 <strtol+0xa0>
		s++, base = 8;
  8010fa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010fe:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801105:	eb 0d                	jmp    801114 <strtol+0xad>
	else if (base == 0)
  801107:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80110b:	75 07                	jne    801114 <strtol+0xad>
		base = 10;
  80110d:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801114:	8b 45 08             	mov    0x8(%ebp),%eax
  801117:	0f b6 00             	movzbl (%eax),%eax
  80111a:	3c 2f                	cmp    $0x2f,%al
  80111c:	7e 1b                	jle    801139 <strtol+0xd2>
  80111e:	8b 45 08             	mov    0x8(%ebp),%eax
  801121:	0f b6 00             	movzbl (%eax),%eax
  801124:	3c 39                	cmp    $0x39,%al
  801126:	7f 11                	jg     801139 <strtol+0xd2>
			dig = *s - '0';
  801128:	8b 45 08             	mov    0x8(%ebp),%eax
  80112b:	0f b6 00             	movzbl (%eax),%eax
  80112e:	0f be c0             	movsbl %al,%eax
  801131:	83 e8 30             	sub    $0x30,%eax
  801134:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801137:	eb 48                	jmp    801181 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  801139:	8b 45 08             	mov    0x8(%ebp),%eax
  80113c:	0f b6 00             	movzbl (%eax),%eax
  80113f:	3c 60                	cmp    $0x60,%al
  801141:	7e 1b                	jle    80115e <strtol+0xf7>
  801143:	8b 45 08             	mov    0x8(%ebp),%eax
  801146:	0f b6 00             	movzbl (%eax),%eax
  801149:	3c 7a                	cmp    $0x7a,%al
  80114b:	7f 11                	jg     80115e <strtol+0xf7>
			dig = *s - 'a' + 10;
  80114d:	8b 45 08             	mov    0x8(%ebp),%eax
  801150:	0f b6 00             	movzbl (%eax),%eax
  801153:	0f be c0             	movsbl %al,%eax
  801156:	83 e8 57             	sub    $0x57,%eax
  801159:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80115c:	eb 23                	jmp    801181 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  80115e:	8b 45 08             	mov    0x8(%ebp),%eax
  801161:	0f b6 00             	movzbl (%eax),%eax
  801164:	3c 40                	cmp    $0x40,%al
  801166:	7e 3d                	jle    8011a5 <strtol+0x13e>
  801168:	8b 45 08             	mov    0x8(%ebp),%eax
  80116b:	0f b6 00             	movzbl (%eax),%eax
  80116e:	3c 5a                	cmp    $0x5a,%al
  801170:	7f 33                	jg     8011a5 <strtol+0x13e>
			dig = *s - 'A' + 10;
  801172:	8b 45 08             	mov    0x8(%ebp),%eax
  801175:	0f b6 00             	movzbl (%eax),%eax
  801178:	0f be c0             	movsbl %al,%eax
  80117b:	83 e8 37             	sub    $0x37,%eax
  80117e:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  801181:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801184:	3b 45 10             	cmp    0x10(%ebp),%eax
  801187:	7c 02                	jl     80118b <strtol+0x124>
			break;
  801189:	eb 1a                	jmp    8011a5 <strtol+0x13e>
		s++, val = (val * base) + dig;
  80118b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80118f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801192:	0f af 45 10          	imul   0x10(%ebp),%eax
  801196:	89 c2                	mov    %eax,%edx
  801198:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80119b:	01 d0                	add    %edx,%eax
  80119d:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  8011a0:	e9 6f ff ff ff       	jmp    801114 <strtol+0xad>

	if (endptr)
  8011a5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011a9:	74 08                	je     8011b3 <strtol+0x14c>
		*endptr = (char *) s;
  8011ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b1:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8011b3:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8011b7:	74 07                	je     8011c0 <strtol+0x159>
  8011b9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011bc:	f7 d8                	neg    %eax
  8011be:	eb 03                	jmp    8011c3 <strtol+0x15c>
  8011c0:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8011c3:	c9                   	leave  
  8011c4:	c3                   	ret    
  8011c5:	66 90                	xchg   %ax,%ax
  8011c7:	66 90                	xchg   %ax,%ax
  8011c9:	66 90                	xchg   %ax,%ax
  8011cb:	66 90                	xchg   %ax,%ax
  8011cd:	66 90                	xchg   %ax,%ax
  8011cf:	90                   	nop

008011d0 <__udivdi3>:
  8011d0:	55                   	push   %ebp
  8011d1:	57                   	push   %edi
  8011d2:	56                   	push   %esi
  8011d3:	83 ec 0c             	sub    $0xc,%esp
  8011d6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8011da:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8011de:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8011e2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011ec:	89 ea                	mov    %ebp,%edx
  8011ee:	89 0c 24             	mov    %ecx,(%esp)
  8011f1:	75 2d                	jne    801220 <__udivdi3+0x50>
  8011f3:	39 e9                	cmp    %ebp,%ecx
  8011f5:	77 61                	ja     801258 <__udivdi3+0x88>
  8011f7:	85 c9                	test   %ecx,%ecx
  8011f9:	89 ce                	mov    %ecx,%esi
  8011fb:	75 0b                	jne    801208 <__udivdi3+0x38>
  8011fd:	b8 01 00 00 00       	mov    $0x1,%eax
  801202:	31 d2                	xor    %edx,%edx
  801204:	f7 f1                	div    %ecx
  801206:	89 c6                	mov    %eax,%esi
  801208:	31 d2                	xor    %edx,%edx
  80120a:	89 e8                	mov    %ebp,%eax
  80120c:	f7 f6                	div    %esi
  80120e:	89 c5                	mov    %eax,%ebp
  801210:	89 f8                	mov    %edi,%eax
  801212:	f7 f6                	div    %esi
  801214:	89 ea                	mov    %ebp,%edx
  801216:	83 c4 0c             	add    $0xc,%esp
  801219:	5e                   	pop    %esi
  80121a:	5f                   	pop    %edi
  80121b:	5d                   	pop    %ebp
  80121c:	c3                   	ret    
  80121d:	8d 76 00             	lea    0x0(%esi),%esi
  801220:	39 e8                	cmp    %ebp,%eax
  801222:	77 24                	ja     801248 <__udivdi3+0x78>
  801224:	0f bd e8             	bsr    %eax,%ebp
  801227:	83 f5 1f             	xor    $0x1f,%ebp
  80122a:	75 3c                	jne    801268 <__udivdi3+0x98>
  80122c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801230:	39 34 24             	cmp    %esi,(%esp)
  801233:	0f 86 9f 00 00 00    	jbe    8012d8 <__udivdi3+0x108>
  801239:	39 d0                	cmp    %edx,%eax
  80123b:	0f 82 97 00 00 00    	jb     8012d8 <__udivdi3+0x108>
  801241:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801248:	31 d2                	xor    %edx,%edx
  80124a:	31 c0                	xor    %eax,%eax
  80124c:	83 c4 0c             	add    $0xc,%esp
  80124f:	5e                   	pop    %esi
  801250:	5f                   	pop    %edi
  801251:	5d                   	pop    %ebp
  801252:	c3                   	ret    
  801253:	90                   	nop
  801254:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801258:	89 f8                	mov    %edi,%eax
  80125a:	f7 f1                	div    %ecx
  80125c:	31 d2                	xor    %edx,%edx
  80125e:	83 c4 0c             	add    $0xc,%esp
  801261:	5e                   	pop    %esi
  801262:	5f                   	pop    %edi
  801263:	5d                   	pop    %ebp
  801264:	c3                   	ret    
  801265:	8d 76 00             	lea    0x0(%esi),%esi
  801268:	89 e9                	mov    %ebp,%ecx
  80126a:	8b 3c 24             	mov    (%esp),%edi
  80126d:	d3 e0                	shl    %cl,%eax
  80126f:	89 c6                	mov    %eax,%esi
  801271:	b8 20 00 00 00       	mov    $0x20,%eax
  801276:	29 e8                	sub    %ebp,%eax
  801278:	89 c1                	mov    %eax,%ecx
  80127a:	d3 ef                	shr    %cl,%edi
  80127c:	89 e9                	mov    %ebp,%ecx
  80127e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801282:	8b 3c 24             	mov    (%esp),%edi
  801285:	09 74 24 08          	or     %esi,0x8(%esp)
  801289:	89 d6                	mov    %edx,%esi
  80128b:	d3 e7                	shl    %cl,%edi
  80128d:	89 c1                	mov    %eax,%ecx
  80128f:	89 3c 24             	mov    %edi,(%esp)
  801292:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801296:	d3 ee                	shr    %cl,%esi
  801298:	89 e9                	mov    %ebp,%ecx
  80129a:	d3 e2                	shl    %cl,%edx
  80129c:	89 c1                	mov    %eax,%ecx
  80129e:	d3 ef                	shr    %cl,%edi
  8012a0:	09 d7                	or     %edx,%edi
  8012a2:	89 f2                	mov    %esi,%edx
  8012a4:	89 f8                	mov    %edi,%eax
  8012a6:	f7 74 24 08          	divl   0x8(%esp)
  8012aa:	89 d6                	mov    %edx,%esi
  8012ac:	89 c7                	mov    %eax,%edi
  8012ae:	f7 24 24             	mull   (%esp)
  8012b1:	39 d6                	cmp    %edx,%esi
  8012b3:	89 14 24             	mov    %edx,(%esp)
  8012b6:	72 30                	jb     8012e8 <__udivdi3+0x118>
  8012b8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012bc:	89 e9                	mov    %ebp,%ecx
  8012be:	d3 e2                	shl    %cl,%edx
  8012c0:	39 c2                	cmp    %eax,%edx
  8012c2:	73 05                	jae    8012c9 <__udivdi3+0xf9>
  8012c4:	3b 34 24             	cmp    (%esp),%esi
  8012c7:	74 1f                	je     8012e8 <__udivdi3+0x118>
  8012c9:	89 f8                	mov    %edi,%eax
  8012cb:	31 d2                	xor    %edx,%edx
  8012cd:	e9 7a ff ff ff       	jmp    80124c <__udivdi3+0x7c>
  8012d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012d8:	31 d2                	xor    %edx,%edx
  8012da:	b8 01 00 00 00       	mov    $0x1,%eax
  8012df:	e9 68 ff ff ff       	jmp    80124c <__udivdi3+0x7c>
  8012e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012e8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8012eb:	31 d2                	xor    %edx,%edx
  8012ed:	83 c4 0c             	add    $0xc,%esp
  8012f0:	5e                   	pop    %esi
  8012f1:	5f                   	pop    %edi
  8012f2:	5d                   	pop    %ebp
  8012f3:	c3                   	ret    
  8012f4:	66 90                	xchg   %ax,%ax
  8012f6:	66 90                	xchg   %ax,%ax
  8012f8:	66 90                	xchg   %ax,%ax
  8012fa:	66 90                	xchg   %ax,%ax
  8012fc:	66 90                	xchg   %ax,%ax
  8012fe:	66 90                	xchg   %ax,%ax

00801300 <__umoddi3>:
  801300:	55                   	push   %ebp
  801301:	57                   	push   %edi
  801302:	56                   	push   %esi
  801303:	83 ec 14             	sub    $0x14,%esp
  801306:	8b 44 24 28          	mov    0x28(%esp),%eax
  80130a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80130e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801312:	89 c7                	mov    %eax,%edi
  801314:	89 44 24 04          	mov    %eax,0x4(%esp)
  801318:	8b 44 24 30          	mov    0x30(%esp),%eax
  80131c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801320:	89 34 24             	mov    %esi,(%esp)
  801323:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801327:	85 c0                	test   %eax,%eax
  801329:	89 c2                	mov    %eax,%edx
  80132b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80132f:	75 17                	jne    801348 <__umoddi3+0x48>
  801331:	39 fe                	cmp    %edi,%esi
  801333:	76 4b                	jbe    801380 <__umoddi3+0x80>
  801335:	89 c8                	mov    %ecx,%eax
  801337:	89 fa                	mov    %edi,%edx
  801339:	f7 f6                	div    %esi
  80133b:	89 d0                	mov    %edx,%eax
  80133d:	31 d2                	xor    %edx,%edx
  80133f:	83 c4 14             	add    $0x14,%esp
  801342:	5e                   	pop    %esi
  801343:	5f                   	pop    %edi
  801344:	5d                   	pop    %ebp
  801345:	c3                   	ret    
  801346:	66 90                	xchg   %ax,%ax
  801348:	39 f8                	cmp    %edi,%eax
  80134a:	77 54                	ja     8013a0 <__umoddi3+0xa0>
  80134c:	0f bd e8             	bsr    %eax,%ebp
  80134f:	83 f5 1f             	xor    $0x1f,%ebp
  801352:	75 5c                	jne    8013b0 <__umoddi3+0xb0>
  801354:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801358:	39 3c 24             	cmp    %edi,(%esp)
  80135b:	0f 87 e7 00 00 00    	ja     801448 <__umoddi3+0x148>
  801361:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801365:	29 f1                	sub    %esi,%ecx
  801367:	19 c7                	sbb    %eax,%edi
  801369:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80136d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801371:	8b 44 24 08          	mov    0x8(%esp),%eax
  801375:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801379:	83 c4 14             	add    $0x14,%esp
  80137c:	5e                   	pop    %esi
  80137d:	5f                   	pop    %edi
  80137e:	5d                   	pop    %ebp
  80137f:	c3                   	ret    
  801380:	85 f6                	test   %esi,%esi
  801382:	89 f5                	mov    %esi,%ebp
  801384:	75 0b                	jne    801391 <__umoddi3+0x91>
  801386:	b8 01 00 00 00       	mov    $0x1,%eax
  80138b:	31 d2                	xor    %edx,%edx
  80138d:	f7 f6                	div    %esi
  80138f:	89 c5                	mov    %eax,%ebp
  801391:	8b 44 24 04          	mov    0x4(%esp),%eax
  801395:	31 d2                	xor    %edx,%edx
  801397:	f7 f5                	div    %ebp
  801399:	89 c8                	mov    %ecx,%eax
  80139b:	f7 f5                	div    %ebp
  80139d:	eb 9c                	jmp    80133b <__umoddi3+0x3b>
  80139f:	90                   	nop
  8013a0:	89 c8                	mov    %ecx,%eax
  8013a2:	89 fa                	mov    %edi,%edx
  8013a4:	83 c4 14             	add    $0x14,%esp
  8013a7:	5e                   	pop    %esi
  8013a8:	5f                   	pop    %edi
  8013a9:	5d                   	pop    %ebp
  8013aa:	c3                   	ret    
  8013ab:	90                   	nop
  8013ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013b0:	8b 04 24             	mov    (%esp),%eax
  8013b3:	be 20 00 00 00       	mov    $0x20,%esi
  8013b8:	89 e9                	mov    %ebp,%ecx
  8013ba:	29 ee                	sub    %ebp,%esi
  8013bc:	d3 e2                	shl    %cl,%edx
  8013be:	89 f1                	mov    %esi,%ecx
  8013c0:	d3 e8                	shr    %cl,%eax
  8013c2:	89 e9                	mov    %ebp,%ecx
  8013c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c8:	8b 04 24             	mov    (%esp),%eax
  8013cb:	09 54 24 04          	or     %edx,0x4(%esp)
  8013cf:	89 fa                	mov    %edi,%edx
  8013d1:	d3 e0                	shl    %cl,%eax
  8013d3:	89 f1                	mov    %esi,%ecx
  8013d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013d9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8013dd:	d3 ea                	shr    %cl,%edx
  8013df:	89 e9                	mov    %ebp,%ecx
  8013e1:	d3 e7                	shl    %cl,%edi
  8013e3:	89 f1                	mov    %esi,%ecx
  8013e5:	d3 e8                	shr    %cl,%eax
  8013e7:	89 e9                	mov    %ebp,%ecx
  8013e9:	09 f8                	or     %edi,%eax
  8013eb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8013ef:	f7 74 24 04          	divl   0x4(%esp)
  8013f3:	d3 e7                	shl    %cl,%edi
  8013f5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013f9:	89 d7                	mov    %edx,%edi
  8013fb:	f7 64 24 08          	mull   0x8(%esp)
  8013ff:	39 d7                	cmp    %edx,%edi
  801401:	89 c1                	mov    %eax,%ecx
  801403:	89 14 24             	mov    %edx,(%esp)
  801406:	72 2c                	jb     801434 <__umoddi3+0x134>
  801408:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80140c:	72 22                	jb     801430 <__umoddi3+0x130>
  80140e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801412:	29 c8                	sub    %ecx,%eax
  801414:	19 d7                	sbb    %edx,%edi
  801416:	89 e9                	mov    %ebp,%ecx
  801418:	89 fa                	mov    %edi,%edx
  80141a:	d3 e8                	shr    %cl,%eax
  80141c:	89 f1                	mov    %esi,%ecx
  80141e:	d3 e2                	shl    %cl,%edx
  801420:	89 e9                	mov    %ebp,%ecx
  801422:	d3 ef                	shr    %cl,%edi
  801424:	09 d0                	or     %edx,%eax
  801426:	89 fa                	mov    %edi,%edx
  801428:	83 c4 14             	add    $0x14,%esp
  80142b:	5e                   	pop    %esi
  80142c:	5f                   	pop    %edi
  80142d:	5d                   	pop    %ebp
  80142e:	c3                   	ret    
  80142f:	90                   	nop
  801430:	39 d7                	cmp    %edx,%edi
  801432:	75 da                	jne    80140e <__umoddi3+0x10e>
  801434:	8b 14 24             	mov    (%esp),%edx
  801437:	89 c1                	mov    %eax,%ecx
  801439:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80143d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801441:	eb cb                	jmp    80140e <__umoddi3+0x10e>
  801443:	90                   	nop
  801444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801448:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80144c:	0f 82 0f ff ff ff    	jb     801361 <__umoddi3+0x61>
  801452:	e9 1a ff ff ff       	jmp    801371 <__umoddi3+0x71>
