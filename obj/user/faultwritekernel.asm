
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
  8000d0:	c7 44 24 08 aa 14 80 	movl   $0x8014aa,0x8(%esp)
  8000d7:	00 
  8000d8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000df:	00 
  8000e0:	c7 04 24 c7 14 80 00 	movl   $0x8014c7,(%esp)
  8000e7:	e8 f7 03 00 00       	call   8004e3 <_panic>

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
}
  80049d:	c9                   	leave  
  80049e:	c3                   	ret    

0080049f <sys_guest>:

void sys_guest(){
  80049f:	55                   	push   %ebp
  8004a0:	89 e5                	mov    %esp,%ebp
  8004a2:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_guest, 0, 0, 0, 0, 0, 0);
  8004a5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8004ac:	00 
  8004ad:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8004b4:	00 
  8004b5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8004bc:	00 
  8004bd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004c4:	00 
  8004c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004cc:	00 
  8004cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004d4:	00 
  8004d5:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
  8004dc:	e8 b5 fb ff ff       	call   800096 <syscall>
  8004e1:	c9                   	leave  
  8004e2:	c3                   	ret    

008004e3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004e3:	55                   	push   %ebp
  8004e4:	89 e5                	mov    %esp,%ebp
  8004e6:	53                   	push   %ebx
  8004e7:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  8004ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8004ed:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004f0:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8004f6:	e8 c5 fc ff ff       	call   8001c0 <sys_getenvid>
  8004fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004fe:	89 54 24 10          	mov    %edx,0x10(%esp)
  800502:	8b 55 08             	mov    0x8(%ebp),%edx
  800505:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800509:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80050d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800511:	c7 04 24 d8 14 80 00 	movl   $0x8014d8,(%esp)
  800518:	e8 e1 00 00 00       	call   8005fe <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80051d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800520:	89 44 24 04          	mov    %eax,0x4(%esp)
  800524:	8b 45 10             	mov    0x10(%ebp),%eax
  800527:	89 04 24             	mov    %eax,(%esp)
  80052a:	e8 6b 00 00 00       	call   80059a <vcprintf>
	cprintf("\n");
  80052f:	c7 04 24 fb 14 80 00 	movl   $0x8014fb,(%esp)
  800536:	e8 c3 00 00 00       	call   8005fe <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80053b:	cc                   	int3   
  80053c:	eb fd                	jmp    80053b <_panic+0x58>

0080053e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80053e:	55                   	push   %ebp
  80053f:	89 e5                	mov    %esp,%ebp
  800541:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800544:	8b 45 0c             	mov    0xc(%ebp),%eax
  800547:	8b 00                	mov    (%eax),%eax
  800549:	8d 48 01             	lea    0x1(%eax),%ecx
  80054c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80054f:	89 0a                	mov    %ecx,(%edx)
  800551:	8b 55 08             	mov    0x8(%ebp),%edx
  800554:	89 d1                	mov    %edx,%ecx
  800556:	8b 55 0c             	mov    0xc(%ebp),%edx
  800559:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  80055d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800560:	8b 00                	mov    (%eax),%eax
  800562:	3d ff 00 00 00       	cmp    $0xff,%eax
  800567:	75 20                	jne    800589 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800569:	8b 45 0c             	mov    0xc(%ebp),%eax
  80056c:	8b 00                	mov    (%eax),%eax
  80056e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800571:	83 c2 08             	add    $0x8,%edx
  800574:	89 44 24 04          	mov    %eax,0x4(%esp)
  800578:	89 14 24             	mov    %edx,(%esp)
  80057b:	e8 77 fb ff ff       	call   8000f7 <sys_cputs>
		b->idx = 0;
  800580:	8b 45 0c             	mov    0xc(%ebp),%eax
  800583:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800589:	8b 45 0c             	mov    0xc(%ebp),%eax
  80058c:	8b 40 04             	mov    0x4(%eax),%eax
  80058f:	8d 50 01             	lea    0x1(%eax),%edx
  800592:	8b 45 0c             	mov    0xc(%ebp),%eax
  800595:	89 50 04             	mov    %edx,0x4(%eax)
}
  800598:	c9                   	leave  
  800599:	c3                   	ret    

0080059a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80059a:	55                   	push   %ebp
  80059b:	89 e5                	mov    %esp,%ebp
  80059d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8005a3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8005aa:	00 00 00 
	b.cnt = 0;
  8005ad:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8005b4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8005b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005be:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005c5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005cf:	c7 04 24 3e 05 80 00 	movl   $0x80053e,(%esp)
  8005d6:	e8 bd 01 00 00       	call   800798 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005db:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8005e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005eb:	83 c0 08             	add    $0x8,%eax
  8005ee:	89 04 24             	mov    %eax,(%esp)
  8005f1:	e8 01 fb ff ff       	call   8000f7 <sys_cputs>

	return b.cnt;
  8005f6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8005fc:	c9                   	leave  
  8005fd:	c3                   	ret    

008005fe <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005fe:	55                   	push   %ebp
  8005ff:	89 e5                	mov    %esp,%ebp
  800601:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800604:	8d 45 0c             	lea    0xc(%ebp),%eax
  800607:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  80060a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80060d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800611:	8b 45 08             	mov    0x8(%ebp),%eax
  800614:	89 04 24             	mov    %eax,(%esp)
  800617:	e8 7e ff ff ff       	call   80059a <vcprintf>
  80061c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  80061f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800622:	c9                   	leave  
  800623:	c3                   	ret    

00800624 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800624:	55                   	push   %ebp
  800625:	89 e5                	mov    %esp,%ebp
  800627:	53                   	push   %ebx
  800628:	83 ec 34             	sub    $0x34,%esp
  80062b:	8b 45 10             	mov    0x10(%ebp),%eax
  80062e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800637:	8b 45 18             	mov    0x18(%ebp),%eax
  80063a:	ba 00 00 00 00       	mov    $0x0,%edx
  80063f:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800642:	77 72                	ja     8006b6 <printnum+0x92>
  800644:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800647:	72 05                	jb     80064e <printnum+0x2a>
  800649:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  80064c:	77 68                	ja     8006b6 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80064e:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800651:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800654:	8b 45 18             	mov    0x18(%ebp),%eax
  800657:	ba 00 00 00 00       	mov    $0x0,%edx
  80065c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800660:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800664:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800667:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80066a:	89 04 24             	mov    %eax,(%esp)
  80066d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800671:	e8 9a 0b 00 00       	call   801210 <__udivdi3>
  800676:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800679:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  80067d:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800681:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800684:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800688:	89 44 24 08          	mov    %eax,0x8(%esp)
  80068c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800690:	8b 45 0c             	mov    0xc(%ebp),%eax
  800693:	89 44 24 04          	mov    %eax,0x4(%esp)
  800697:	8b 45 08             	mov    0x8(%ebp),%eax
  80069a:	89 04 24             	mov    %eax,(%esp)
  80069d:	e8 82 ff ff ff       	call   800624 <printnum>
  8006a2:	eb 1c                	jmp    8006c0 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8006a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ab:	8b 45 20             	mov    0x20(%ebp),%eax
  8006ae:	89 04 24             	mov    %eax,(%esp)
  8006b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b4:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006b6:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8006ba:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8006be:	7f e4                	jg     8006a4 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006c0:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8006c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006ce:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006d2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006d6:	89 04 24             	mov    %eax,(%esp)
  8006d9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006dd:	e8 5e 0c 00 00       	call   801340 <__umoddi3>
  8006e2:	05 c8 15 80 00       	add    $0x8015c8,%eax
  8006e7:	0f b6 00             	movzbl (%eax),%eax
  8006ea:	0f be c0             	movsbl %al,%eax
  8006ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006f0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006f4:	89 04 24             	mov    %eax,(%esp)
  8006f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fa:	ff d0                	call   *%eax
}
  8006fc:	83 c4 34             	add    $0x34,%esp
  8006ff:	5b                   	pop    %ebx
  800700:	5d                   	pop    %ebp
  800701:	c3                   	ret    

00800702 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800705:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800709:	7e 14                	jle    80071f <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80070b:	8b 45 08             	mov    0x8(%ebp),%eax
  80070e:	8b 00                	mov    (%eax),%eax
  800710:	8d 48 08             	lea    0x8(%eax),%ecx
  800713:	8b 55 08             	mov    0x8(%ebp),%edx
  800716:	89 0a                	mov    %ecx,(%edx)
  800718:	8b 50 04             	mov    0x4(%eax),%edx
  80071b:	8b 00                	mov    (%eax),%eax
  80071d:	eb 30                	jmp    80074f <getuint+0x4d>
	else if (lflag)
  80071f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800723:	74 16                	je     80073b <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800725:	8b 45 08             	mov    0x8(%ebp),%eax
  800728:	8b 00                	mov    (%eax),%eax
  80072a:	8d 48 04             	lea    0x4(%eax),%ecx
  80072d:	8b 55 08             	mov    0x8(%ebp),%edx
  800730:	89 0a                	mov    %ecx,(%edx)
  800732:	8b 00                	mov    (%eax),%eax
  800734:	ba 00 00 00 00       	mov    $0x0,%edx
  800739:	eb 14                	jmp    80074f <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  80073b:	8b 45 08             	mov    0x8(%ebp),%eax
  80073e:	8b 00                	mov    (%eax),%eax
  800740:	8d 48 04             	lea    0x4(%eax),%ecx
  800743:	8b 55 08             	mov    0x8(%ebp),%edx
  800746:	89 0a                	mov    %ecx,(%edx)
  800748:	8b 00                	mov    (%eax),%eax
  80074a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80074f:	5d                   	pop    %ebp
  800750:	c3                   	ret    

00800751 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800754:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800758:	7e 14                	jle    80076e <getint+0x1d>
		return va_arg(*ap, long long);
  80075a:	8b 45 08             	mov    0x8(%ebp),%eax
  80075d:	8b 00                	mov    (%eax),%eax
  80075f:	8d 48 08             	lea    0x8(%eax),%ecx
  800762:	8b 55 08             	mov    0x8(%ebp),%edx
  800765:	89 0a                	mov    %ecx,(%edx)
  800767:	8b 50 04             	mov    0x4(%eax),%edx
  80076a:	8b 00                	mov    (%eax),%eax
  80076c:	eb 28                	jmp    800796 <getint+0x45>
	else if (lflag)
  80076e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800772:	74 12                	je     800786 <getint+0x35>
		return va_arg(*ap, long);
  800774:	8b 45 08             	mov    0x8(%ebp),%eax
  800777:	8b 00                	mov    (%eax),%eax
  800779:	8d 48 04             	lea    0x4(%eax),%ecx
  80077c:	8b 55 08             	mov    0x8(%ebp),%edx
  80077f:	89 0a                	mov    %ecx,(%edx)
  800781:	8b 00                	mov    (%eax),%eax
  800783:	99                   	cltd   
  800784:	eb 10                	jmp    800796 <getint+0x45>
	else
		return va_arg(*ap, int);
  800786:	8b 45 08             	mov    0x8(%ebp),%eax
  800789:	8b 00                	mov    (%eax),%eax
  80078b:	8d 48 04             	lea    0x4(%eax),%ecx
  80078e:	8b 55 08             	mov    0x8(%ebp),%edx
  800791:	89 0a                	mov    %ecx,(%edx)
  800793:	8b 00                	mov    (%eax),%eax
  800795:	99                   	cltd   
}
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	56                   	push   %esi
  80079c:	53                   	push   %ebx
  80079d:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007a0:	eb 18                	jmp    8007ba <vprintfmt+0x22>
			if (ch == '\0')
  8007a2:	85 db                	test   %ebx,%ebx
  8007a4:	75 05                	jne    8007ab <vprintfmt+0x13>
				return;
  8007a6:	e9 cc 03 00 00       	jmp    800b77 <vprintfmt+0x3df>
			putch(ch, putdat);
  8007ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b2:	89 1c 24             	mov    %ebx,(%esp)
  8007b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b8:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8007bd:	8d 50 01             	lea    0x1(%eax),%edx
  8007c0:	89 55 10             	mov    %edx,0x10(%ebp)
  8007c3:	0f b6 00             	movzbl (%eax),%eax
  8007c6:	0f b6 d8             	movzbl %al,%ebx
  8007c9:	83 fb 25             	cmp    $0x25,%ebx
  8007cc:	75 d4                	jne    8007a2 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8007ce:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8007d2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8007d9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8007e0:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8007e7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f1:	8d 50 01             	lea    0x1(%eax),%edx
  8007f4:	89 55 10             	mov    %edx,0x10(%ebp)
  8007f7:	0f b6 00             	movzbl (%eax),%eax
  8007fa:	0f b6 d8             	movzbl %al,%ebx
  8007fd:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800800:	83 f8 55             	cmp    $0x55,%eax
  800803:	0f 87 3d 03 00 00    	ja     800b46 <vprintfmt+0x3ae>
  800809:	8b 04 85 ec 15 80 00 	mov    0x8015ec(,%eax,4),%eax
  800810:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800812:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800816:	eb d6                	jmp    8007ee <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800818:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  80081c:	eb d0                	jmp    8007ee <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80081e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800825:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800828:	89 d0                	mov    %edx,%eax
  80082a:	c1 e0 02             	shl    $0x2,%eax
  80082d:	01 d0                	add    %edx,%eax
  80082f:	01 c0                	add    %eax,%eax
  800831:	01 d8                	add    %ebx,%eax
  800833:	83 e8 30             	sub    $0x30,%eax
  800836:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800839:	8b 45 10             	mov    0x10(%ebp),%eax
  80083c:	0f b6 00             	movzbl (%eax),%eax
  80083f:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800842:	83 fb 2f             	cmp    $0x2f,%ebx
  800845:	7e 0b                	jle    800852 <vprintfmt+0xba>
  800847:	83 fb 39             	cmp    $0x39,%ebx
  80084a:	7f 06                	jg     800852 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80084c:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800850:	eb d3                	jmp    800825 <vprintfmt+0x8d>
			goto process_precision;
  800852:	eb 33                	jmp    800887 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800854:	8b 45 14             	mov    0x14(%ebp),%eax
  800857:	8d 50 04             	lea    0x4(%eax),%edx
  80085a:	89 55 14             	mov    %edx,0x14(%ebp)
  80085d:	8b 00                	mov    (%eax),%eax
  80085f:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800862:	eb 23                	jmp    800887 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800864:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800868:	79 0c                	jns    800876 <vprintfmt+0xde>
				width = 0;
  80086a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800871:	e9 78 ff ff ff       	jmp    8007ee <vprintfmt+0x56>
  800876:	e9 73 ff ff ff       	jmp    8007ee <vprintfmt+0x56>

		case '#':
			altflag = 1;
  80087b:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800882:	e9 67 ff ff ff       	jmp    8007ee <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800887:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80088b:	79 12                	jns    80089f <vprintfmt+0x107>
				width = precision, precision = -1;
  80088d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800890:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800893:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  80089a:	e9 4f ff ff ff       	jmp    8007ee <vprintfmt+0x56>
  80089f:	e9 4a ff ff ff       	jmp    8007ee <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008a4:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8008a8:	e9 41 ff ff ff       	jmp    8007ee <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b0:	8d 50 04             	lea    0x4(%eax),%edx
  8008b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b6:	8b 00                	mov    (%eax),%eax
  8008b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008bf:	89 04 24             	mov    %eax,(%esp)
  8008c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c5:	ff d0                	call   *%eax
			break;
  8008c7:	e9 a5 02 00 00       	jmp    800b71 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cf:	8d 50 04             	lea    0x4(%eax),%edx
  8008d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d5:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8008d7:	85 db                	test   %ebx,%ebx
  8008d9:	79 02                	jns    8008dd <vprintfmt+0x145>
				err = -err;
  8008db:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8008dd:	83 fb 09             	cmp    $0x9,%ebx
  8008e0:	7f 0b                	jg     8008ed <vprintfmt+0x155>
  8008e2:	8b 34 9d a0 15 80 00 	mov    0x8015a0(,%ebx,4),%esi
  8008e9:	85 f6                	test   %esi,%esi
  8008eb:	75 23                	jne    800910 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  8008ed:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8008f1:	c7 44 24 08 d9 15 80 	movl   $0x8015d9,0x8(%esp)
  8008f8:	00 
  8008f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800900:	8b 45 08             	mov    0x8(%ebp),%eax
  800903:	89 04 24             	mov    %eax,(%esp)
  800906:	e8 73 02 00 00       	call   800b7e <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80090b:	e9 61 02 00 00       	jmp    800b71 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800910:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800914:	c7 44 24 08 e2 15 80 	movl   $0x8015e2,0x8(%esp)
  80091b:	00 
  80091c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	89 04 24             	mov    %eax,(%esp)
  800929:	e8 50 02 00 00       	call   800b7e <printfmt>
			break;
  80092e:	e9 3e 02 00 00       	jmp    800b71 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800933:	8b 45 14             	mov    0x14(%ebp),%eax
  800936:	8d 50 04             	lea    0x4(%eax),%edx
  800939:	89 55 14             	mov    %edx,0x14(%ebp)
  80093c:	8b 30                	mov    (%eax),%esi
  80093e:	85 f6                	test   %esi,%esi
  800940:	75 05                	jne    800947 <vprintfmt+0x1af>
				p = "(null)";
  800942:	be e5 15 80 00       	mov    $0x8015e5,%esi
			if (width > 0 && padc != '-')
  800947:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80094b:	7e 37                	jle    800984 <vprintfmt+0x1ec>
  80094d:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800951:	74 31                	je     800984 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800953:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800956:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095a:	89 34 24             	mov    %esi,(%esp)
  80095d:	e8 39 03 00 00       	call   800c9b <strnlen>
  800962:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800965:	eb 17                	jmp    80097e <vprintfmt+0x1e6>
					putch(padc, putdat);
  800967:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  80096b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800972:	89 04 24             	mov    %eax,(%esp)
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80097a:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80097e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800982:	7f e3                	jg     800967 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800984:	eb 38                	jmp    8009be <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800986:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80098a:	74 1f                	je     8009ab <vprintfmt+0x213>
  80098c:	83 fb 1f             	cmp    $0x1f,%ebx
  80098f:	7e 05                	jle    800996 <vprintfmt+0x1fe>
  800991:	83 fb 7e             	cmp    $0x7e,%ebx
  800994:	7e 15                	jle    8009ab <vprintfmt+0x213>
					putch('?', putdat);
  800996:	8b 45 0c             	mov    0xc(%ebp),%eax
  800999:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	ff d0                	call   *%eax
  8009a9:	eb 0f                	jmp    8009ba <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8009ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b2:	89 1c 24             	mov    %ebx,(%esp)
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009ba:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8009be:	89 f0                	mov    %esi,%eax
  8009c0:	8d 70 01             	lea    0x1(%eax),%esi
  8009c3:	0f b6 00             	movzbl (%eax),%eax
  8009c6:	0f be d8             	movsbl %al,%ebx
  8009c9:	85 db                	test   %ebx,%ebx
  8009cb:	74 10                	je     8009dd <vprintfmt+0x245>
  8009cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009d1:	78 b3                	js     800986 <vprintfmt+0x1ee>
  8009d3:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8009d7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009db:	79 a9                	jns    800986 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009dd:	eb 17                	jmp    8009f6 <vprintfmt+0x25e>
				putch(' ', putdat);
  8009df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009f2:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8009f6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009fa:	7f e3                	jg     8009df <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  8009fc:	e9 70 01 00 00       	jmp    800b71 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800a01:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a04:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a08:	8d 45 14             	lea    0x14(%ebp),%eax
  800a0b:	89 04 24             	mov    %eax,(%esp)
  800a0e:	e8 3e fd ff ff       	call   800751 <getint>
  800a13:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a16:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800a19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a1f:	85 d2                	test   %edx,%edx
  800a21:	79 26                	jns    800a49 <vprintfmt+0x2b1>
				putch('-', putdat);
  800a23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a26:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a2a:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a31:	8b 45 08             	mov    0x8(%ebp),%eax
  800a34:	ff d0                	call   *%eax
				num = -(long long) num;
  800a36:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a39:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a3c:	f7 d8                	neg    %eax
  800a3e:	83 d2 00             	adc    $0x0,%edx
  800a41:	f7 da                	neg    %edx
  800a43:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a46:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800a49:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a50:	e9 a8 00 00 00       	jmp    800afd <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a55:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a58:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a5c:	8d 45 14             	lea    0x14(%ebp),%eax
  800a5f:	89 04 24             	mov    %eax,(%esp)
  800a62:	e8 9b fc ff ff       	call   800702 <getuint>
  800a67:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a6a:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800a6d:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800a74:	e9 84 00 00 00       	jmp    800afd <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a79:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a80:	8d 45 14             	lea    0x14(%ebp),%eax
  800a83:	89 04 24             	mov    %eax,(%esp)
  800a86:	e8 77 fc ff ff       	call   800702 <getuint>
  800a8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a8e:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  800a91:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  800a98:	eb 63                	jmp    800afd <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800a9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa1:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aab:	ff d0                	call   *%eax
			putch('x', putdat);
  800aad:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800abb:	8b 45 08             	mov    0x8(%ebp),%eax
  800abe:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800ac0:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac3:	8d 50 04             	lea    0x4(%eax),%edx
  800ac6:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac9:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800acb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ace:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800ad5:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800adc:	eb 1f                	jmp    800afd <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800ade:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800ae1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae5:	8d 45 14             	lea    0x14(%ebp),%eax
  800ae8:	89 04 24             	mov    %eax,(%esp)
  800aeb:	e8 12 fc ff ff       	call   800702 <getuint>
  800af0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800af3:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800af6:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800afd:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800b01:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b04:	89 54 24 18          	mov    %edx,0x18(%esp)
  800b08:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b0b:	89 54 24 14          	mov    %edx,0x14(%esp)
  800b0f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b16:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b19:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b1d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b21:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b24:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b28:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2b:	89 04 24             	mov    %eax,(%esp)
  800b2e:	e8 f1 fa ff ff       	call   800624 <printnum>
			break;
  800b33:	eb 3c                	jmp    800b71 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b35:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b38:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b3c:	89 1c 24             	mov    %ebx,(%esp)
  800b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b42:	ff d0                	call   *%eax
			break;
  800b44:	eb 2b                	jmp    800b71 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b46:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b49:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b4d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b54:	8b 45 08             	mov    0x8(%ebp),%eax
  800b57:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b59:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b5d:	eb 04                	jmp    800b63 <vprintfmt+0x3cb>
  800b5f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b63:	8b 45 10             	mov    0x10(%ebp),%eax
  800b66:	83 e8 01             	sub    $0x1,%eax
  800b69:	0f b6 00             	movzbl (%eax),%eax
  800b6c:	3c 25                	cmp    $0x25,%al
  800b6e:	75 ef                	jne    800b5f <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  800b70:	90                   	nop
		}
	}
  800b71:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b72:	e9 43 fc ff ff       	jmp    8007ba <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800b77:	83 c4 40             	add    $0x40,%esp
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b84:	8d 45 14             	lea    0x14(%ebp),%eax
  800b87:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b8d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b91:	8b 45 10             	mov    0x10(%ebp),%eax
  800b94:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b98:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba2:	89 04 24             	mov    %eax,(%esp)
  800ba5:	e8 ee fb ff ff       	call   800798 <vprintfmt>
	va_end(ap);
}
  800baa:	c9                   	leave  
  800bab:	c3                   	ret    

00800bac <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800baf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb2:	8b 40 08             	mov    0x8(%eax),%eax
  800bb5:	8d 50 01             	lea    0x1(%eax),%edx
  800bb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbb:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800bbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc1:	8b 10                	mov    (%eax),%edx
  800bc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc6:	8b 40 04             	mov    0x4(%eax),%eax
  800bc9:	39 c2                	cmp    %eax,%edx
  800bcb:	73 12                	jae    800bdf <sprintputch+0x33>
		*b->buf++ = ch;
  800bcd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd0:	8b 00                	mov    (%eax),%eax
  800bd2:	8d 48 01             	lea    0x1(%eax),%ecx
  800bd5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bd8:	89 0a                	mov    %ecx,(%edx)
  800bda:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdd:	88 10                	mov    %dl,(%eax)
}
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800be7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bed:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf0:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bf3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf6:	01 d0                	add    %edx,%eax
  800bf8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800bfb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c02:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800c06:	74 06                	je     800c0e <vsnprintf+0x2d>
  800c08:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c0c:	7f 07                	jg     800c15 <vsnprintf+0x34>
		return -E_INVAL;
  800c0e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c13:	eb 2a                	jmp    800c3f <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c15:	8b 45 14             	mov    0x14(%ebp),%eax
  800c18:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c1c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c1f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c23:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c26:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c2a:	c7 04 24 ac 0b 80 00 	movl   $0x800bac,(%esp)
  800c31:	e8 62 fb ff ff       	call   800798 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c36:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c39:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c3f:	c9                   	leave  
  800c40:	c3                   	ret    

00800c41 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c47:	8d 45 14             	lea    0x14(%ebp),%eax
  800c4a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800c4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c50:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c54:	8b 45 10             	mov    0x10(%ebp),%eax
  800c57:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c62:	8b 45 08             	mov    0x8(%ebp),%eax
  800c65:	89 04 24             	mov    %eax,(%esp)
  800c68:	e8 74 ff ff ff       	call   800be1 <vsnprintf>
  800c6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c73:	c9                   	leave  
  800c74:	c3                   	ret    

00800c75 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800c7b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c82:	eb 08                	jmp    800c8c <strlen+0x17>
		n++;
  800c84:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c88:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8f:	0f b6 00             	movzbl (%eax),%eax
  800c92:	84 c0                	test   %al,%al
  800c94:	75 ee                	jne    800c84 <strlen+0xf>
		n++;
	return n;
  800c96:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c99:	c9                   	leave  
  800c9a:	c3                   	ret    

00800c9b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ca1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800ca8:	eb 0c                	jmp    800cb6 <strnlen+0x1b>
		n++;
  800caa:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cae:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800cb2:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800cb6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cba:	74 0a                	je     800cc6 <strnlen+0x2b>
  800cbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbf:	0f b6 00             	movzbl (%eax),%eax
  800cc2:	84 c0                	test   %al,%al
  800cc4:	75 e4                	jne    800caa <strnlen+0xf>
		n++;
	return n;
  800cc6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800cc9:	c9                   	leave  
  800cca:	c3                   	ret    

00800ccb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800cd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd4:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800cd7:	90                   	nop
  800cd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdb:	8d 50 01             	lea    0x1(%eax),%edx
  800cde:	89 55 08             	mov    %edx,0x8(%ebp)
  800ce1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ce4:	8d 4a 01             	lea    0x1(%edx),%ecx
  800ce7:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800cea:	0f b6 12             	movzbl (%edx),%edx
  800ced:	88 10                	mov    %dl,(%eax)
  800cef:	0f b6 00             	movzbl (%eax),%eax
  800cf2:	84 c0                	test   %al,%al
  800cf4:	75 e2                	jne    800cd8 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800cf6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800cf9:	c9                   	leave  
  800cfa:	c3                   	ret    

00800cfb <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800d01:	8b 45 08             	mov    0x8(%ebp),%eax
  800d04:	89 04 24             	mov    %eax,(%esp)
  800d07:	e8 69 ff ff ff       	call   800c75 <strlen>
  800d0c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800d0f:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800d12:	8b 45 08             	mov    0x8(%ebp),%eax
  800d15:	01 c2                	add    %eax,%edx
  800d17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d1e:	89 14 24             	mov    %edx,(%esp)
  800d21:	e8 a5 ff ff ff       	call   800ccb <strcpy>
	return dst;
  800d26:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800d29:	c9                   	leave  
  800d2a:	c3                   	ret    

00800d2b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800d31:	8b 45 08             	mov    0x8(%ebp),%eax
  800d34:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800d37:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800d3e:	eb 23                	jmp    800d63 <strncpy+0x38>
		*dst++ = *src;
  800d40:	8b 45 08             	mov    0x8(%ebp),%eax
  800d43:	8d 50 01             	lea    0x1(%eax),%edx
  800d46:	89 55 08             	mov    %edx,0x8(%ebp)
  800d49:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d4c:	0f b6 12             	movzbl (%edx),%edx
  800d4f:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800d51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d54:	0f b6 00             	movzbl (%eax),%eax
  800d57:	84 c0                	test   %al,%al
  800d59:	74 04                	je     800d5f <strncpy+0x34>
			src++;
  800d5b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d5f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d63:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d66:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d69:	72 d5                	jb     800d40 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800d6b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d6e:	c9                   	leave  
  800d6f:	c3                   	ret    

00800d70 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800d76:	8b 45 08             	mov    0x8(%ebp),%eax
  800d79:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800d7c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d80:	74 33                	je     800db5 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d82:	eb 17                	jmp    800d9b <strlcpy+0x2b>
			*dst++ = *src++;
  800d84:	8b 45 08             	mov    0x8(%ebp),%eax
  800d87:	8d 50 01             	lea    0x1(%eax),%edx
  800d8a:	89 55 08             	mov    %edx,0x8(%ebp)
  800d8d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d90:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d93:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d96:	0f b6 12             	movzbl (%edx),%edx
  800d99:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d9b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d9f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800da3:	74 0a                	je     800daf <strlcpy+0x3f>
  800da5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da8:	0f b6 00             	movzbl (%eax),%eax
  800dab:	84 c0                	test   %al,%al
  800dad:	75 d5                	jne    800d84 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800daf:	8b 45 08             	mov    0x8(%ebp),%eax
  800db2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800db5:	8b 55 08             	mov    0x8(%ebp),%edx
  800db8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800dbb:	29 c2                	sub    %eax,%edx
  800dbd:	89 d0                	mov    %edx,%eax
}
  800dbf:	c9                   	leave  
  800dc0:	c3                   	ret    

00800dc1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800dc4:	eb 08                	jmp    800dce <strcmp+0xd>
		p++, q++;
  800dc6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dca:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800dce:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd1:	0f b6 00             	movzbl (%eax),%eax
  800dd4:	84 c0                	test   %al,%al
  800dd6:	74 10                	je     800de8 <strcmp+0x27>
  800dd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddb:	0f b6 10             	movzbl (%eax),%edx
  800dde:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de1:	0f b6 00             	movzbl (%eax),%eax
  800de4:	38 c2                	cmp    %al,%dl
  800de6:	74 de                	je     800dc6 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800de8:	8b 45 08             	mov    0x8(%ebp),%eax
  800deb:	0f b6 00             	movzbl (%eax),%eax
  800dee:	0f b6 d0             	movzbl %al,%edx
  800df1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df4:	0f b6 00             	movzbl (%eax),%eax
  800df7:	0f b6 c0             	movzbl %al,%eax
  800dfa:	29 c2                	sub    %eax,%edx
  800dfc:	89 d0                	mov    %edx,%eax
}
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800e03:	eb 0c                	jmp    800e11 <strncmp+0x11>
		n--, p++, q++;
  800e05:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800e09:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e0d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e11:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e15:	74 1a                	je     800e31 <strncmp+0x31>
  800e17:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1a:	0f b6 00             	movzbl (%eax),%eax
  800e1d:	84 c0                	test   %al,%al
  800e1f:	74 10                	je     800e31 <strncmp+0x31>
  800e21:	8b 45 08             	mov    0x8(%ebp),%eax
  800e24:	0f b6 10             	movzbl (%eax),%edx
  800e27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e2a:	0f b6 00             	movzbl (%eax),%eax
  800e2d:	38 c2                	cmp    %al,%dl
  800e2f:	74 d4                	je     800e05 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800e31:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e35:	75 07                	jne    800e3e <strncmp+0x3e>
		return 0;
  800e37:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3c:	eb 16                	jmp    800e54 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e41:	0f b6 00             	movzbl (%eax),%eax
  800e44:	0f b6 d0             	movzbl %al,%edx
  800e47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e4a:	0f b6 00             	movzbl (%eax),%eax
  800e4d:	0f b6 c0             	movzbl %al,%eax
  800e50:	29 c2                	sub    %eax,%edx
  800e52:	89 d0                	mov    %edx,%eax
}
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	83 ec 04             	sub    $0x4,%esp
  800e5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5f:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e62:	eb 14                	jmp    800e78 <strchr+0x22>
		if (*s == c)
  800e64:	8b 45 08             	mov    0x8(%ebp),%eax
  800e67:	0f b6 00             	movzbl (%eax),%eax
  800e6a:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e6d:	75 05                	jne    800e74 <strchr+0x1e>
			return (char *) s;
  800e6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e72:	eb 13                	jmp    800e87 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e74:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e78:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7b:	0f b6 00             	movzbl (%eax),%eax
  800e7e:	84 c0                	test   %al,%al
  800e80:	75 e2                	jne    800e64 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e82:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e87:	c9                   	leave  
  800e88:	c3                   	ret    

00800e89 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	83 ec 04             	sub    $0x4,%esp
  800e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e92:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e95:	eb 11                	jmp    800ea8 <strfind+0x1f>
		if (*s == c)
  800e97:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9a:	0f b6 00             	movzbl (%eax),%eax
  800e9d:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800ea0:	75 02                	jne    800ea4 <strfind+0x1b>
			break;
  800ea2:	eb 0e                	jmp    800eb2 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ea4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800ea8:	8b 45 08             	mov    0x8(%ebp),%eax
  800eab:	0f b6 00             	movzbl (%eax),%eax
  800eae:	84 c0                	test   %al,%al
  800eb0:	75 e5                	jne    800e97 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800eb2:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800eb5:	c9                   	leave  
  800eb6:	c3                   	ret    

00800eb7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	57                   	push   %edi
	char *p;

	if (n == 0)
  800ebb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ebf:	75 05                	jne    800ec6 <memset+0xf>
		return v;
  800ec1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec4:	eb 5c                	jmp    800f22 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800ec6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec9:	83 e0 03             	and    $0x3,%eax
  800ecc:	85 c0                	test   %eax,%eax
  800ece:	75 41                	jne    800f11 <memset+0x5a>
  800ed0:	8b 45 10             	mov    0x10(%ebp),%eax
  800ed3:	83 e0 03             	and    $0x3,%eax
  800ed6:	85 c0                	test   %eax,%eax
  800ed8:	75 37                	jne    800f11 <memset+0x5a>
		c &= 0xFF;
  800eda:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ee1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee4:	c1 e0 18             	shl    $0x18,%eax
  800ee7:	89 c2                	mov    %eax,%edx
  800ee9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eec:	c1 e0 10             	shl    $0x10,%eax
  800eef:	09 c2                	or     %eax,%edx
  800ef1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef4:	c1 e0 08             	shl    $0x8,%eax
  800ef7:	09 d0                	or     %edx,%eax
  800ef9:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800efc:	8b 45 10             	mov    0x10(%ebp),%eax
  800eff:	c1 e8 02             	shr    $0x2,%eax
  800f02:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800f04:	8b 55 08             	mov    0x8(%ebp),%edx
  800f07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f0a:	89 d7                	mov    %edx,%edi
  800f0c:	fc                   	cld    
  800f0d:	f3 ab                	rep stos %eax,%es:(%edi)
  800f0f:	eb 0e                	jmp    800f1f <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f11:	8b 55 08             	mov    0x8(%ebp),%edx
  800f14:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f17:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f1a:	89 d7                	mov    %edx,%edi
  800f1c:	fc                   	cld    
  800f1d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800f1f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f22:	5f                   	pop    %edi
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    

00800f25 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f25:	55                   	push   %ebp
  800f26:	89 e5                	mov    %esp,%ebp
  800f28:	57                   	push   %edi
  800f29:	56                   	push   %esi
  800f2a:	53                   	push   %ebx
  800f2b:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800f2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f31:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800f34:	8b 45 08             	mov    0x8(%ebp),%eax
  800f37:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800f3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f3d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f40:	73 6d                	jae    800faf <memmove+0x8a>
  800f42:	8b 45 10             	mov    0x10(%ebp),%eax
  800f45:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f48:	01 d0                	add    %edx,%eax
  800f4a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f4d:	76 60                	jbe    800faf <memmove+0x8a>
		s += n;
  800f4f:	8b 45 10             	mov    0x10(%ebp),%eax
  800f52:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800f55:	8b 45 10             	mov    0x10(%ebp),%eax
  800f58:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f5e:	83 e0 03             	and    $0x3,%eax
  800f61:	85 c0                	test   %eax,%eax
  800f63:	75 2f                	jne    800f94 <memmove+0x6f>
  800f65:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f68:	83 e0 03             	and    $0x3,%eax
  800f6b:	85 c0                	test   %eax,%eax
  800f6d:	75 25                	jne    800f94 <memmove+0x6f>
  800f6f:	8b 45 10             	mov    0x10(%ebp),%eax
  800f72:	83 e0 03             	and    $0x3,%eax
  800f75:	85 c0                	test   %eax,%eax
  800f77:	75 1b                	jne    800f94 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f79:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f7c:	83 e8 04             	sub    $0x4,%eax
  800f7f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f82:	83 ea 04             	sub    $0x4,%edx
  800f85:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f88:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f8b:	89 c7                	mov    %eax,%edi
  800f8d:	89 d6                	mov    %edx,%esi
  800f8f:	fd                   	std    
  800f90:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f92:	eb 18                	jmp    800fac <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f94:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f97:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f9d:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800fa0:	8b 45 10             	mov    0x10(%ebp),%eax
  800fa3:	89 d7                	mov    %edx,%edi
  800fa5:	89 de                	mov    %ebx,%esi
  800fa7:	89 c1                	mov    %eax,%ecx
  800fa9:	fd                   	std    
  800faa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fac:	fc                   	cld    
  800fad:	eb 45                	jmp    800ff4 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800faf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fb2:	83 e0 03             	and    $0x3,%eax
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	75 2b                	jne    800fe4 <memmove+0xbf>
  800fb9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fbc:	83 e0 03             	and    $0x3,%eax
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	75 21                	jne    800fe4 <memmove+0xbf>
  800fc3:	8b 45 10             	mov    0x10(%ebp),%eax
  800fc6:	83 e0 03             	and    $0x3,%eax
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	75 17                	jne    800fe4 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800fcd:	8b 45 10             	mov    0x10(%ebp),%eax
  800fd0:	c1 e8 02             	shr    $0x2,%eax
  800fd3:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800fd5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fd8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fdb:	89 c7                	mov    %eax,%edi
  800fdd:	89 d6                	mov    %edx,%esi
  800fdf:	fc                   	cld    
  800fe0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fe2:	eb 10                	jmp    800ff4 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fe4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fe7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fed:	89 c7                	mov    %eax,%edi
  800fef:	89 d6                	mov    %edx,%esi
  800ff1:	fc                   	cld    
  800ff2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800ff4:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ff7:	83 c4 10             	add    $0x10,%esp
  800ffa:	5b                   	pop    %ebx
  800ffb:	5e                   	pop    %esi
  800ffc:	5f                   	pop    %edi
  800ffd:	5d                   	pop    %ebp
  800ffe:	c3                   	ret    

00800fff <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800fff:	55                   	push   %ebp
  801000:	89 e5                	mov    %esp,%ebp
  801002:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801005:	8b 45 10             	mov    0x10(%ebp),%eax
  801008:	89 44 24 08          	mov    %eax,0x8(%esp)
  80100c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80100f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801013:	8b 45 08             	mov    0x8(%ebp),%eax
  801016:	89 04 24             	mov    %eax,(%esp)
  801019:	e8 07 ff ff ff       	call   800f25 <memmove>
}
  80101e:	c9                   	leave  
  80101f:	c3                   	ret    

00801020 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  801026:	8b 45 08             	mov    0x8(%ebp),%eax
  801029:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  80102c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80102f:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  801032:	eb 30                	jmp    801064 <memcmp+0x44>
		if (*s1 != *s2)
  801034:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801037:	0f b6 10             	movzbl (%eax),%edx
  80103a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80103d:	0f b6 00             	movzbl (%eax),%eax
  801040:	38 c2                	cmp    %al,%dl
  801042:	74 18                	je     80105c <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  801044:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801047:	0f b6 00             	movzbl (%eax),%eax
  80104a:	0f b6 d0             	movzbl %al,%edx
  80104d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801050:	0f b6 00             	movzbl (%eax),%eax
  801053:	0f b6 c0             	movzbl %al,%eax
  801056:	29 c2                	sub    %eax,%edx
  801058:	89 d0                	mov    %edx,%eax
  80105a:	eb 1a                	jmp    801076 <memcmp+0x56>
		s1++, s2++;
  80105c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  801060:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801064:	8b 45 10             	mov    0x10(%ebp),%eax
  801067:	8d 50 ff             	lea    -0x1(%eax),%edx
  80106a:	89 55 10             	mov    %edx,0x10(%ebp)
  80106d:	85 c0                	test   %eax,%eax
  80106f:	75 c3                	jne    801034 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801071:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801076:	c9                   	leave  
  801077:	c3                   	ret    

00801078 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  80107e:	8b 45 10             	mov    0x10(%ebp),%eax
  801081:	8b 55 08             	mov    0x8(%ebp),%edx
  801084:	01 d0                	add    %edx,%eax
  801086:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801089:	eb 13                	jmp    80109e <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  80108b:	8b 45 08             	mov    0x8(%ebp),%eax
  80108e:	0f b6 10             	movzbl (%eax),%edx
  801091:	8b 45 0c             	mov    0xc(%ebp),%eax
  801094:	38 c2                	cmp    %al,%dl
  801096:	75 02                	jne    80109a <memfind+0x22>
			break;
  801098:	eb 0c                	jmp    8010a6 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80109a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80109e:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a1:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  8010a4:	72 e5                	jb     80108b <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  8010a6:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8010a9:	c9                   	leave  
  8010aa:	c3                   	ret    

008010ab <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  8010b1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  8010b8:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010bf:	eb 04                	jmp    8010c5 <strtol+0x1a>
		s++;
  8010c1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c8:	0f b6 00             	movzbl (%eax),%eax
  8010cb:	3c 20                	cmp    $0x20,%al
  8010cd:	74 f2                	je     8010c1 <strtol+0x16>
  8010cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d2:	0f b6 00             	movzbl (%eax),%eax
  8010d5:	3c 09                	cmp    $0x9,%al
  8010d7:	74 e8                	je     8010c1 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  8010d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010dc:	0f b6 00             	movzbl (%eax),%eax
  8010df:	3c 2b                	cmp    $0x2b,%al
  8010e1:	75 06                	jne    8010e9 <strtol+0x3e>
		s++;
  8010e3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010e7:	eb 15                	jmp    8010fe <strtol+0x53>
	else if (*s == '-')
  8010e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ec:	0f b6 00             	movzbl (%eax),%eax
  8010ef:	3c 2d                	cmp    $0x2d,%al
  8010f1:	75 0b                	jne    8010fe <strtol+0x53>
		s++, neg = 1;
  8010f3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010f7:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801102:	74 06                	je     80110a <strtol+0x5f>
  801104:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  801108:	75 24                	jne    80112e <strtol+0x83>
  80110a:	8b 45 08             	mov    0x8(%ebp),%eax
  80110d:	0f b6 00             	movzbl (%eax),%eax
  801110:	3c 30                	cmp    $0x30,%al
  801112:	75 1a                	jne    80112e <strtol+0x83>
  801114:	8b 45 08             	mov    0x8(%ebp),%eax
  801117:	83 c0 01             	add    $0x1,%eax
  80111a:	0f b6 00             	movzbl (%eax),%eax
  80111d:	3c 78                	cmp    $0x78,%al
  80111f:	75 0d                	jne    80112e <strtol+0x83>
		s += 2, base = 16;
  801121:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  801125:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  80112c:	eb 2a                	jmp    801158 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  80112e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801132:	75 17                	jne    80114b <strtol+0xa0>
  801134:	8b 45 08             	mov    0x8(%ebp),%eax
  801137:	0f b6 00             	movzbl (%eax),%eax
  80113a:	3c 30                	cmp    $0x30,%al
  80113c:	75 0d                	jne    80114b <strtol+0xa0>
		s++, base = 8;
  80113e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801142:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801149:	eb 0d                	jmp    801158 <strtol+0xad>
	else if (base == 0)
  80114b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80114f:	75 07                	jne    801158 <strtol+0xad>
		base = 10;
  801151:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801158:	8b 45 08             	mov    0x8(%ebp),%eax
  80115b:	0f b6 00             	movzbl (%eax),%eax
  80115e:	3c 2f                	cmp    $0x2f,%al
  801160:	7e 1b                	jle    80117d <strtol+0xd2>
  801162:	8b 45 08             	mov    0x8(%ebp),%eax
  801165:	0f b6 00             	movzbl (%eax),%eax
  801168:	3c 39                	cmp    $0x39,%al
  80116a:	7f 11                	jg     80117d <strtol+0xd2>
			dig = *s - '0';
  80116c:	8b 45 08             	mov    0x8(%ebp),%eax
  80116f:	0f b6 00             	movzbl (%eax),%eax
  801172:	0f be c0             	movsbl %al,%eax
  801175:	83 e8 30             	sub    $0x30,%eax
  801178:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80117b:	eb 48                	jmp    8011c5 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  80117d:	8b 45 08             	mov    0x8(%ebp),%eax
  801180:	0f b6 00             	movzbl (%eax),%eax
  801183:	3c 60                	cmp    $0x60,%al
  801185:	7e 1b                	jle    8011a2 <strtol+0xf7>
  801187:	8b 45 08             	mov    0x8(%ebp),%eax
  80118a:	0f b6 00             	movzbl (%eax),%eax
  80118d:	3c 7a                	cmp    $0x7a,%al
  80118f:	7f 11                	jg     8011a2 <strtol+0xf7>
			dig = *s - 'a' + 10;
  801191:	8b 45 08             	mov    0x8(%ebp),%eax
  801194:	0f b6 00             	movzbl (%eax),%eax
  801197:	0f be c0             	movsbl %al,%eax
  80119a:	83 e8 57             	sub    $0x57,%eax
  80119d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8011a0:	eb 23                	jmp    8011c5 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  8011a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a5:	0f b6 00             	movzbl (%eax),%eax
  8011a8:	3c 40                	cmp    $0x40,%al
  8011aa:	7e 3d                	jle    8011e9 <strtol+0x13e>
  8011ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8011af:	0f b6 00             	movzbl (%eax),%eax
  8011b2:	3c 5a                	cmp    $0x5a,%al
  8011b4:	7f 33                	jg     8011e9 <strtol+0x13e>
			dig = *s - 'A' + 10;
  8011b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b9:	0f b6 00             	movzbl (%eax),%eax
  8011bc:	0f be c0             	movsbl %al,%eax
  8011bf:	83 e8 37             	sub    $0x37,%eax
  8011c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  8011c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011c8:	3b 45 10             	cmp    0x10(%ebp),%eax
  8011cb:	7c 02                	jl     8011cf <strtol+0x124>
			break;
  8011cd:	eb 1a                	jmp    8011e9 <strtol+0x13e>
		s++, val = (val * base) + dig;
  8011cf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8011d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011d6:	0f af 45 10          	imul   0x10(%ebp),%eax
  8011da:	89 c2                	mov    %eax,%edx
  8011dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011df:	01 d0                	add    %edx,%eax
  8011e1:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  8011e4:	e9 6f ff ff ff       	jmp    801158 <strtol+0xad>

	if (endptr)
  8011e9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011ed:	74 08                	je     8011f7 <strtol+0x14c>
		*endptr = (char *) s;
  8011ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f5:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8011f7:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8011fb:	74 07                	je     801204 <strtol+0x159>
  8011fd:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801200:	f7 d8                	neg    %eax
  801202:	eb 03                	jmp    801207 <strtol+0x15c>
  801204:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  801207:	c9                   	leave  
  801208:	c3                   	ret    
  801209:	66 90                	xchg   %ax,%ax
  80120b:	66 90                	xchg   %ax,%ax
  80120d:	66 90                	xchg   %ax,%ax
  80120f:	90                   	nop

00801210 <__udivdi3>:
  801210:	55                   	push   %ebp
  801211:	57                   	push   %edi
  801212:	56                   	push   %esi
  801213:	83 ec 0c             	sub    $0xc,%esp
  801216:	8b 44 24 28          	mov    0x28(%esp),%eax
  80121a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80121e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801222:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801226:	85 c0                	test   %eax,%eax
  801228:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80122c:	89 ea                	mov    %ebp,%edx
  80122e:	89 0c 24             	mov    %ecx,(%esp)
  801231:	75 2d                	jne    801260 <__udivdi3+0x50>
  801233:	39 e9                	cmp    %ebp,%ecx
  801235:	77 61                	ja     801298 <__udivdi3+0x88>
  801237:	85 c9                	test   %ecx,%ecx
  801239:	89 ce                	mov    %ecx,%esi
  80123b:	75 0b                	jne    801248 <__udivdi3+0x38>
  80123d:	b8 01 00 00 00       	mov    $0x1,%eax
  801242:	31 d2                	xor    %edx,%edx
  801244:	f7 f1                	div    %ecx
  801246:	89 c6                	mov    %eax,%esi
  801248:	31 d2                	xor    %edx,%edx
  80124a:	89 e8                	mov    %ebp,%eax
  80124c:	f7 f6                	div    %esi
  80124e:	89 c5                	mov    %eax,%ebp
  801250:	89 f8                	mov    %edi,%eax
  801252:	f7 f6                	div    %esi
  801254:	89 ea                	mov    %ebp,%edx
  801256:	83 c4 0c             	add    $0xc,%esp
  801259:	5e                   	pop    %esi
  80125a:	5f                   	pop    %edi
  80125b:	5d                   	pop    %ebp
  80125c:	c3                   	ret    
  80125d:	8d 76 00             	lea    0x0(%esi),%esi
  801260:	39 e8                	cmp    %ebp,%eax
  801262:	77 24                	ja     801288 <__udivdi3+0x78>
  801264:	0f bd e8             	bsr    %eax,%ebp
  801267:	83 f5 1f             	xor    $0x1f,%ebp
  80126a:	75 3c                	jne    8012a8 <__udivdi3+0x98>
  80126c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801270:	39 34 24             	cmp    %esi,(%esp)
  801273:	0f 86 9f 00 00 00    	jbe    801318 <__udivdi3+0x108>
  801279:	39 d0                	cmp    %edx,%eax
  80127b:	0f 82 97 00 00 00    	jb     801318 <__udivdi3+0x108>
  801281:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801288:	31 d2                	xor    %edx,%edx
  80128a:	31 c0                	xor    %eax,%eax
  80128c:	83 c4 0c             	add    $0xc,%esp
  80128f:	5e                   	pop    %esi
  801290:	5f                   	pop    %edi
  801291:	5d                   	pop    %ebp
  801292:	c3                   	ret    
  801293:	90                   	nop
  801294:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801298:	89 f8                	mov    %edi,%eax
  80129a:	f7 f1                	div    %ecx
  80129c:	31 d2                	xor    %edx,%edx
  80129e:	83 c4 0c             	add    $0xc,%esp
  8012a1:	5e                   	pop    %esi
  8012a2:	5f                   	pop    %edi
  8012a3:	5d                   	pop    %ebp
  8012a4:	c3                   	ret    
  8012a5:	8d 76 00             	lea    0x0(%esi),%esi
  8012a8:	89 e9                	mov    %ebp,%ecx
  8012aa:	8b 3c 24             	mov    (%esp),%edi
  8012ad:	d3 e0                	shl    %cl,%eax
  8012af:	89 c6                	mov    %eax,%esi
  8012b1:	b8 20 00 00 00       	mov    $0x20,%eax
  8012b6:	29 e8                	sub    %ebp,%eax
  8012b8:	89 c1                	mov    %eax,%ecx
  8012ba:	d3 ef                	shr    %cl,%edi
  8012bc:	89 e9                	mov    %ebp,%ecx
  8012be:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8012c2:	8b 3c 24             	mov    (%esp),%edi
  8012c5:	09 74 24 08          	or     %esi,0x8(%esp)
  8012c9:	89 d6                	mov    %edx,%esi
  8012cb:	d3 e7                	shl    %cl,%edi
  8012cd:	89 c1                	mov    %eax,%ecx
  8012cf:	89 3c 24             	mov    %edi,(%esp)
  8012d2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012d6:	d3 ee                	shr    %cl,%esi
  8012d8:	89 e9                	mov    %ebp,%ecx
  8012da:	d3 e2                	shl    %cl,%edx
  8012dc:	89 c1                	mov    %eax,%ecx
  8012de:	d3 ef                	shr    %cl,%edi
  8012e0:	09 d7                	or     %edx,%edi
  8012e2:	89 f2                	mov    %esi,%edx
  8012e4:	89 f8                	mov    %edi,%eax
  8012e6:	f7 74 24 08          	divl   0x8(%esp)
  8012ea:	89 d6                	mov    %edx,%esi
  8012ec:	89 c7                	mov    %eax,%edi
  8012ee:	f7 24 24             	mull   (%esp)
  8012f1:	39 d6                	cmp    %edx,%esi
  8012f3:	89 14 24             	mov    %edx,(%esp)
  8012f6:	72 30                	jb     801328 <__udivdi3+0x118>
  8012f8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012fc:	89 e9                	mov    %ebp,%ecx
  8012fe:	d3 e2                	shl    %cl,%edx
  801300:	39 c2                	cmp    %eax,%edx
  801302:	73 05                	jae    801309 <__udivdi3+0xf9>
  801304:	3b 34 24             	cmp    (%esp),%esi
  801307:	74 1f                	je     801328 <__udivdi3+0x118>
  801309:	89 f8                	mov    %edi,%eax
  80130b:	31 d2                	xor    %edx,%edx
  80130d:	e9 7a ff ff ff       	jmp    80128c <__udivdi3+0x7c>
  801312:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801318:	31 d2                	xor    %edx,%edx
  80131a:	b8 01 00 00 00       	mov    $0x1,%eax
  80131f:	e9 68 ff ff ff       	jmp    80128c <__udivdi3+0x7c>
  801324:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801328:	8d 47 ff             	lea    -0x1(%edi),%eax
  80132b:	31 d2                	xor    %edx,%edx
  80132d:	83 c4 0c             	add    $0xc,%esp
  801330:	5e                   	pop    %esi
  801331:	5f                   	pop    %edi
  801332:	5d                   	pop    %ebp
  801333:	c3                   	ret    
  801334:	66 90                	xchg   %ax,%ax
  801336:	66 90                	xchg   %ax,%ax
  801338:	66 90                	xchg   %ax,%ax
  80133a:	66 90                	xchg   %ax,%ax
  80133c:	66 90                	xchg   %ax,%ax
  80133e:	66 90                	xchg   %ax,%ax

00801340 <__umoddi3>:
  801340:	55                   	push   %ebp
  801341:	57                   	push   %edi
  801342:	56                   	push   %esi
  801343:	83 ec 14             	sub    $0x14,%esp
  801346:	8b 44 24 28          	mov    0x28(%esp),%eax
  80134a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80134e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801352:	89 c7                	mov    %eax,%edi
  801354:	89 44 24 04          	mov    %eax,0x4(%esp)
  801358:	8b 44 24 30          	mov    0x30(%esp),%eax
  80135c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801360:	89 34 24             	mov    %esi,(%esp)
  801363:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801367:	85 c0                	test   %eax,%eax
  801369:	89 c2                	mov    %eax,%edx
  80136b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80136f:	75 17                	jne    801388 <__umoddi3+0x48>
  801371:	39 fe                	cmp    %edi,%esi
  801373:	76 4b                	jbe    8013c0 <__umoddi3+0x80>
  801375:	89 c8                	mov    %ecx,%eax
  801377:	89 fa                	mov    %edi,%edx
  801379:	f7 f6                	div    %esi
  80137b:	89 d0                	mov    %edx,%eax
  80137d:	31 d2                	xor    %edx,%edx
  80137f:	83 c4 14             	add    $0x14,%esp
  801382:	5e                   	pop    %esi
  801383:	5f                   	pop    %edi
  801384:	5d                   	pop    %ebp
  801385:	c3                   	ret    
  801386:	66 90                	xchg   %ax,%ax
  801388:	39 f8                	cmp    %edi,%eax
  80138a:	77 54                	ja     8013e0 <__umoddi3+0xa0>
  80138c:	0f bd e8             	bsr    %eax,%ebp
  80138f:	83 f5 1f             	xor    $0x1f,%ebp
  801392:	75 5c                	jne    8013f0 <__umoddi3+0xb0>
  801394:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801398:	39 3c 24             	cmp    %edi,(%esp)
  80139b:	0f 87 e7 00 00 00    	ja     801488 <__umoddi3+0x148>
  8013a1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013a5:	29 f1                	sub    %esi,%ecx
  8013a7:	19 c7                	sbb    %eax,%edi
  8013a9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013ad:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013b1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8013b5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8013b9:	83 c4 14             	add    $0x14,%esp
  8013bc:	5e                   	pop    %esi
  8013bd:	5f                   	pop    %edi
  8013be:	5d                   	pop    %ebp
  8013bf:	c3                   	ret    
  8013c0:	85 f6                	test   %esi,%esi
  8013c2:	89 f5                	mov    %esi,%ebp
  8013c4:	75 0b                	jne    8013d1 <__umoddi3+0x91>
  8013c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013cb:	31 d2                	xor    %edx,%edx
  8013cd:	f7 f6                	div    %esi
  8013cf:	89 c5                	mov    %eax,%ebp
  8013d1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8013d5:	31 d2                	xor    %edx,%edx
  8013d7:	f7 f5                	div    %ebp
  8013d9:	89 c8                	mov    %ecx,%eax
  8013db:	f7 f5                	div    %ebp
  8013dd:	eb 9c                	jmp    80137b <__umoddi3+0x3b>
  8013df:	90                   	nop
  8013e0:	89 c8                	mov    %ecx,%eax
  8013e2:	89 fa                	mov    %edi,%edx
  8013e4:	83 c4 14             	add    $0x14,%esp
  8013e7:	5e                   	pop    %esi
  8013e8:	5f                   	pop    %edi
  8013e9:	5d                   	pop    %ebp
  8013ea:	c3                   	ret    
  8013eb:	90                   	nop
  8013ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013f0:	8b 04 24             	mov    (%esp),%eax
  8013f3:	be 20 00 00 00       	mov    $0x20,%esi
  8013f8:	89 e9                	mov    %ebp,%ecx
  8013fa:	29 ee                	sub    %ebp,%esi
  8013fc:	d3 e2                	shl    %cl,%edx
  8013fe:	89 f1                	mov    %esi,%ecx
  801400:	d3 e8                	shr    %cl,%eax
  801402:	89 e9                	mov    %ebp,%ecx
  801404:	89 44 24 04          	mov    %eax,0x4(%esp)
  801408:	8b 04 24             	mov    (%esp),%eax
  80140b:	09 54 24 04          	or     %edx,0x4(%esp)
  80140f:	89 fa                	mov    %edi,%edx
  801411:	d3 e0                	shl    %cl,%eax
  801413:	89 f1                	mov    %esi,%ecx
  801415:	89 44 24 08          	mov    %eax,0x8(%esp)
  801419:	8b 44 24 10          	mov    0x10(%esp),%eax
  80141d:	d3 ea                	shr    %cl,%edx
  80141f:	89 e9                	mov    %ebp,%ecx
  801421:	d3 e7                	shl    %cl,%edi
  801423:	89 f1                	mov    %esi,%ecx
  801425:	d3 e8                	shr    %cl,%eax
  801427:	89 e9                	mov    %ebp,%ecx
  801429:	09 f8                	or     %edi,%eax
  80142b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80142f:	f7 74 24 04          	divl   0x4(%esp)
  801433:	d3 e7                	shl    %cl,%edi
  801435:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801439:	89 d7                	mov    %edx,%edi
  80143b:	f7 64 24 08          	mull   0x8(%esp)
  80143f:	39 d7                	cmp    %edx,%edi
  801441:	89 c1                	mov    %eax,%ecx
  801443:	89 14 24             	mov    %edx,(%esp)
  801446:	72 2c                	jb     801474 <__umoddi3+0x134>
  801448:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80144c:	72 22                	jb     801470 <__umoddi3+0x130>
  80144e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801452:	29 c8                	sub    %ecx,%eax
  801454:	19 d7                	sbb    %edx,%edi
  801456:	89 e9                	mov    %ebp,%ecx
  801458:	89 fa                	mov    %edi,%edx
  80145a:	d3 e8                	shr    %cl,%eax
  80145c:	89 f1                	mov    %esi,%ecx
  80145e:	d3 e2                	shl    %cl,%edx
  801460:	89 e9                	mov    %ebp,%ecx
  801462:	d3 ef                	shr    %cl,%edi
  801464:	09 d0                	or     %edx,%eax
  801466:	89 fa                	mov    %edi,%edx
  801468:	83 c4 14             	add    $0x14,%esp
  80146b:	5e                   	pop    %esi
  80146c:	5f                   	pop    %edi
  80146d:	5d                   	pop    %ebp
  80146e:	c3                   	ret    
  80146f:	90                   	nop
  801470:	39 d7                	cmp    %edx,%edi
  801472:	75 da                	jne    80144e <__umoddi3+0x10e>
  801474:	8b 14 24             	mov    (%esp),%edx
  801477:	89 c1                	mov    %eax,%ecx
  801479:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80147d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801481:	eb cb                	jmp    80144e <__umoddi3+0x10e>
  801483:	90                   	nop
  801484:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801488:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80148c:	0f 82 0f ff ff ff    	jb     8013a1 <__umoddi3+0x61>
  801492:	e9 1a ff ff ff       	jmp    8013b1 <__umoddi3+0x71>
