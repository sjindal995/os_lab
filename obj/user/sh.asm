
obj/user/sh:     file format elf32-i386


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
  80002c:	e8 39 00 00 00       	call   80006a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 28             	sub    $0x28,%esp
	char* buf;
	while(1){
		buf = readline("U> ");
  800039:	c7 04 24 c0 1a 80 00 	movl   $0x801ac0,(%esp)
  800040:	e8 88 00 00 00       	call   8000cd <readline>
  800045:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if(buf == NULL)
  800048:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80004c:	75 02                	jne    800050 <umain+0x1d>
			break;
  80004e:	eb 18                	jmp    800068 <umain+0x35>
		if(fork()==0){
  800050:	e8 0b 08 00 00       	call   800860 <fork>
  800055:	85 c0                	test   %eax,%eax
  800057:	75 0d                	jne    800066 <umain+0x33>
			sys_exec(buf);
  800059:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80005c:	89 04 24             	mov    %eax,(%esp)
  80005f:	e8 d8 04 00 00       	call   80053c <sys_exec>
		}
	}
  800064:	eb d3                	jmp    800039 <umain+0x6>
  800066:	eb d1                	jmp    800039 <umain+0x6>
}
  800068:	c9                   	leave  
  800069:	c3                   	ret    

0080006a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80006a:	55                   	push   %ebp
  80006b:	89 e5                	mov    %esp,%ebp
  80006d:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800070:	e8 6f 02 00 00       	call   8002e4 <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	c1 e0 02             	shl    $0x2,%eax
  80007d:	89 c2                	mov    %eax,%edx
  80007f:	c1 e2 05             	shl    $0x5,%edx
  800082:	29 c2                	sub    %eax,%edx
  800084:	89 d0                	mov    %edx,%eax
  800086:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008b:	a3 20 24 80 00       	mov    %eax,0x802420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800090:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800094:	7e 0a                	jle    8000a0 <libmain+0x36>
		binaryname = argv[0];
  800096:	8b 45 0c             	mov    0xc(%ebp),%eax
  800099:	8b 00                	mov    (%eax),%eax
  80009b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8000aa:	89 04 24             	mov    %eax,(%esp)
  8000ad:	e8 81 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b2:	e8 02 00 00 00       	call   8000b9 <exit>
}
  8000b7:	c9                   	leave  
  8000b8:	c3                   	ret    

008000b9 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c6:	e8 d6 01 00 00       	call   8002a1 <sys_env_destroy>
}
  8000cb:	c9                   	leave  
  8000cc:	c3                   	ret    

008000cd <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  8000cd:	55                   	push   %ebp
  8000ce:	89 e5                	mov    %esp,%ebp
  8000d0:	83 ec 28             	sub    $0x28,%esp
	int i, c, echoing;

	if (prompt != NULL)
  8000d3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000d7:	74 13                	je     8000ec <readline+0x1f>
		cprintf("%s", prompt);
  8000d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8000dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000e0:	c7 04 24 ce 1a 80 00 	movl   $0x801ace,(%esp)
  8000e7:	e8 84 0a 00 00       	call   800b70 <cprintf>

	i = 0;
  8000ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	// echoing = iscons(0);
	echoing = 1;
  8000f3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	while (1) {
		c = getchar();
  8000fa:	e8 36 09 00 00       	call   800a35 <getchar>
  8000ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if (c < 0) {
  800102:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  800106:	79 1d                	jns    800125 <readline+0x58>
			cprintf("read error: %e\n", c);
  800108:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80010b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80010f:	c7 04 24 d1 1a 80 00 	movl   $0x801ad1,(%esp)
  800116:	e8 55 0a 00 00       	call   800b70 <cprintf>
			return NULL;
  80011b:	b8 00 00 00 00       	mov    $0x0,%eax
  800120:	e9 93 00 00 00       	jmp    8001b8 <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  800125:	83 7d ec 08          	cmpl   $0x8,-0x14(%ebp)
  800129:	74 06                	je     800131 <readline+0x64>
  80012b:	83 7d ec 7f          	cmpl   $0x7f,-0x14(%ebp)
  80012f:	75 1e                	jne    80014f <readline+0x82>
  800131:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  800135:	7e 18                	jle    80014f <readline+0x82>
			if (echoing)
  800137:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80013b:	74 0c                	je     800149 <readline+0x7c>
				cputchar('\b');
  80013d:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800144:	e8 cb 08 00 00       	call   800a14 <cputchar>
			i--;
  800149:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  80014d:	eb 64                	jmp    8001b3 <readline+0xe6>
		} else if (c >= ' ' && i < BUFLEN-1) {
  80014f:	83 7d ec 1f          	cmpl   $0x1f,-0x14(%ebp)
  800153:	7e 2e                	jle    800183 <readline+0xb6>
  800155:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  80015c:	7f 25                	jg     800183 <readline+0xb6>
			if (echoing)
  80015e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800162:	74 0b                	je     80016f <readline+0xa2>
				cputchar(c);
  800164:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800167:	89 04 24             	mov    %eax,(%esp)
  80016a:	e8 a5 08 00 00       	call   800a14 <cputchar>
			buf[i++] = c;
  80016f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800172:	8d 50 01             	lea    0x1(%eax),%edx
  800175:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800178:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80017b:	88 90 20 20 80 00    	mov    %dl,0x802020(%eax)
  800181:	eb 30                	jmp    8001b3 <readline+0xe6>
		} else if (c == '\n' || c == '\r') {
  800183:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
  800187:	74 06                	je     80018f <readline+0xc2>
  800189:	83 7d ec 0d          	cmpl   $0xd,-0x14(%ebp)
  80018d:	75 24                	jne    8001b3 <readline+0xe6>
			if (echoing)
  80018f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800193:	74 0c                	je     8001a1 <readline+0xd4>
				cputchar('\n');
  800195:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80019c:	e8 73 08 00 00       	call   800a14 <cputchar>
			buf[i] = 0;
  8001a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001a4:	05 20 20 80 00       	add    $0x802020,%eax
  8001a9:	c6 00 00             	movb   $0x0,(%eax)
			return buf;
  8001ac:	b8 20 20 80 00       	mov    $0x802020,%eax
  8001b1:	eb 05                	jmp    8001b8 <readline+0xeb>
		}
	}
  8001b3:	e9 42 ff ff ff       	jmp    8000fa <readline+0x2d>
}
  8001b8:	c9                   	leave  
  8001b9:	c3                   	ret    

008001ba <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8001ba:	55                   	push   %ebp
  8001bb:	89 e5                	mov    %esp,%ebp
  8001bd:	57                   	push   %edi
  8001be:	56                   	push   %esi
  8001bf:	53                   	push   %ebx
  8001c0:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c6:	8b 55 10             	mov    0x10(%ebp),%edx
  8001c9:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8001cc:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8001cf:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  8001d2:	8b 75 20             	mov    0x20(%ebp),%esi
  8001d5:	cd 30                	int    $0x30
  8001d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001da:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8001de:	74 30                	je     800210 <syscall+0x56>
  8001e0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8001e4:	7e 2a                	jle    800210 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001e9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001f4:	c7 44 24 08 e1 1a 80 	movl   $0x801ae1,0x8(%esp)
  8001fb:	00 
  8001fc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800203:	00 
  800204:	c7 04 24 fe 1a 80 00 	movl   $0x801afe,(%esp)
  80020b:	e8 45 08 00 00       	call   800a55 <_panic>

	return ret;
  800210:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800213:	83 c4 3c             	add    $0x3c,%esp
  800216:	5b                   	pop    %ebx
  800217:	5e                   	pop    %esi
  800218:	5f                   	pop    %edi
  800219:	5d                   	pop    %ebp
  80021a:	c3                   	ret    

0080021b <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800221:	8b 45 08             	mov    0x8(%ebp),%eax
  800224:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80022b:	00 
  80022c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800233:	00 
  800234:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80023b:	00 
  80023c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800243:	89 44 24 08          	mov    %eax,0x8(%esp)
  800247:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80024e:	00 
  80024f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800256:	e8 5f ff ff ff       	call   8001ba <syscall>
}
  80025b:	c9                   	leave  
  80025c:	c3                   	ret    

0080025d <sys_cgetc>:

int
sys_cgetc(void)
{
  80025d:	55                   	push   %ebp
  80025e:	89 e5                	mov    %esp,%ebp
  800260:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800263:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80026a:	00 
  80026b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800272:	00 
  800273:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80027a:	00 
  80027b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800282:	00 
  800283:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80028a:	00 
  80028b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800292:	00 
  800293:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80029a:	e8 1b ff ff ff       	call   8001ba <syscall>
}
  80029f:	c9                   	leave  
  8002a0:	c3                   	ret    

008002a1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8002a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002aa:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8002b1:	00 
  8002b2:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8002b9:	00 
  8002ba:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8002c1:	00 
  8002c2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002c9:	00 
  8002ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ce:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002d5:	00 
  8002d6:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8002dd:	e8 d8 fe ff ff       	call   8001ba <syscall>
}
  8002e2:	c9                   	leave  
  8002e3:	c3                   	ret    

008002e4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8002ea:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8002f1:	00 
  8002f2:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8002f9:	00 
  8002fa:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800301:	00 
  800302:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800309:	00 
  80030a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800311:	00 
  800312:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800319:	00 
  80031a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800321:	e8 94 fe ff ff       	call   8001ba <syscall>
}
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <sys_yield>:

void
sys_yield(void)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80032e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800335:	00 
  800336:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80033d:	00 
  80033e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800345:	00 
  800346:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80034d:	00 
  80034e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800355:	00 
  800356:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80035d:	00 
  80035e:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800365:	e8 50 fe ff ff       	call   8001ba <syscall>
}
  80036a:	c9                   	leave  
  80036b:	c3                   	ret    

0080036c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800372:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800375:	8b 55 0c             	mov    0xc(%ebp),%edx
  800378:	8b 45 08             	mov    0x8(%ebp),%eax
  80037b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800382:	00 
  800383:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80038a:	00 
  80038b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80038f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800393:	89 44 24 08          	mov    %eax,0x8(%esp)
  800397:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80039e:	00 
  80039f:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  8003a6:	e8 0f fe ff ff       	call   8001ba <syscall>
}
  8003ab:	c9                   	leave  
  8003ac:	c3                   	ret    

008003ad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8003ad:	55                   	push   %ebp
  8003ae:	89 e5                	mov    %esp,%ebp
  8003b0:	56                   	push   %esi
  8003b1:	53                   	push   %ebx
  8003b2:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8003b5:	8b 75 18             	mov    0x18(%ebp),%esi
  8003b8:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003bb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c4:	89 74 24 18          	mov    %esi,0x18(%esp)
  8003c8:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8003cc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8003d0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003d8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8003df:	00 
  8003e0:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8003e7:	e8 ce fd ff ff       	call   8001ba <syscall>
}
  8003ec:	83 c4 20             	add    $0x20,%esp
  8003ef:	5b                   	pop    %ebx
  8003f0:	5e                   	pop    %esi
  8003f1:	5d                   	pop    %ebp
  8003f2:	c3                   	ret    

008003f3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8003f3:	55                   	push   %ebp
  8003f4:	89 e5                	mov    %esp,%ebp
  8003f6:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8003f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ff:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800406:	00 
  800407:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80040e:	00 
  80040f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800416:	00 
  800417:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80041b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80041f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800426:	00 
  800427:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  80042e:	e8 87 fd ff ff       	call   8001ba <syscall>
}
  800433:	c9                   	leave  
  800434:	c3                   	ret    

00800435 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800435:	55                   	push   %ebp
  800436:	89 e5                	mov    %esp,%ebp
  800438:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80043b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043e:	8b 45 08             	mov    0x8(%ebp),%eax
  800441:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800448:	00 
  800449:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800450:	00 
  800451:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800458:	00 
  800459:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80045d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800461:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800468:	00 
  800469:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800470:	e8 45 fd ff ff       	call   8001ba <syscall>
}
  800475:	c9                   	leave  
  800476:	c3                   	ret    

00800477 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800477:	55                   	push   %ebp
  800478:	89 e5                	mov    %esp,%ebp
  80047a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80047d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800480:	8b 45 08             	mov    0x8(%ebp),%eax
  800483:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80048a:	00 
  80048b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800492:	00 
  800493:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80049a:	00 
  80049b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80049f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004a3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8004aa:	00 
  8004ab:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8004b2:	e8 03 fd ff ff       	call   8001ba <syscall>
}
  8004b7:	c9                   	leave  
  8004b8:	c3                   	ret    

008004b9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8004b9:	55                   	push   %ebp
  8004ba:	89 e5                	mov    %esp,%ebp
  8004bc:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8004bf:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004c2:	8b 55 10             	mov    0x10(%ebp),%edx
  8004c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c8:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8004cf:	00 
  8004d0:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8004d4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8004d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004db:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004ea:	00 
  8004eb:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8004f2:	e8 c3 fc ff ff       	call   8001ba <syscall>
}
  8004f7:	c9                   	leave  
  8004f8:	c3                   	ret    

008004f9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8004f9:	55                   	push   %ebp
  8004fa:	89 e5                	mov    %esp,%ebp
  8004fc:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8004ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800502:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800509:	00 
  80050a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800511:	00 
  800512:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800519:	00 
  80051a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800521:	00 
  800522:	89 44 24 08          	mov    %eax,0x8(%esp)
  800526:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80052d:	00 
  80052e:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  800535:	e8 80 fc ff ff       	call   8001ba <syscall>
}
  80053a:	c9                   	leave  
  80053b:	c3                   	ret    

0080053c <sys_exec>:

void sys_exec(char* buf){
  80053c:	55                   	push   %ebp
  80053d:	89 e5                	mov    %esp,%ebp
  80053f:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_exec, 0, (uint32_t)buf, 0 , 0, 0, 0);
  800542:	8b 45 08             	mov    0x8(%ebp),%eax
  800545:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80054c:	00 
  80054d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800554:	00 
  800555:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80055c:	00 
  80055d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800564:	00 
  800565:	89 44 24 08          	mov    %eax,0x8(%esp)
  800569:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800570:	00 
  800571:	c7 04 24 0d 00 00 00 	movl   $0xd,(%esp)
  800578:	e8 3d fc ff ff       	call   8001ba <syscall>
}
  80057d:	c9                   	leave  
  80057e:	c3                   	ret    

0080057f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80057f:	55                   	push   %ebp
  800580:	89 e5                	mov    %esp,%ebp
  800582:	83 ec 48             	sub    $0x48,%esp
	void *addr = (void *) utf->utf_fault_va;
  800585:	8b 45 08             	mov    0x8(%ebp),%eax
  800588:	8b 00                	mov    (%eax),%eax
  80058a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32_t err = utf->utf_err;
  80058d:	8b 45 08             	mov    0x8(%ebp),%eax
  800590:	8b 40 04             	mov    0x4(%eax),%eax
  800593:	89 45 f0             	mov    %eax,-0x10(%ebp)
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).
	// LAB 4: Your code here.
	if(!(err & FEC_WR)){
  800596:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800599:	83 e0 02             	and    $0x2,%eax
  80059c:	85 c0                	test   %eax,%eax
  80059e:	75 23                	jne    8005c3 <pgfault+0x44>
		panic("error pgfault: faulting access not a write: %d\n",err);
  8005a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005a7:	c7 44 24 08 0c 1b 80 	movl   $0x801b0c,0x8(%esp)
  8005ae:	00 
  8005af:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  8005b6:	00 
  8005b7:	c7 04 24 3c 1b 80 00 	movl   $0x801b3c,(%esp)
  8005be:	e8 92 04 00 00       	call   800a55 <_panic>
	}
	uint32_t page_num = PGNUM((uint32_t)addr);
  8005c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005c6:	c1 e8 0c             	shr    $0xc,%eax
  8005c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(!(uvpt[page_num] & PTE_COW)){
  8005cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8005cf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005d6:	25 00 08 00 00       	and    $0x800,%eax
  8005db:	85 c0                	test   %eax,%eax
  8005dd:	75 1c                	jne    8005fb <pgfault+0x7c>
		panic("error pgfault: faulting access on a non copy-on-write page\n");
  8005df:	c7 44 24 08 48 1b 80 	movl   $0x801b48,0x8(%esp)
  8005e6:	00 
  8005e7:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8005ee:	00 
  8005ef:	c7 04 24 3c 1b 80 00 	movl   $0x801b3c,(%esp)
  8005f6:	e8 5a 04 00 00       	call   800a55 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	if((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0){
  8005fb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800602:	00 
  800603:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80060a:	00 
  80060b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800612:	e8 55 fd ff ff       	call   80036c <sys_page_alloc>
  800617:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80061a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  80061e:	79 23                	jns    800643 <pgfault+0xc4>
		panic("error pgfault: cannot allocate new page at PFTEMP: %e\n", r);
  800620:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800623:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800627:	c7 44 24 08 84 1b 80 	movl   $0x801b84,0x8(%esp)
  80062e:	00 
  80062f:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800636:	00 
  800637:	c7 04 24 3c 1b 80 00 	movl   $0x801b3c,(%esp)
  80063e:	e8 12 04 00 00       	call   800a55 <_panic>
	}

	memcpy(PFTEMP, ROUNDDOWN(addr, PGSIZE), PGSIZE);
  800643:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800646:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800649:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80064c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800651:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800658:	00 
  800659:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800664:	e8 08 0f 00 00       	call   801571 <memcpy>

	if((r = sys_page_map(0, PFTEMP, 0, ROUNDDOWN(addr, PGSIZE), PTE_P | PTE_U | PTE_W)) < 0){
  800669:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80066c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80066f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800672:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800677:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80067e:	00 
  80067f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800683:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80068a:	00 
  80068b:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800692:	00 
  800693:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80069a:	e8 0e fd ff ff       	call   8003ad <sys_page_map>
  80069f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8006a2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  8006a6:	79 23                	jns    8006cb <pgfault+0x14c>
		panic("error pgfault: mapping new page to old page: %e\n", r);
  8006a8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006af:	c7 44 24 08 bc 1b 80 	movl   $0x801bbc,0x8(%esp)
  8006b6:	00 
  8006b7:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  8006be:	00 
  8006bf:	c7 04 24 3c 1b 80 00 	movl   $0x801b3c,(%esp)
  8006c6:	e8 8a 03 00 00       	call   800a55 <_panic>
	}

	// panic("pgfault not implemented");
}
  8006cb:	c9                   	leave  
  8006cc:	c3                   	ret    

008006cd <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  8006cd:	55                   	push   %ebp
  8006ce:	89 e5                	mov    %esp,%ebp
  8006d0:	56                   	push   %esi
  8006d1:	53                   	push   %ebx
  8006d2:	83 ec 30             	sub    $0x30,%esp
	int r;

	// LAB 4: Your code here.
	uint32_t perm = PTE_P | PTE_COW;
  8006d5:	c7 45 f4 01 08 00 00 	movl   $0x801,-0xc(%ebp)
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
  8006dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006df:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8006e6:	25 00 08 00 00       	and    $0x800,%eax
  8006eb:	85 c0                	test   %eax,%eax
  8006ed:	75 15                	jne    800704 <duppage+0x37>
  8006ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8006f9:	83 e0 02             	and    $0x2,%eax
  8006fc:	85 c0                	test   %eax,%eax
  8006fe:	0f 84 e0 00 00 00    	je     8007e4 <duppage+0x117>
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
  800704:	8b 45 0c             	mov    0xc(%ebp),%eax
  800707:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80070e:	83 e0 04             	and    $0x4,%eax
  800711:	85 c0                	test   %eax,%eax
  800713:	74 04                	je     800719 <duppage+0x4c>
  800715:	83 4d f4 04          	orl    $0x4,-0xc(%ebp)
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
  800719:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80071c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80071f:	c1 e0 0c             	shl    $0xc,%eax
  800722:	89 c1                	mov    %eax,%ecx
  800724:	8b 45 0c             	mov    0xc(%ebp),%eax
  800727:	c1 e0 0c             	shl    $0xc,%eax
  80072a:	89 c2                	mov    %eax,%edx
  80072c:	a1 20 24 80 00       	mov    0x802420,%eax
  800731:	8b 40 48             	mov    0x48(%eax),%eax
  800734:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800738:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80073c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80073f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800743:	89 54 24 04          	mov    %edx,0x4(%esp)
  800747:	89 04 24             	mov    %eax,(%esp)
  80074a:	e8 5e fc ff ff       	call   8003ad <sys_page_map>
  80074f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800752:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800756:	79 23                	jns    80077b <duppage+0xae>
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
  800758:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80075b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80075f:	c7 44 24 08 f0 1b 80 	movl   $0x801bf0,0x8(%esp)
  800766:	00 
  800767:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  80076e:	00 
  80076f:	c7 04 24 3c 1b 80 00 	movl   $0x801b3c,(%esp)
  800776:	e8 da 02 00 00       	call   800a55 <_panic>
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  80077b:	8b 75 f4             	mov    -0xc(%ebp),%esi
  80077e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800781:	c1 e0 0c             	shl    $0xc,%eax
  800784:	89 c3                	mov    %eax,%ebx
  800786:	a1 20 24 80 00       	mov    0x802420,%eax
  80078b:	8b 48 48             	mov    0x48(%eax),%ecx
  80078e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800791:	c1 e0 0c             	shl    $0xc,%eax
  800794:	89 c2                	mov    %eax,%edx
  800796:	a1 20 24 80 00       	mov    0x802420,%eax
  80079b:	8b 40 48             	mov    0x48(%eax),%eax
  80079e:	89 74 24 10          	mov    %esi,0x10(%esp)
  8007a2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8007a6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007ae:	89 04 24             	mov    %eax,(%esp)
  8007b1:	e8 f7 fb ff ff       	call   8003ad <sys_page_map>
  8007b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007b9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8007bd:	79 23                	jns    8007e2 <duppage+0x115>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
  8007bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c6:	c7 44 24 08 2c 1c 80 	movl   $0x801c2c,0x8(%esp)
  8007cd:	00 
  8007ce:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  8007d5:	00 
  8007d6:	c7 04 24 3c 1b 80 00 	movl   $0x801b3c,(%esp)
  8007dd:	e8 73 02 00 00       	call   800a55 <_panic>
	if((uvpt[pn] & PTE_COW) || (uvpt[pn] & PTE_W)){
		if(uvpt[pn] & PTE_U) perm |= PTE_U;
		if((r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm)) < 0){
			panic("error in sys_page_map from parent to child in duppage: %e\n", r);
		}
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), thisenv->env_id, (void *)(pn*PGSIZE), perm)) < 0){
  8007e2:	eb 70                	jmp    800854 <duppage+0x187>
			panic("error in remapping sys_page_map in duppage: %e\n", r);
		}
	}
	else{
		if((r = sys_page_map(thisenv->env_id,(void *) (pn*PGSIZE), envid, (void *)(pn*PGSIZE), uvpt[pn] & 0xFFF)) < 0){
  8007e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8007ee:	25 ff 0f 00 00       	and    $0xfff,%eax
  8007f3:	89 c3                	mov    %eax,%ebx
  8007f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007f8:	c1 e0 0c             	shl    $0xc,%eax
  8007fb:	89 c1                	mov    %eax,%ecx
  8007fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800800:	c1 e0 0c             	shl    $0xc,%eax
  800803:	89 c2                	mov    %eax,%edx
  800805:	a1 20 24 80 00       	mov    0x802420,%eax
  80080a:	8b 40 48             	mov    0x48(%eax),%eax
  80080d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800811:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800815:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800818:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80081c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800820:	89 04 24             	mov    %eax,(%esp)
  800823:	e8 85 fb ff ff       	call   8003ad <sys_page_map>
  800828:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80082b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80082f:	79 23                	jns    800854 <duppage+0x187>
			panic("error in sys_page_map in read only case in duppage: %e\n",r);
  800831:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800834:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800838:	c7 44 24 08 5c 1c 80 	movl   $0x801c5c,0x8(%esp)
  80083f:	00 
  800840:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  800847:	00 
  800848:	c7 04 24 3c 1b 80 00 	movl   $0x801b3c,(%esp)
  80084f:	e8 01 02 00 00       	call   800a55 <_panic>
		}		
	}
	// panic("duppage not implemented");
	return 0;
  800854:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800859:	83 c4 30             	add    $0x30,%esp
  80085c:	5b                   	pop    %ebx
  80085d:	5e                   	pop    %esi
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800866:	c7 04 24 7f 05 80 00 	movl   $0x80057f,(%esp)
  80086d:	e8 09 0f 00 00       	call   80177b <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800872:	b8 07 00 00 00       	mov    $0x7,%eax
  800877:	cd 30                	int    $0x30
  800879:	89 45 e8             	mov    %eax,-0x18(%ebp)
		: "=a" (ret)
		: "a" (SYS_exofork),
		  "i" (T_SYSCALL)
	);
	return ret;
  80087c:	8b 45 e8             	mov    -0x18(%ebp),%eax
	envid_t childeid;
	childeid = sys_exofork();
  80087f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if(childeid < 0) panic("child environment id on sysfork: %d\n", childeid);
  800882:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800886:	79 23                	jns    8008ab <fork+0x4b>
  800888:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80088f:	c7 44 24 08 94 1c 80 	movl   $0x801c94,0x8(%esp)
  800896:	00 
  800897:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  80089e:	00 
  80089f:	c7 04 24 3c 1b 80 00 	movl   $0x801b3c,(%esp)
  8008a6:	e8 aa 01 00 00       	call   800a55 <_panic>
	else if(childeid == 0){
  8008ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8008af:	75 29                	jne    8008da <fork+0x7a>
		thisenv = &envs[ENVX(sys_getenvid())];
  8008b1:	e8 2e fa ff ff       	call   8002e4 <sys_getenvid>
  8008b6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8008bb:	c1 e0 02             	shl    $0x2,%eax
  8008be:	89 c2                	mov    %eax,%edx
  8008c0:	c1 e2 05             	shl    $0x5,%edx
  8008c3:	29 c2                	sub    %eax,%edx
  8008c5:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  8008cb:	a3 20 24 80 00       	mov    %eax,0x802420
		// set_pgfault_handler(pgfault);
		return 0;
  8008d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d5:	e9 16 01 00 00       	jmp    8009f0 <fork+0x190>
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  8008da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  8008e1:	eb 3b                	jmp    80091e <fork+0xbe>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
  8008e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008e6:	c1 f8 0a             	sar    $0xa,%eax
  8008e9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8008f0:	83 e0 01             	and    $0x1,%eax
  8008f3:	85 c0                	test   %eax,%eax
  8008f5:	74 23                	je     80091a <fork+0xba>
  8008f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008fa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800901:	83 e0 01             	and    $0x1,%eax
  800904:	85 c0                	test   %eax,%eax
  800906:	74 12                	je     80091a <fork+0xba>
			duppage(childeid, i);
  800908:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80090b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800912:	89 04 24             	mov    %eax,(%esp)
  800915:	e8 b3 fd ff ff       	call   8006cd <duppage>
		// set_pgfault_handler(pgfault);
		return 0;
	}

	int i;
	for(i=0; i < PGNUM(UTOP - PGSIZE); i++){
  80091a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  80091e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800921:	3d fe eb 0e 00       	cmp    $0xeebfe,%eax
  800926:	76 bb                	jbe    8008e3 <fork+0x83>
		if(((uvpd[i >> 10] & PTE_P) == PTE_P) && ((uvpt[i] & PTE_P) == PTE_P)){
			duppage(childeid, i);
		}
	}
	int r;
	if((r = sys_page_alloc(childeid, (void *)(UXSTACKTOP-PGSIZE) , PTE_P | PTE_U | PTE_W)) < 0){
  800928:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80092f:	00 
  800930:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800937:	ee 
  800938:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80093b:	89 04 24             	mov    %eax,(%esp)
  80093e:	e8 29 fa ff ff       	call   80036c <sys_page_alloc>
  800943:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800946:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  80094a:	79 23                	jns    80096f <fork+0x10f>
		panic("error in sys_page_alloc in fork: %e\n",r);
  80094c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80094f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800953:	c7 44 24 08 bc 1c 80 	movl   $0x801cbc,0x8(%esp)
  80095a:	00 
  80095b:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  800962:	00 
  800963:	c7 04 24 3c 1b 80 00 	movl   $0x801b3c,(%esp)
  80096a:	e8 e6 00 00 00       	call   800a55 <_panic>
	}
	if((r = sys_env_set_pgfault_upcall(childeid, _pgfault_upcall)) < 0){
  80096f:	c7 44 24 04 f1 17 80 	movl   $0x8017f1,0x4(%esp)
  800976:	00 
  800977:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80097a:	89 04 24             	mov    %eax,(%esp)
  80097d:	e8 f5 fa ff ff       	call   800477 <sys_env_set_pgfault_upcall>
  800982:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800985:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  800989:	79 23                	jns    8009ae <fork+0x14e>
		panic("error in sys_env_set_pgfault_upcall in fork: %e\n",r);
  80098b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80098e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800992:	c7 44 24 08 e4 1c 80 	movl   $0x801ce4,0x8(%esp)
  800999:	00 
  80099a:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  8009a1:	00 
  8009a2:	c7 04 24 3c 1b 80 00 	movl   $0x801b3c,(%esp)
  8009a9:	e8 a7 00 00 00       	call   800a55 <_panic>
	}
	if((r = sys_env_set_status(childeid, ENV_RUNNABLE)) < 0){
  8009ae:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8009b5:	00 
  8009b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009b9:	89 04 24             	mov    %eax,(%esp)
  8009bc:	e8 74 fa ff ff       	call   800435 <sys_env_set_status>
  8009c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009c4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8009c8:	79 23                	jns    8009ed <fork+0x18d>
		panic("error in sys_env_set_status in fork: %e\n",r);
  8009ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009d1:	c7 44 24 08 18 1d 80 	movl   $0x801d18,0x8(%esp)
  8009d8:	00 
  8009d9:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  8009e0:	00 
  8009e1:	c7 04 24 3c 1b 80 00 	movl   $0x801b3c,(%esp)
  8009e8:	e8 68 00 00 00       	call   800a55 <_panic>
	}
	return childeid;
  8009ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
	// panic("fork not implemented");
}
  8009f0:	c9                   	leave  
  8009f1:	c3                   	ret    

008009f2 <sfork>:

// Challenge!
int
sfork(void)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8009f8:	c7 44 24 08 41 1d 80 	movl   $0x801d41,0x8(%esp)
  8009ff:	00 
  800a00:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
  800a07:	00 
  800a08:	c7 04 24 3c 1b 80 00 	movl   $0x801b3c,(%esp)
  800a0f:	e8 41 00 00 00       	call   800a55 <_panic>

00800a14 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800a20:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800a27:	00 
  800a28:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800a2b:	89 04 24             	mov    %eax,(%esp)
  800a2e:	e8 e8 f7 ff ff       	call   80021b <sys_cputs>
}
  800a33:	c9                   	leave  
  800a34:	c3                   	ret    

00800a35 <getchar>:

int
getchar(void)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	83 ec 18             	sub    $0x18,%esp
	int r;
	// sys_cgetc does not block, but getchar should.
	while ((r = sys_cgetc()) == 0)
  800a3b:	eb 05                	jmp    800a42 <getchar+0xd>
		sys_yield();
  800a3d:	e8 e6 f8 ff ff       	call   800328 <sys_yield>
int
getchar(void)
{
	int r;
	// sys_cgetc does not block, but getchar should.
	while ((r = sys_cgetc()) == 0)
  800a42:	e8 16 f8 ff ff       	call   80025d <sys_cgetc>
  800a47:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800a4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  800a4e:	74 ed                	je     800a3d <getchar+0x8>
		sys_yield();
	return r;
  800a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800a53:	c9                   	leave  
  800a54:	c3                   	ret    

00800a55 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	53                   	push   %ebx
  800a59:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  800a5c:	8d 45 14             	lea    0x14(%ebp),%eax
  800a5f:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a62:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800a68:	e8 77 f8 ff ff       	call   8002e4 <sys_getenvid>
  800a6d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a70:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a74:	8b 55 08             	mov    0x8(%ebp),%edx
  800a77:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a7b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a83:	c7 04 24 58 1d 80 00 	movl   $0x801d58,(%esp)
  800a8a:	e8 e1 00 00 00       	call   800b70 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a92:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a96:	8b 45 10             	mov    0x10(%ebp),%eax
  800a99:	89 04 24             	mov    %eax,(%esp)
  800a9c:	e8 6b 00 00 00       	call   800b0c <vcprintf>
	cprintf("\n");
  800aa1:	c7 04 24 7b 1d 80 00 	movl   $0x801d7b,(%esp)
  800aa8:	e8 c3 00 00 00       	call   800b70 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800aad:	cc                   	int3   
  800aae:	eb fd                	jmp    800aad <_panic+0x58>

00800ab0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab9:	8b 00                	mov    (%eax),%eax
  800abb:	8d 48 01             	lea    0x1(%eax),%ecx
  800abe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac1:	89 0a                	mov    %ecx,(%edx)
  800ac3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac6:	89 d1                	mov    %edx,%ecx
  800ac8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800acb:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800acf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad2:	8b 00                	mov    (%eax),%eax
  800ad4:	3d ff 00 00 00       	cmp    $0xff,%eax
  800ad9:	75 20                	jne    800afb <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  800adb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ade:	8b 00                	mov    (%eax),%eax
  800ae0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae3:	83 c2 08             	add    $0x8,%edx
  800ae6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aea:	89 14 24             	mov    %edx,(%esp)
  800aed:	e8 29 f7 ff ff       	call   80021b <sys_cputs>
		b->idx = 0;
  800af2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800afb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afe:	8b 40 04             	mov    0x4(%eax),%eax
  800b01:	8d 50 01             	lea    0x1(%eax),%edx
  800b04:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b07:	89 50 04             	mov    %edx,0x4(%eax)
}
  800b0a:	c9                   	leave  
  800b0b:	c3                   	ret    

00800b0c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800b15:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800b1c:	00 00 00 
	b.cnt = 0;
  800b1f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800b26:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800b29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b30:	8b 45 08             	mov    0x8(%ebp),%eax
  800b33:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b37:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800b3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b41:	c7 04 24 b0 0a 80 00 	movl   $0x800ab0,(%esp)
  800b48:	e8 bd 01 00 00       	call   800d0a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800b4d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800b53:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b57:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800b5d:	83 c0 08             	add    $0x8,%eax
  800b60:	89 04 24             	mov    %eax,(%esp)
  800b63:	e8 b3 f6 ff ff       	call   80021b <sys_cputs>

	return b.cnt;
  800b68:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800b6e:	c9                   	leave  
  800b6f:	c3                   	ret    

00800b70 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800b76:	8d 45 0c             	lea    0xc(%ebp),%eax
  800b79:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800b7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b83:	8b 45 08             	mov    0x8(%ebp),%eax
  800b86:	89 04 24             	mov    %eax,(%esp)
  800b89:	e8 7e ff ff ff       	call   800b0c <vcprintf>
  800b8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800b94:	c9                   	leave  
  800b95:	c3                   	ret    

00800b96 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	53                   	push   %ebx
  800b9a:	83 ec 34             	sub    $0x34,%esp
  800b9d:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ba3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ba6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800ba9:	8b 45 18             	mov    0x18(%ebp),%eax
  800bac:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb1:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800bb4:	77 72                	ja     800c28 <printnum+0x92>
  800bb6:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800bb9:	72 05                	jb     800bc0 <printnum+0x2a>
  800bbb:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800bbe:	77 68                	ja     800c28 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800bc0:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800bc3:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800bc6:	8b 45 18             	mov    0x18(%ebp),%eax
  800bc9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bce:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bd2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800bd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bd9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bdc:	89 04 24             	mov    %eax,(%esp)
  800bdf:	89 54 24 04          	mov    %edx,0x4(%esp)
  800be3:	e8 38 0c 00 00       	call   801820 <__udivdi3>
  800be8:	8b 4d 20             	mov    0x20(%ebp),%ecx
  800beb:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  800bef:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800bf3:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800bf6:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800bfa:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bfe:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800c02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c05:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c09:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0c:	89 04 24             	mov    %eax,(%esp)
  800c0f:	e8 82 ff ff ff       	call   800b96 <printnum>
  800c14:	eb 1c                	jmp    800c32 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800c16:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c19:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c1d:	8b 45 20             	mov    0x20(%ebp),%eax
  800c20:	89 04 24             	mov    %eax,(%esp)
  800c23:	8b 45 08             	mov    0x8(%ebp),%eax
  800c26:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800c28:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800c2c:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800c30:	7f e4                	jg     800c16 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800c32:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800c35:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c3d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c40:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c44:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800c48:	89 04 24             	mov    %eax,(%esp)
  800c4b:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c4f:	e8 fc 0c 00 00       	call   801950 <__umoddi3>
  800c54:	05 48 1e 80 00       	add    $0x801e48,%eax
  800c59:	0f b6 00             	movzbl (%eax),%eax
  800c5c:	0f be c0             	movsbl %al,%eax
  800c5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c62:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c66:	89 04 24             	mov    %eax,(%esp)
  800c69:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6c:	ff d0                	call   *%eax
}
  800c6e:	83 c4 34             	add    $0x34,%esp
  800c71:	5b                   	pop    %ebx
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800c77:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800c7b:	7e 14                	jle    800c91 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800c7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c80:	8b 00                	mov    (%eax),%eax
  800c82:	8d 48 08             	lea    0x8(%eax),%ecx
  800c85:	8b 55 08             	mov    0x8(%ebp),%edx
  800c88:	89 0a                	mov    %ecx,(%edx)
  800c8a:	8b 50 04             	mov    0x4(%eax),%edx
  800c8d:	8b 00                	mov    (%eax),%eax
  800c8f:	eb 30                	jmp    800cc1 <getuint+0x4d>
	else if (lflag)
  800c91:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c95:	74 16                	je     800cad <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800c97:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9a:	8b 00                	mov    (%eax),%eax
  800c9c:	8d 48 04             	lea    0x4(%eax),%ecx
  800c9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca2:	89 0a                	mov    %ecx,(%edx)
  800ca4:	8b 00                	mov    (%eax),%eax
  800ca6:	ba 00 00 00 00       	mov    $0x0,%edx
  800cab:	eb 14                	jmp    800cc1 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800cad:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb0:	8b 00                	mov    (%eax),%eax
  800cb2:	8d 48 04             	lea    0x4(%eax),%ecx
  800cb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb8:	89 0a                	mov    %ecx,(%edx)
  800cba:	8b 00                	mov    (%eax),%eax
  800cbc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800cc6:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800cca:	7e 14                	jle    800ce0 <getint+0x1d>
		return va_arg(*ap, long long);
  800ccc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccf:	8b 00                	mov    (%eax),%eax
  800cd1:	8d 48 08             	lea    0x8(%eax),%ecx
  800cd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd7:	89 0a                	mov    %ecx,(%edx)
  800cd9:	8b 50 04             	mov    0x4(%eax),%edx
  800cdc:	8b 00                	mov    (%eax),%eax
  800cde:	eb 28                	jmp    800d08 <getint+0x45>
	else if (lflag)
  800ce0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ce4:	74 12                	je     800cf8 <getint+0x35>
		return va_arg(*ap, long);
  800ce6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce9:	8b 00                	mov    (%eax),%eax
  800ceb:	8d 48 04             	lea    0x4(%eax),%ecx
  800cee:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf1:	89 0a                	mov    %ecx,(%edx)
  800cf3:	8b 00                	mov    (%eax),%eax
  800cf5:	99                   	cltd   
  800cf6:	eb 10                	jmp    800d08 <getint+0x45>
	else
		return va_arg(*ap, int);
  800cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfb:	8b 00                	mov    (%eax),%eax
  800cfd:	8d 48 04             	lea    0x4(%eax),%ecx
  800d00:	8b 55 08             	mov    0x8(%ebp),%edx
  800d03:	89 0a                	mov    %ecx,(%edx)
  800d05:	8b 00                	mov    (%eax),%eax
  800d07:	99                   	cltd   
}
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    

00800d0a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	56                   	push   %esi
  800d0e:	53                   	push   %ebx
  800d0f:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800d12:	eb 18                	jmp    800d2c <vprintfmt+0x22>
			if (ch == '\0')
  800d14:	85 db                	test   %ebx,%ebx
  800d16:	75 05                	jne    800d1d <vprintfmt+0x13>
				return;
  800d18:	e9 cc 03 00 00       	jmp    8010e9 <vprintfmt+0x3df>
			putch(ch, putdat);
  800d1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d20:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d24:	89 1c 24             	mov    %ebx,(%esp)
  800d27:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2a:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800d2c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d2f:	8d 50 01             	lea    0x1(%eax),%edx
  800d32:	89 55 10             	mov    %edx,0x10(%ebp)
  800d35:	0f b6 00             	movzbl (%eax),%eax
  800d38:	0f b6 d8             	movzbl %al,%ebx
  800d3b:	83 fb 25             	cmp    $0x25,%ebx
  800d3e:	75 d4                	jne    800d14 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800d40:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800d44:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800d4b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800d52:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800d59:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d60:	8b 45 10             	mov    0x10(%ebp),%eax
  800d63:	8d 50 01             	lea    0x1(%eax),%edx
  800d66:	89 55 10             	mov    %edx,0x10(%ebp)
  800d69:	0f b6 00             	movzbl (%eax),%eax
  800d6c:	0f b6 d8             	movzbl %al,%ebx
  800d6f:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800d72:	83 f8 55             	cmp    $0x55,%eax
  800d75:	0f 87 3d 03 00 00    	ja     8010b8 <vprintfmt+0x3ae>
  800d7b:	8b 04 85 6c 1e 80 00 	mov    0x801e6c(,%eax,4),%eax
  800d82:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800d84:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800d88:	eb d6                	jmp    800d60 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800d8a:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800d8e:	eb d0                	jmp    800d60 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800d90:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800d97:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800d9a:	89 d0                	mov    %edx,%eax
  800d9c:	c1 e0 02             	shl    $0x2,%eax
  800d9f:	01 d0                	add    %edx,%eax
  800da1:	01 c0                	add    %eax,%eax
  800da3:	01 d8                	add    %ebx,%eax
  800da5:	83 e8 30             	sub    $0x30,%eax
  800da8:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800dab:	8b 45 10             	mov    0x10(%ebp),%eax
  800dae:	0f b6 00             	movzbl (%eax),%eax
  800db1:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800db4:	83 fb 2f             	cmp    $0x2f,%ebx
  800db7:	7e 0b                	jle    800dc4 <vprintfmt+0xba>
  800db9:	83 fb 39             	cmp    $0x39,%ebx
  800dbc:	7f 06                	jg     800dc4 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800dbe:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800dc2:	eb d3                	jmp    800d97 <vprintfmt+0x8d>
			goto process_precision;
  800dc4:	eb 33                	jmp    800df9 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800dc6:	8b 45 14             	mov    0x14(%ebp),%eax
  800dc9:	8d 50 04             	lea    0x4(%eax),%edx
  800dcc:	89 55 14             	mov    %edx,0x14(%ebp)
  800dcf:	8b 00                	mov    (%eax),%eax
  800dd1:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800dd4:	eb 23                	jmp    800df9 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  800dd6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800dda:	79 0c                	jns    800de8 <vprintfmt+0xde>
				width = 0;
  800ddc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800de3:	e9 78 ff ff ff       	jmp    800d60 <vprintfmt+0x56>
  800de8:	e9 73 ff ff ff       	jmp    800d60 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  800ded:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800df4:	e9 67 ff ff ff       	jmp    800d60 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800df9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800dfd:	79 12                	jns    800e11 <vprintfmt+0x107>
				width = precision, precision = -1;
  800dff:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e02:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e05:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800e0c:	e9 4f ff ff ff       	jmp    800d60 <vprintfmt+0x56>
  800e11:	e9 4a ff ff ff       	jmp    800d60 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800e16:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800e1a:	e9 41 ff ff ff       	jmp    800d60 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800e1f:	8b 45 14             	mov    0x14(%ebp),%eax
  800e22:	8d 50 04             	lea    0x4(%eax),%edx
  800e25:	89 55 14             	mov    %edx,0x14(%ebp)
  800e28:	8b 00                	mov    (%eax),%eax
  800e2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e2d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e31:	89 04 24             	mov    %eax,(%esp)
  800e34:	8b 45 08             	mov    0x8(%ebp),%eax
  800e37:	ff d0                	call   *%eax
			break;
  800e39:	e9 a5 02 00 00       	jmp    8010e3 <vprintfmt+0x3d9>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800e3e:	8b 45 14             	mov    0x14(%ebp),%eax
  800e41:	8d 50 04             	lea    0x4(%eax),%edx
  800e44:	89 55 14             	mov    %edx,0x14(%ebp)
  800e47:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800e49:	85 db                	test   %ebx,%ebx
  800e4b:	79 02                	jns    800e4f <vprintfmt+0x145>
				err = -err;
  800e4d:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800e4f:	83 fb 09             	cmp    $0x9,%ebx
  800e52:	7f 0b                	jg     800e5f <vprintfmt+0x155>
  800e54:	8b 34 9d 20 1e 80 00 	mov    0x801e20(,%ebx,4),%esi
  800e5b:	85 f6                	test   %esi,%esi
  800e5d:	75 23                	jne    800e82 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800e5f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e63:	c7 44 24 08 59 1e 80 	movl   $0x801e59,0x8(%esp)
  800e6a:	00 
  800e6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e72:	8b 45 08             	mov    0x8(%ebp),%eax
  800e75:	89 04 24             	mov    %eax,(%esp)
  800e78:	e8 73 02 00 00       	call   8010f0 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800e7d:	e9 61 02 00 00       	jmp    8010e3 <vprintfmt+0x3d9>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800e82:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800e86:	c7 44 24 08 62 1e 80 	movl   $0x801e62,0x8(%esp)
  800e8d:	00 
  800e8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e91:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e95:	8b 45 08             	mov    0x8(%ebp),%eax
  800e98:	89 04 24             	mov    %eax,(%esp)
  800e9b:	e8 50 02 00 00       	call   8010f0 <printfmt>
			break;
  800ea0:	e9 3e 02 00 00       	jmp    8010e3 <vprintfmt+0x3d9>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800ea5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ea8:	8d 50 04             	lea    0x4(%eax),%edx
  800eab:	89 55 14             	mov    %edx,0x14(%ebp)
  800eae:	8b 30                	mov    (%eax),%esi
  800eb0:	85 f6                	test   %esi,%esi
  800eb2:	75 05                	jne    800eb9 <vprintfmt+0x1af>
				p = "(null)";
  800eb4:	be 65 1e 80 00       	mov    $0x801e65,%esi
			if (width > 0 && padc != '-')
  800eb9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ebd:	7e 37                	jle    800ef6 <vprintfmt+0x1ec>
  800ebf:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800ec3:	74 31                	je     800ef6 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800ec5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ec8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ecc:	89 34 24             	mov    %esi,(%esp)
  800ecf:	e8 39 03 00 00       	call   80120d <strnlen>
  800ed4:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800ed7:	eb 17                	jmp    800ef0 <vprintfmt+0x1e6>
					putch(padc, putdat);
  800ed9:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800edd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ee0:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ee4:	89 04 24             	mov    %eax,(%esp)
  800ee7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eea:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800eec:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800ef0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ef4:	7f e3                	jg     800ed9 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ef6:	eb 38                	jmp    800f30 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800ef8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800efc:	74 1f                	je     800f1d <vprintfmt+0x213>
  800efe:	83 fb 1f             	cmp    $0x1f,%ebx
  800f01:	7e 05                	jle    800f08 <vprintfmt+0x1fe>
  800f03:	83 fb 7e             	cmp    $0x7e,%ebx
  800f06:	7e 15                	jle    800f1d <vprintfmt+0x213>
					putch('?', putdat);
  800f08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f0f:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800f16:	8b 45 08             	mov    0x8(%ebp),%eax
  800f19:	ff d0                	call   *%eax
  800f1b:	eb 0f                	jmp    800f2c <vprintfmt+0x222>
				else
					putch(ch, putdat);
  800f1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f20:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f24:	89 1c 24             	mov    %ebx,(%esp)
  800f27:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2a:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800f2c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800f30:	89 f0                	mov    %esi,%eax
  800f32:	8d 70 01             	lea    0x1(%eax),%esi
  800f35:	0f b6 00             	movzbl (%eax),%eax
  800f38:	0f be d8             	movsbl %al,%ebx
  800f3b:	85 db                	test   %ebx,%ebx
  800f3d:	74 10                	je     800f4f <vprintfmt+0x245>
  800f3f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f43:	78 b3                	js     800ef8 <vprintfmt+0x1ee>
  800f45:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800f49:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800f4d:	79 a9                	jns    800ef8 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800f4f:	eb 17                	jmp    800f68 <vprintfmt+0x25e>
				putch(' ', putdat);
  800f51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f54:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f58:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800f5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f62:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800f64:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800f68:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f6c:	7f e3                	jg     800f51 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800f6e:	e9 70 01 00 00       	jmp    8010e3 <vprintfmt+0x3d9>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800f73:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f76:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f7a:	8d 45 14             	lea    0x14(%ebp),%eax
  800f7d:	89 04 24             	mov    %eax,(%esp)
  800f80:	e8 3e fd ff ff       	call   800cc3 <getint>
  800f85:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800f88:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800f8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f91:	85 d2                	test   %edx,%edx
  800f93:	79 26                	jns    800fbb <vprintfmt+0x2b1>
				putch('-', putdat);
  800f95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f98:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f9c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800fa3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa6:	ff d0                	call   *%eax
				num = -(long long) num;
  800fa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800fae:	f7 d8                	neg    %eax
  800fb0:	83 d2 00             	adc    $0x0,%edx
  800fb3:	f7 da                	neg    %edx
  800fb5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800fb8:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800fbb:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800fc2:	e9 a8 00 00 00       	jmp    80106f <vprintfmt+0x365>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800fc7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800fca:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fce:	8d 45 14             	lea    0x14(%ebp),%eax
  800fd1:	89 04 24             	mov    %eax,(%esp)
  800fd4:	e8 9b fc ff ff       	call   800c74 <getuint>
  800fd9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800fdc:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800fdf:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800fe6:	e9 84 00 00 00       	jmp    80106f <vprintfmt+0x365>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800feb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800fee:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ff2:	8d 45 14             	lea    0x14(%ebp),%eax
  800ff5:	89 04 24             	mov    %eax,(%esp)
  800ff8:	e8 77 fc ff ff       	call   800c74 <getuint>
  800ffd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801000:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 8;
  801003:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			goto number;
  80100a:	eb 63                	jmp    80106f <vprintfmt+0x365>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80100c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80100f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801013:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80101a:	8b 45 08             	mov    0x8(%ebp),%eax
  80101d:	ff d0                	call   *%eax
			putch('x', putdat);
  80101f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801022:	89 44 24 04          	mov    %eax,0x4(%esp)
  801026:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80102d:	8b 45 08             	mov    0x8(%ebp),%eax
  801030:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801032:	8b 45 14             	mov    0x14(%ebp),%eax
  801035:	8d 50 04             	lea    0x4(%eax),%edx
  801038:	89 55 14             	mov    %edx,0x14(%ebp)
  80103b:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80103d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801040:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801047:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  80104e:	eb 1f                	jmp    80106f <vprintfmt+0x365>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801050:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801053:	89 44 24 04          	mov    %eax,0x4(%esp)
  801057:	8d 45 14             	lea    0x14(%ebp),%eax
  80105a:	89 04 24             	mov    %eax,(%esp)
  80105d:	e8 12 fc ff ff       	call   800c74 <getuint>
  801062:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801065:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  801068:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  80106f:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  801073:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801076:	89 54 24 18          	mov    %edx,0x18(%esp)
  80107a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80107d:	89 54 24 14          	mov    %edx,0x14(%esp)
  801081:	89 44 24 10          	mov    %eax,0x10(%esp)
  801085:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801088:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80108b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80108f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801093:	8b 45 0c             	mov    0xc(%ebp),%eax
  801096:	89 44 24 04          	mov    %eax,0x4(%esp)
  80109a:	8b 45 08             	mov    0x8(%ebp),%eax
  80109d:	89 04 24             	mov    %eax,(%esp)
  8010a0:	e8 f1 fa ff ff       	call   800b96 <printnum>
			break;
  8010a5:	eb 3c                	jmp    8010e3 <vprintfmt+0x3d9>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8010a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ae:	89 1c 24             	mov    %ebx,(%esp)
  8010b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b4:	ff d0                	call   *%eax
			break;
  8010b6:	eb 2b                	jmp    8010e3 <vprintfmt+0x3d9>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8010b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010bf:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8010c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c9:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  8010cb:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8010cf:	eb 04                	jmp    8010d5 <vprintfmt+0x3cb>
  8010d1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  8010d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8010d8:	83 e8 01             	sub    $0x1,%eax
  8010db:	0f b6 00             	movzbl (%eax),%eax
  8010de:	3c 25                	cmp    $0x25,%al
  8010e0:	75 ef                	jne    8010d1 <vprintfmt+0x3c7>
				/* do nothing */;
			break;
  8010e2:	90                   	nop
		}
	}
  8010e3:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8010e4:	e9 43 fc ff ff       	jmp    800d2c <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8010e9:	83 c4 40             	add    $0x40,%esp
  8010ec:	5b                   	pop    %ebx
  8010ed:	5e                   	pop    %esi
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    

008010f0 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  8010f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8010f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8010fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801103:	8b 45 10             	mov    0x10(%ebp),%eax
  801106:	89 44 24 08          	mov    %eax,0x8(%esp)
  80110a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80110d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801111:	8b 45 08             	mov    0x8(%ebp),%eax
  801114:	89 04 24             	mov    %eax,(%esp)
  801117:	e8 ee fb ff ff       	call   800d0a <vprintfmt>
	va_end(ap);
}
  80111c:	c9                   	leave  
  80111d:	c3                   	ret    

0080111e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80111e:	55                   	push   %ebp
  80111f:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  801121:	8b 45 0c             	mov    0xc(%ebp),%eax
  801124:	8b 40 08             	mov    0x8(%eax),%eax
  801127:	8d 50 01             	lea    0x1(%eax),%edx
  80112a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80112d:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  801130:	8b 45 0c             	mov    0xc(%ebp),%eax
  801133:	8b 10                	mov    (%eax),%edx
  801135:	8b 45 0c             	mov    0xc(%ebp),%eax
  801138:	8b 40 04             	mov    0x4(%eax),%eax
  80113b:	39 c2                	cmp    %eax,%edx
  80113d:	73 12                	jae    801151 <sprintputch+0x33>
		*b->buf++ = ch;
  80113f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801142:	8b 00                	mov    (%eax),%eax
  801144:	8d 48 01             	lea    0x1(%eax),%ecx
  801147:	8b 55 0c             	mov    0xc(%ebp),%edx
  80114a:	89 0a                	mov    %ecx,(%edx)
  80114c:	8b 55 08             	mov    0x8(%ebp),%edx
  80114f:	88 10                	mov    %dl,(%eax)
}
  801151:	5d                   	pop    %ebp
  801152:	c3                   	ret    

00801153 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  801159:	8b 45 08             	mov    0x8(%ebp),%eax
  80115c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80115f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801162:	8d 50 ff             	lea    -0x1(%eax),%edx
  801165:	8b 45 08             	mov    0x8(%ebp),%eax
  801168:	01 d0                	add    %edx,%eax
  80116a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80116d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801174:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801178:	74 06                	je     801180 <vsnprintf+0x2d>
  80117a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80117e:	7f 07                	jg     801187 <vsnprintf+0x34>
		return -E_INVAL;
  801180:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801185:	eb 2a                	jmp    8011b1 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801187:	8b 45 14             	mov    0x14(%ebp),%eax
  80118a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80118e:	8b 45 10             	mov    0x10(%ebp),%eax
  801191:	89 44 24 08          	mov    %eax,0x8(%esp)
  801195:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801198:	89 44 24 04          	mov    %eax,0x4(%esp)
  80119c:	c7 04 24 1e 11 80 00 	movl   $0x80111e,(%esp)
  8011a3:	e8 62 fb ff ff       	call   800d0a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8011a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8011ab:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8011ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8011b1:	c9                   	leave  
  8011b2:	c3                   	ret    

008011b3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8011b3:	55                   	push   %ebp
  8011b4:	89 e5                	mov    %esp,%ebp
  8011b6:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8011b9:	8d 45 14             	lea    0x14(%ebp),%eax
  8011bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8011bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8011c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d7:	89 04 24             	mov    %eax,(%esp)
  8011da:	e8 74 ff ff ff       	call   801153 <vsnprintf>
  8011df:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  8011e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8011e5:	c9                   	leave  
  8011e6:	c3                   	ret    

008011e7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
  8011ea:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  8011ed:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8011f4:	eb 08                	jmp    8011fe <strlen+0x17>
		n++;
  8011f6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8011fa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8011fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801201:	0f b6 00             	movzbl (%eax),%eax
  801204:	84 c0                	test   %al,%al
  801206:	75 ee                	jne    8011f6 <strlen+0xf>
		n++;
	return n;
  801208:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80120b:	c9                   	leave  
  80120c:	c3                   	ret    

0080120d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
  801210:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801213:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80121a:	eb 0c                	jmp    801228 <strnlen+0x1b>
		n++;
  80121c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801220:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801224:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  801228:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80122c:	74 0a                	je     801238 <strnlen+0x2b>
  80122e:	8b 45 08             	mov    0x8(%ebp),%eax
  801231:	0f b6 00             	movzbl (%eax),%eax
  801234:	84 c0                	test   %al,%al
  801236:	75 e4                	jne    80121c <strnlen+0xf>
		n++;
	return n;
  801238:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80123b:	c9                   	leave  
  80123c:	c3                   	ret    

0080123d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80123d:	55                   	push   %ebp
  80123e:	89 e5                	mov    %esp,%ebp
  801240:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  801243:	8b 45 08             	mov    0x8(%ebp),%eax
  801246:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  801249:	90                   	nop
  80124a:	8b 45 08             	mov    0x8(%ebp),%eax
  80124d:	8d 50 01             	lea    0x1(%eax),%edx
  801250:	89 55 08             	mov    %edx,0x8(%ebp)
  801253:	8b 55 0c             	mov    0xc(%ebp),%edx
  801256:	8d 4a 01             	lea    0x1(%edx),%ecx
  801259:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  80125c:	0f b6 12             	movzbl (%edx),%edx
  80125f:	88 10                	mov    %dl,(%eax)
  801261:	0f b6 00             	movzbl (%eax),%eax
  801264:	84 c0                	test   %al,%al
  801266:	75 e2                	jne    80124a <strcpy+0xd>
		/* do nothing */;
	return ret;
  801268:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80126b:	c9                   	leave  
  80126c:	c3                   	ret    

0080126d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80126d:	55                   	push   %ebp
  80126e:	89 e5                	mov    %esp,%ebp
  801270:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  801273:	8b 45 08             	mov    0x8(%ebp),%eax
  801276:	89 04 24             	mov    %eax,(%esp)
  801279:	e8 69 ff ff ff       	call   8011e7 <strlen>
  80127e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  801281:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801284:	8b 45 08             	mov    0x8(%ebp),%eax
  801287:	01 c2                	add    %eax,%edx
  801289:	8b 45 0c             	mov    0xc(%ebp),%eax
  80128c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801290:	89 14 24             	mov    %edx,(%esp)
  801293:	e8 a5 ff ff ff       	call   80123d <strcpy>
	return dst;
  801298:	8b 45 08             	mov    0x8(%ebp),%eax
}
  80129b:	c9                   	leave  
  80129c:	c3                   	ret    

0080129d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  8012a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a6:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8012a9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8012b0:	eb 23                	jmp    8012d5 <strncpy+0x38>
		*dst++ = *src;
  8012b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b5:	8d 50 01             	lea    0x1(%eax),%edx
  8012b8:	89 55 08             	mov    %edx,0x8(%ebp)
  8012bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012be:	0f b6 12             	movzbl (%edx),%edx
  8012c1:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8012c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c6:	0f b6 00             	movzbl (%eax),%eax
  8012c9:	84 c0                	test   %al,%al
  8012cb:	74 04                	je     8012d1 <strncpy+0x34>
			src++;
  8012cd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8012d1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8012d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012d8:	3b 45 10             	cmp    0x10(%ebp),%eax
  8012db:	72 d5                	jb     8012b2 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  8012dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8012e0:	c9                   	leave  
  8012e1:	c3                   	ret    

008012e2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  8012e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8012eb:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  8012ee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8012f2:	74 33                	je     801327 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  8012f4:	eb 17                	jmp    80130d <strlcpy+0x2b>
			*dst++ = *src++;
  8012f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f9:	8d 50 01             	lea    0x1(%eax),%edx
  8012fc:	89 55 08             	mov    %edx,0x8(%ebp)
  8012ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801302:	8d 4a 01             	lea    0x1(%edx),%ecx
  801305:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  801308:	0f b6 12             	movzbl (%edx),%edx
  80130b:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80130d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  801311:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801315:	74 0a                	je     801321 <strlcpy+0x3f>
  801317:	8b 45 0c             	mov    0xc(%ebp),%eax
  80131a:	0f b6 00             	movzbl (%eax),%eax
  80131d:	84 c0                	test   %al,%al
  80131f:	75 d5                	jne    8012f6 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  801321:	8b 45 08             	mov    0x8(%ebp),%eax
  801324:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801327:	8b 55 08             	mov    0x8(%ebp),%edx
  80132a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80132d:	29 c2                	sub    %eax,%edx
  80132f:	89 d0                	mov    %edx,%eax
}
  801331:	c9                   	leave  
  801332:	c3                   	ret    

00801333 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801333:	55                   	push   %ebp
  801334:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  801336:	eb 08                	jmp    801340 <strcmp+0xd>
		p++, q++;
  801338:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80133c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801340:	8b 45 08             	mov    0x8(%ebp),%eax
  801343:	0f b6 00             	movzbl (%eax),%eax
  801346:	84 c0                	test   %al,%al
  801348:	74 10                	je     80135a <strcmp+0x27>
  80134a:	8b 45 08             	mov    0x8(%ebp),%eax
  80134d:	0f b6 10             	movzbl (%eax),%edx
  801350:	8b 45 0c             	mov    0xc(%ebp),%eax
  801353:	0f b6 00             	movzbl (%eax),%eax
  801356:	38 c2                	cmp    %al,%dl
  801358:	74 de                	je     801338 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80135a:	8b 45 08             	mov    0x8(%ebp),%eax
  80135d:	0f b6 00             	movzbl (%eax),%eax
  801360:	0f b6 d0             	movzbl %al,%edx
  801363:	8b 45 0c             	mov    0xc(%ebp),%eax
  801366:	0f b6 00             	movzbl (%eax),%eax
  801369:	0f b6 c0             	movzbl %al,%eax
  80136c:	29 c2                	sub    %eax,%edx
  80136e:	89 d0                	mov    %edx,%eax
}
  801370:	5d                   	pop    %ebp
  801371:	c3                   	ret    

00801372 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  801375:	eb 0c                	jmp    801383 <strncmp+0x11>
		n--, p++, q++;
  801377:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  80137b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80137f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801383:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801387:	74 1a                	je     8013a3 <strncmp+0x31>
  801389:	8b 45 08             	mov    0x8(%ebp),%eax
  80138c:	0f b6 00             	movzbl (%eax),%eax
  80138f:	84 c0                	test   %al,%al
  801391:	74 10                	je     8013a3 <strncmp+0x31>
  801393:	8b 45 08             	mov    0x8(%ebp),%eax
  801396:	0f b6 10             	movzbl (%eax),%edx
  801399:	8b 45 0c             	mov    0xc(%ebp),%eax
  80139c:	0f b6 00             	movzbl (%eax),%eax
  80139f:	38 c2                	cmp    %al,%dl
  8013a1:	74 d4                	je     801377 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  8013a3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013a7:	75 07                	jne    8013b0 <strncmp+0x3e>
		return 0;
  8013a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ae:	eb 16                	jmp    8013c6 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8013b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b3:	0f b6 00             	movzbl (%eax),%eax
  8013b6:	0f b6 d0             	movzbl %al,%edx
  8013b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013bc:	0f b6 00             	movzbl (%eax),%eax
  8013bf:	0f b6 c0             	movzbl %al,%eax
  8013c2:	29 c2                	sub    %eax,%edx
  8013c4:	89 d0                	mov    %edx,%eax
}
  8013c6:	5d                   	pop    %ebp
  8013c7:	c3                   	ret    

008013c8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
  8013cb:	83 ec 04             	sub    $0x4,%esp
  8013ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013d1:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  8013d4:	eb 14                	jmp    8013ea <strchr+0x22>
		if (*s == c)
  8013d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d9:	0f b6 00             	movzbl (%eax),%eax
  8013dc:	3a 45 fc             	cmp    -0x4(%ebp),%al
  8013df:	75 05                	jne    8013e6 <strchr+0x1e>
			return (char *) s;
  8013e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e4:	eb 13                	jmp    8013f9 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8013e6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8013ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ed:	0f b6 00             	movzbl (%eax),%eax
  8013f0:	84 c0                	test   %al,%al
  8013f2:	75 e2                	jne    8013d6 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  8013f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013f9:	c9                   	leave  
  8013fa:	c3                   	ret    

008013fb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8013fb:	55                   	push   %ebp
  8013fc:	89 e5                	mov    %esp,%ebp
  8013fe:	83 ec 04             	sub    $0x4,%esp
  801401:	8b 45 0c             	mov    0xc(%ebp),%eax
  801404:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  801407:	eb 11                	jmp    80141a <strfind+0x1f>
		if (*s == c)
  801409:	8b 45 08             	mov    0x8(%ebp),%eax
  80140c:	0f b6 00             	movzbl (%eax),%eax
  80140f:	3a 45 fc             	cmp    -0x4(%ebp),%al
  801412:	75 02                	jne    801416 <strfind+0x1b>
			break;
  801414:	eb 0e                	jmp    801424 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801416:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80141a:	8b 45 08             	mov    0x8(%ebp),%eax
  80141d:	0f b6 00             	movzbl (%eax),%eax
  801420:	84 c0                	test   %al,%al
  801422:	75 e5                	jne    801409 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  801424:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801427:	c9                   	leave  
  801428:	c3                   	ret    

00801429 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	57                   	push   %edi
	char *p;

	if (n == 0)
  80142d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801431:	75 05                	jne    801438 <memset+0xf>
		return v;
  801433:	8b 45 08             	mov    0x8(%ebp),%eax
  801436:	eb 5c                	jmp    801494 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  801438:	8b 45 08             	mov    0x8(%ebp),%eax
  80143b:	83 e0 03             	and    $0x3,%eax
  80143e:	85 c0                	test   %eax,%eax
  801440:	75 41                	jne    801483 <memset+0x5a>
  801442:	8b 45 10             	mov    0x10(%ebp),%eax
  801445:	83 e0 03             	and    $0x3,%eax
  801448:	85 c0                	test   %eax,%eax
  80144a:	75 37                	jne    801483 <memset+0x5a>
		c &= 0xFF;
  80144c:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801453:	8b 45 0c             	mov    0xc(%ebp),%eax
  801456:	c1 e0 18             	shl    $0x18,%eax
  801459:	89 c2                	mov    %eax,%edx
  80145b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80145e:	c1 e0 10             	shl    $0x10,%eax
  801461:	09 c2                	or     %eax,%edx
  801463:	8b 45 0c             	mov    0xc(%ebp),%eax
  801466:	c1 e0 08             	shl    $0x8,%eax
  801469:	09 d0                	or     %edx,%eax
  80146b:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80146e:	8b 45 10             	mov    0x10(%ebp),%eax
  801471:	c1 e8 02             	shr    $0x2,%eax
  801474:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801476:	8b 55 08             	mov    0x8(%ebp),%edx
  801479:	8b 45 0c             	mov    0xc(%ebp),%eax
  80147c:	89 d7                	mov    %edx,%edi
  80147e:	fc                   	cld    
  80147f:	f3 ab                	rep stos %eax,%es:(%edi)
  801481:	eb 0e                	jmp    801491 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801483:	8b 55 08             	mov    0x8(%ebp),%edx
  801486:	8b 45 0c             	mov    0xc(%ebp),%eax
  801489:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80148c:	89 d7                	mov    %edx,%edi
  80148e:	fc                   	cld    
  80148f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  801491:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801494:	5f                   	pop    %edi
  801495:	5d                   	pop    %ebp
  801496:	c3                   	ret    

00801497 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801497:	55                   	push   %ebp
  801498:	89 e5                	mov    %esp,%ebp
  80149a:	57                   	push   %edi
  80149b:	56                   	push   %esi
  80149c:	53                   	push   %ebx
  80149d:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  8014a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  8014a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  8014ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014af:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  8014b2:	73 6d                	jae    801521 <memmove+0x8a>
  8014b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8014b7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014ba:	01 d0                	add    %edx,%eax
  8014bc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  8014bf:	76 60                	jbe    801521 <memmove+0x8a>
		s += n;
  8014c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8014c4:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  8014c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8014ca:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8014cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d0:	83 e0 03             	and    $0x3,%eax
  8014d3:	85 c0                	test   %eax,%eax
  8014d5:	75 2f                	jne    801506 <memmove+0x6f>
  8014d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8014da:	83 e0 03             	and    $0x3,%eax
  8014dd:	85 c0                	test   %eax,%eax
  8014df:	75 25                	jne    801506 <memmove+0x6f>
  8014e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8014e4:	83 e0 03             	and    $0x3,%eax
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	75 1b                	jne    801506 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8014eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8014ee:	83 e8 04             	sub    $0x4,%eax
  8014f1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014f4:	83 ea 04             	sub    $0x4,%edx
  8014f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014fa:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8014fd:	89 c7                	mov    %eax,%edi
  8014ff:	89 d6                	mov    %edx,%esi
  801501:	fd                   	std    
  801502:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801504:	eb 18                	jmp    80151e <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801506:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801509:	8d 50 ff             	lea    -0x1(%eax),%edx
  80150c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150f:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801512:	8b 45 10             	mov    0x10(%ebp),%eax
  801515:	89 d7                	mov    %edx,%edi
  801517:	89 de                	mov    %ebx,%esi
  801519:	89 c1                	mov    %eax,%ecx
  80151b:	fd                   	std    
  80151c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80151e:	fc                   	cld    
  80151f:	eb 45                	jmp    801566 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801521:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801524:	83 e0 03             	and    $0x3,%eax
  801527:	85 c0                	test   %eax,%eax
  801529:	75 2b                	jne    801556 <memmove+0xbf>
  80152b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80152e:	83 e0 03             	and    $0x3,%eax
  801531:	85 c0                	test   %eax,%eax
  801533:	75 21                	jne    801556 <memmove+0xbf>
  801535:	8b 45 10             	mov    0x10(%ebp),%eax
  801538:	83 e0 03             	and    $0x3,%eax
  80153b:	85 c0                	test   %eax,%eax
  80153d:	75 17                	jne    801556 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80153f:	8b 45 10             	mov    0x10(%ebp),%eax
  801542:	c1 e8 02             	shr    $0x2,%eax
  801545:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801547:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80154a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80154d:	89 c7                	mov    %eax,%edi
  80154f:	89 d6                	mov    %edx,%esi
  801551:	fc                   	cld    
  801552:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801554:	eb 10                	jmp    801566 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801556:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801559:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80155c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80155f:	89 c7                	mov    %eax,%edi
  801561:	89 d6                	mov    %edx,%esi
  801563:	fc                   	cld    
  801564:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  801566:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801569:	83 c4 10             	add    $0x10,%esp
  80156c:	5b                   	pop    %ebx
  80156d:	5e                   	pop    %esi
  80156e:	5f                   	pop    %edi
  80156f:	5d                   	pop    %ebp
  801570:	c3                   	ret    

00801571 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801571:	55                   	push   %ebp
  801572:	89 e5                	mov    %esp,%ebp
  801574:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801577:	8b 45 10             	mov    0x10(%ebp),%eax
  80157a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80157e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801581:	89 44 24 04          	mov    %eax,0x4(%esp)
  801585:	8b 45 08             	mov    0x8(%ebp),%eax
  801588:	89 04 24             	mov    %eax,(%esp)
  80158b:	e8 07 ff ff ff       	call   801497 <memmove>
}
  801590:	c9                   	leave  
  801591:	c3                   	ret    

00801592 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801592:	55                   	push   %ebp
  801593:	89 e5                	mov    %esp,%ebp
  801595:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  801598:	8b 45 08             	mov    0x8(%ebp),%eax
  80159b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  80159e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015a1:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  8015a4:	eb 30                	jmp    8015d6 <memcmp+0x44>
		if (*s1 != *s2)
  8015a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015a9:	0f b6 10             	movzbl (%eax),%edx
  8015ac:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8015af:	0f b6 00             	movzbl (%eax),%eax
  8015b2:	38 c2                	cmp    %al,%dl
  8015b4:	74 18                	je     8015ce <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  8015b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015b9:	0f b6 00             	movzbl (%eax),%eax
  8015bc:	0f b6 d0             	movzbl %al,%edx
  8015bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8015c2:	0f b6 00             	movzbl (%eax),%eax
  8015c5:	0f b6 c0             	movzbl %al,%eax
  8015c8:	29 c2                	sub    %eax,%edx
  8015ca:	89 d0                	mov    %edx,%eax
  8015cc:	eb 1a                	jmp    8015e8 <memcmp+0x56>
		s1++, s2++;
  8015ce:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  8015d2:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8015d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8015d9:	8d 50 ff             	lea    -0x1(%eax),%edx
  8015dc:	89 55 10             	mov    %edx,0x10(%ebp)
  8015df:	85 c0                	test   %eax,%eax
  8015e1:	75 c3                	jne    8015a6 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8015e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015e8:	c9                   	leave  
  8015e9:	c3                   	ret    

008015ea <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  8015f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8015f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8015f6:	01 d0                	add    %edx,%eax
  8015f8:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  8015fb:	eb 13                	jmp    801610 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  8015fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801600:	0f b6 10             	movzbl (%eax),%edx
  801603:	8b 45 0c             	mov    0xc(%ebp),%eax
  801606:	38 c2                	cmp    %al,%dl
  801608:	75 02                	jne    80160c <memfind+0x22>
			break;
  80160a:	eb 0c                	jmp    801618 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80160c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801610:	8b 45 08             	mov    0x8(%ebp),%eax
  801613:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  801616:	72 e5                	jb     8015fd <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  801618:	8b 45 08             	mov    0x8(%ebp),%eax
}
  80161b:	c9                   	leave  
  80161c:	c3                   	ret    

0080161d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
  801620:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  801623:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  80162a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801631:	eb 04                	jmp    801637 <strtol+0x1a>
		s++;
  801633:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801637:	8b 45 08             	mov    0x8(%ebp),%eax
  80163a:	0f b6 00             	movzbl (%eax),%eax
  80163d:	3c 20                	cmp    $0x20,%al
  80163f:	74 f2                	je     801633 <strtol+0x16>
  801641:	8b 45 08             	mov    0x8(%ebp),%eax
  801644:	0f b6 00             	movzbl (%eax),%eax
  801647:	3c 09                	cmp    $0x9,%al
  801649:	74 e8                	je     801633 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  80164b:	8b 45 08             	mov    0x8(%ebp),%eax
  80164e:	0f b6 00             	movzbl (%eax),%eax
  801651:	3c 2b                	cmp    $0x2b,%al
  801653:	75 06                	jne    80165b <strtol+0x3e>
		s++;
  801655:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801659:	eb 15                	jmp    801670 <strtol+0x53>
	else if (*s == '-')
  80165b:	8b 45 08             	mov    0x8(%ebp),%eax
  80165e:	0f b6 00             	movzbl (%eax),%eax
  801661:	3c 2d                	cmp    $0x2d,%al
  801663:	75 0b                	jne    801670 <strtol+0x53>
		s++, neg = 1;
  801665:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801669:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801670:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801674:	74 06                	je     80167c <strtol+0x5f>
  801676:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  80167a:	75 24                	jne    8016a0 <strtol+0x83>
  80167c:	8b 45 08             	mov    0x8(%ebp),%eax
  80167f:	0f b6 00             	movzbl (%eax),%eax
  801682:	3c 30                	cmp    $0x30,%al
  801684:	75 1a                	jne    8016a0 <strtol+0x83>
  801686:	8b 45 08             	mov    0x8(%ebp),%eax
  801689:	83 c0 01             	add    $0x1,%eax
  80168c:	0f b6 00             	movzbl (%eax),%eax
  80168f:	3c 78                	cmp    $0x78,%al
  801691:	75 0d                	jne    8016a0 <strtol+0x83>
		s += 2, base = 16;
  801693:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  801697:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  80169e:	eb 2a                	jmp    8016ca <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  8016a0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8016a4:	75 17                	jne    8016bd <strtol+0xa0>
  8016a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a9:	0f b6 00             	movzbl (%eax),%eax
  8016ac:	3c 30                	cmp    $0x30,%al
  8016ae:	75 0d                	jne    8016bd <strtol+0xa0>
		s++, base = 8;
  8016b0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8016b4:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8016bb:	eb 0d                	jmp    8016ca <strtol+0xad>
	else if (base == 0)
  8016bd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8016c1:	75 07                	jne    8016ca <strtol+0xad>
		base = 10;
  8016c3:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8016ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cd:	0f b6 00             	movzbl (%eax),%eax
  8016d0:	3c 2f                	cmp    $0x2f,%al
  8016d2:	7e 1b                	jle    8016ef <strtol+0xd2>
  8016d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d7:	0f b6 00             	movzbl (%eax),%eax
  8016da:	3c 39                	cmp    $0x39,%al
  8016dc:	7f 11                	jg     8016ef <strtol+0xd2>
			dig = *s - '0';
  8016de:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e1:	0f b6 00             	movzbl (%eax),%eax
  8016e4:	0f be c0             	movsbl %al,%eax
  8016e7:	83 e8 30             	sub    $0x30,%eax
  8016ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8016ed:	eb 48                	jmp    801737 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  8016ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f2:	0f b6 00             	movzbl (%eax),%eax
  8016f5:	3c 60                	cmp    $0x60,%al
  8016f7:	7e 1b                	jle    801714 <strtol+0xf7>
  8016f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fc:	0f b6 00             	movzbl (%eax),%eax
  8016ff:	3c 7a                	cmp    $0x7a,%al
  801701:	7f 11                	jg     801714 <strtol+0xf7>
			dig = *s - 'a' + 10;
  801703:	8b 45 08             	mov    0x8(%ebp),%eax
  801706:	0f b6 00             	movzbl (%eax),%eax
  801709:	0f be c0             	movsbl %al,%eax
  80170c:	83 e8 57             	sub    $0x57,%eax
  80170f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801712:	eb 23                	jmp    801737 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  801714:	8b 45 08             	mov    0x8(%ebp),%eax
  801717:	0f b6 00             	movzbl (%eax),%eax
  80171a:	3c 40                	cmp    $0x40,%al
  80171c:	7e 3d                	jle    80175b <strtol+0x13e>
  80171e:	8b 45 08             	mov    0x8(%ebp),%eax
  801721:	0f b6 00             	movzbl (%eax),%eax
  801724:	3c 5a                	cmp    $0x5a,%al
  801726:	7f 33                	jg     80175b <strtol+0x13e>
			dig = *s - 'A' + 10;
  801728:	8b 45 08             	mov    0x8(%ebp),%eax
  80172b:	0f b6 00             	movzbl (%eax),%eax
  80172e:	0f be c0             	movsbl %al,%eax
  801731:	83 e8 37             	sub    $0x37,%eax
  801734:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  801737:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80173a:	3b 45 10             	cmp    0x10(%ebp),%eax
  80173d:	7c 02                	jl     801741 <strtol+0x124>
			break;
  80173f:	eb 1a                	jmp    80175b <strtol+0x13e>
		s++, val = (val * base) + dig;
  801741:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801745:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801748:	0f af 45 10          	imul   0x10(%ebp),%eax
  80174c:	89 c2                	mov    %eax,%edx
  80174e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801751:	01 d0                	add    %edx,%eax
  801753:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  801756:	e9 6f ff ff ff       	jmp    8016ca <strtol+0xad>

	if (endptr)
  80175b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80175f:	74 08                	je     801769 <strtol+0x14c>
		*endptr = (char *) s;
  801761:	8b 45 0c             	mov    0xc(%ebp),%eax
  801764:	8b 55 08             	mov    0x8(%ebp),%edx
  801767:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801769:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  80176d:	74 07                	je     801776 <strtol+0x159>
  80176f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801772:	f7 d8                	neg    %eax
  801774:	eb 03                	jmp    801779 <strtol+0x15c>
  801776:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  801779:	c9                   	leave  
  80177a:	c3                   	ret    

0080177b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80177b:	55                   	push   %ebp
  80177c:	89 e5                	mov    %esp,%ebp
  80177e:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  801781:	a1 24 24 80 00       	mov    0x802424,%eax
  801786:	85 c0                	test   %eax,%eax
  801788:	75 5d                	jne    8017e7 <set_pgfault_handler+0x6c>
		// First time through!
		// LAB 4: Your code here.
		if((r = sys_page_alloc(thisenv->env_id, (void *)UXSTACKTOP-PGSIZE, PTE_U | PTE_W | PTE_P)) < 0) panic("set_pgfault_handler unable to allocate page");
  80178a:	a1 20 24 80 00       	mov    0x802420,%eax
  80178f:	8b 40 48             	mov    0x48(%eax),%eax
  801792:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801799:	00 
  80179a:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8017a1:	ee 
  8017a2:	89 04 24             	mov    %eax,(%esp)
  8017a5:	e8 c2 eb ff ff       	call   80036c <sys_page_alloc>
  8017aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8017ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8017b1:	79 1c                	jns    8017cf <set_pgfault_handler+0x54>
  8017b3:	c7 44 24 08 c4 1f 80 	movl   $0x801fc4,0x8(%esp)
  8017ba:	00 
  8017bb:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8017c2:	00 
  8017c3:	c7 04 24 f0 1f 80 00 	movl   $0x801ff0,(%esp)
  8017ca:	e8 86 f2 ff ff       	call   800a55 <_panic>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8017cf:	a1 20 24 80 00       	mov    0x802420,%eax
  8017d4:	8b 40 48             	mov    0x48(%eax),%eax
  8017d7:	c7 44 24 04 f1 17 80 	movl   $0x8017f1,0x4(%esp)
  8017de:	00 
  8017df:	89 04 24             	mov    %eax,(%esp)
  8017e2:	e8 90 ec ff ff       	call   800477 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8017e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ea:	a3 24 24 80 00       	mov    %eax,0x802424
}
  8017ef:	c9                   	leave  
  8017f0:	c3                   	ret    

008017f1 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8017f1:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8017f2:	a1 24 24 80 00       	mov    0x802424,%eax
	call *%eax
  8017f7:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8017f9:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 40(%esp) , %eax 		//store trap-time eip in eax
  8017fc:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %esp , %ebp 			// save current stack location
  801800:	89 e5                	mov    %esp,%ebp
	movl 48(%esp) , %esp 		// switch to trap time stack
  801802:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 					// push eip, esp gets changed
  801806:	50                   	push   %eax
	movl %esp , 48(%ebp) 		// save current esp to update the trap time esp
  801807:	89 65 30             	mov    %esp,0x30(%ebp)
	movl %ebp , %esp 			// move to user stack
  80180a:	89 ec                	mov    %ebp,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	popl %eax 					// pop fault_va
  80180c:	58                   	pop    %eax
	popl %eax 					// pop tf_err
  80180d:	58                   	pop    %eax
	popal 						// pop all the registers
  80180e:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4 , %esp
  80180f:	83 c4 04             	add    $0x4,%esp
	popfl
  801812:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp
  801813:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  801814:	c3                   	ret    
  801815:	66 90                	xchg   %ax,%ax
  801817:	66 90                	xchg   %ax,%ax
  801819:	66 90                	xchg   %ax,%ax
  80181b:	66 90                	xchg   %ax,%ax
  80181d:	66 90                	xchg   %ax,%ax
  80181f:	90                   	nop

00801820 <__udivdi3>:
  801820:	55                   	push   %ebp
  801821:	57                   	push   %edi
  801822:	56                   	push   %esi
  801823:	83 ec 0c             	sub    $0xc,%esp
  801826:	8b 44 24 28          	mov    0x28(%esp),%eax
  80182a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80182e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801832:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801836:	85 c0                	test   %eax,%eax
  801838:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80183c:	89 ea                	mov    %ebp,%edx
  80183e:	89 0c 24             	mov    %ecx,(%esp)
  801841:	75 2d                	jne    801870 <__udivdi3+0x50>
  801843:	39 e9                	cmp    %ebp,%ecx
  801845:	77 61                	ja     8018a8 <__udivdi3+0x88>
  801847:	85 c9                	test   %ecx,%ecx
  801849:	89 ce                	mov    %ecx,%esi
  80184b:	75 0b                	jne    801858 <__udivdi3+0x38>
  80184d:	b8 01 00 00 00       	mov    $0x1,%eax
  801852:	31 d2                	xor    %edx,%edx
  801854:	f7 f1                	div    %ecx
  801856:	89 c6                	mov    %eax,%esi
  801858:	31 d2                	xor    %edx,%edx
  80185a:	89 e8                	mov    %ebp,%eax
  80185c:	f7 f6                	div    %esi
  80185e:	89 c5                	mov    %eax,%ebp
  801860:	89 f8                	mov    %edi,%eax
  801862:	f7 f6                	div    %esi
  801864:	89 ea                	mov    %ebp,%edx
  801866:	83 c4 0c             	add    $0xc,%esp
  801869:	5e                   	pop    %esi
  80186a:	5f                   	pop    %edi
  80186b:	5d                   	pop    %ebp
  80186c:	c3                   	ret    
  80186d:	8d 76 00             	lea    0x0(%esi),%esi
  801870:	39 e8                	cmp    %ebp,%eax
  801872:	77 24                	ja     801898 <__udivdi3+0x78>
  801874:	0f bd e8             	bsr    %eax,%ebp
  801877:	83 f5 1f             	xor    $0x1f,%ebp
  80187a:	75 3c                	jne    8018b8 <__udivdi3+0x98>
  80187c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801880:	39 34 24             	cmp    %esi,(%esp)
  801883:	0f 86 9f 00 00 00    	jbe    801928 <__udivdi3+0x108>
  801889:	39 d0                	cmp    %edx,%eax
  80188b:	0f 82 97 00 00 00    	jb     801928 <__udivdi3+0x108>
  801891:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801898:	31 d2                	xor    %edx,%edx
  80189a:	31 c0                	xor    %eax,%eax
  80189c:	83 c4 0c             	add    $0xc,%esp
  80189f:	5e                   	pop    %esi
  8018a0:	5f                   	pop    %edi
  8018a1:	5d                   	pop    %ebp
  8018a2:	c3                   	ret    
  8018a3:	90                   	nop
  8018a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8018a8:	89 f8                	mov    %edi,%eax
  8018aa:	f7 f1                	div    %ecx
  8018ac:	31 d2                	xor    %edx,%edx
  8018ae:	83 c4 0c             	add    $0xc,%esp
  8018b1:	5e                   	pop    %esi
  8018b2:	5f                   	pop    %edi
  8018b3:	5d                   	pop    %ebp
  8018b4:	c3                   	ret    
  8018b5:	8d 76 00             	lea    0x0(%esi),%esi
  8018b8:	89 e9                	mov    %ebp,%ecx
  8018ba:	8b 3c 24             	mov    (%esp),%edi
  8018bd:	d3 e0                	shl    %cl,%eax
  8018bf:	89 c6                	mov    %eax,%esi
  8018c1:	b8 20 00 00 00       	mov    $0x20,%eax
  8018c6:	29 e8                	sub    %ebp,%eax
  8018c8:	89 c1                	mov    %eax,%ecx
  8018ca:	d3 ef                	shr    %cl,%edi
  8018cc:	89 e9                	mov    %ebp,%ecx
  8018ce:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8018d2:	8b 3c 24             	mov    (%esp),%edi
  8018d5:	09 74 24 08          	or     %esi,0x8(%esp)
  8018d9:	89 d6                	mov    %edx,%esi
  8018db:	d3 e7                	shl    %cl,%edi
  8018dd:	89 c1                	mov    %eax,%ecx
  8018df:	89 3c 24             	mov    %edi,(%esp)
  8018e2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8018e6:	d3 ee                	shr    %cl,%esi
  8018e8:	89 e9                	mov    %ebp,%ecx
  8018ea:	d3 e2                	shl    %cl,%edx
  8018ec:	89 c1                	mov    %eax,%ecx
  8018ee:	d3 ef                	shr    %cl,%edi
  8018f0:	09 d7                	or     %edx,%edi
  8018f2:	89 f2                	mov    %esi,%edx
  8018f4:	89 f8                	mov    %edi,%eax
  8018f6:	f7 74 24 08          	divl   0x8(%esp)
  8018fa:	89 d6                	mov    %edx,%esi
  8018fc:	89 c7                	mov    %eax,%edi
  8018fe:	f7 24 24             	mull   (%esp)
  801901:	39 d6                	cmp    %edx,%esi
  801903:	89 14 24             	mov    %edx,(%esp)
  801906:	72 30                	jb     801938 <__udivdi3+0x118>
  801908:	8b 54 24 04          	mov    0x4(%esp),%edx
  80190c:	89 e9                	mov    %ebp,%ecx
  80190e:	d3 e2                	shl    %cl,%edx
  801910:	39 c2                	cmp    %eax,%edx
  801912:	73 05                	jae    801919 <__udivdi3+0xf9>
  801914:	3b 34 24             	cmp    (%esp),%esi
  801917:	74 1f                	je     801938 <__udivdi3+0x118>
  801919:	89 f8                	mov    %edi,%eax
  80191b:	31 d2                	xor    %edx,%edx
  80191d:	e9 7a ff ff ff       	jmp    80189c <__udivdi3+0x7c>
  801922:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801928:	31 d2                	xor    %edx,%edx
  80192a:	b8 01 00 00 00       	mov    $0x1,%eax
  80192f:	e9 68 ff ff ff       	jmp    80189c <__udivdi3+0x7c>
  801934:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801938:	8d 47 ff             	lea    -0x1(%edi),%eax
  80193b:	31 d2                	xor    %edx,%edx
  80193d:	83 c4 0c             	add    $0xc,%esp
  801940:	5e                   	pop    %esi
  801941:	5f                   	pop    %edi
  801942:	5d                   	pop    %ebp
  801943:	c3                   	ret    
  801944:	66 90                	xchg   %ax,%ax
  801946:	66 90                	xchg   %ax,%ax
  801948:	66 90                	xchg   %ax,%ax
  80194a:	66 90                	xchg   %ax,%ax
  80194c:	66 90                	xchg   %ax,%ax
  80194e:	66 90                	xchg   %ax,%ax

00801950 <__umoddi3>:
  801950:	55                   	push   %ebp
  801951:	57                   	push   %edi
  801952:	56                   	push   %esi
  801953:	83 ec 14             	sub    $0x14,%esp
  801956:	8b 44 24 28          	mov    0x28(%esp),%eax
  80195a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80195e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801962:	89 c7                	mov    %eax,%edi
  801964:	89 44 24 04          	mov    %eax,0x4(%esp)
  801968:	8b 44 24 30          	mov    0x30(%esp),%eax
  80196c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801970:	89 34 24             	mov    %esi,(%esp)
  801973:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801977:	85 c0                	test   %eax,%eax
  801979:	89 c2                	mov    %eax,%edx
  80197b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80197f:	75 17                	jne    801998 <__umoddi3+0x48>
  801981:	39 fe                	cmp    %edi,%esi
  801983:	76 4b                	jbe    8019d0 <__umoddi3+0x80>
  801985:	89 c8                	mov    %ecx,%eax
  801987:	89 fa                	mov    %edi,%edx
  801989:	f7 f6                	div    %esi
  80198b:	89 d0                	mov    %edx,%eax
  80198d:	31 d2                	xor    %edx,%edx
  80198f:	83 c4 14             	add    $0x14,%esp
  801992:	5e                   	pop    %esi
  801993:	5f                   	pop    %edi
  801994:	5d                   	pop    %ebp
  801995:	c3                   	ret    
  801996:	66 90                	xchg   %ax,%ax
  801998:	39 f8                	cmp    %edi,%eax
  80199a:	77 54                	ja     8019f0 <__umoddi3+0xa0>
  80199c:	0f bd e8             	bsr    %eax,%ebp
  80199f:	83 f5 1f             	xor    $0x1f,%ebp
  8019a2:	75 5c                	jne    801a00 <__umoddi3+0xb0>
  8019a4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8019a8:	39 3c 24             	cmp    %edi,(%esp)
  8019ab:	0f 87 e7 00 00 00    	ja     801a98 <__umoddi3+0x148>
  8019b1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8019b5:	29 f1                	sub    %esi,%ecx
  8019b7:	19 c7                	sbb    %eax,%edi
  8019b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8019bd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8019c1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8019c5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8019c9:	83 c4 14             	add    $0x14,%esp
  8019cc:	5e                   	pop    %esi
  8019cd:	5f                   	pop    %edi
  8019ce:	5d                   	pop    %ebp
  8019cf:	c3                   	ret    
  8019d0:	85 f6                	test   %esi,%esi
  8019d2:	89 f5                	mov    %esi,%ebp
  8019d4:	75 0b                	jne    8019e1 <__umoddi3+0x91>
  8019d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8019db:	31 d2                	xor    %edx,%edx
  8019dd:	f7 f6                	div    %esi
  8019df:	89 c5                	mov    %eax,%ebp
  8019e1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8019e5:	31 d2                	xor    %edx,%edx
  8019e7:	f7 f5                	div    %ebp
  8019e9:	89 c8                	mov    %ecx,%eax
  8019eb:	f7 f5                	div    %ebp
  8019ed:	eb 9c                	jmp    80198b <__umoddi3+0x3b>
  8019ef:	90                   	nop
  8019f0:	89 c8                	mov    %ecx,%eax
  8019f2:	89 fa                	mov    %edi,%edx
  8019f4:	83 c4 14             	add    $0x14,%esp
  8019f7:	5e                   	pop    %esi
  8019f8:	5f                   	pop    %edi
  8019f9:	5d                   	pop    %ebp
  8019fa:	c3                   	ret    
  8019fb:	90                   	nop
  8019fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a00:	8b 04 24             	mov    (%esp),%eax
  801a03:	be 20 00 00 00       	mov    $0x20,%esi
  801a08:	89 e9                	mov    %ebp,%ecx
  801a0a:	29 ee                	sub    %ebp,%esi
  801a0c:	d3 e2                	shl    %cl,%edx
  801a0e:	89 f1                	mov    %esi,%ecx
  801a10:	d3 e8                	shr    %cl,%eax
  801a12:	89 e9                	mov    %ebp,%ecx
  801a14:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a18:	8b 04 24             	mov    (%esp),%eax
  801a1b:	09 54 24 04          	or     %edx,0x4(%esp)
  801a1f:	89 fa                	mov    %edi,%edx
  801a21:	d3 e0                	shl    %cl,%eax
  801a23:	89 f1                	mov    %esi,%ecx
  801a25:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a29:	8b 44 24 10          	mov    0x10(%esp),%eax
  801a2d:	d3 ea                	shr    %cl,%edx
  801a2f:	89 e9                	mov    %ebp,%ecx
  801a31:	d3 e7                	shl    %cl,%edi
  801a33:	89 f1                	mov    %esi,%ecx
  801a35:	d3 e8                	shr    %cl,%eax
  801a37:	89 e9                	mov    %ebp,%ecx
  801a39:	09 f8                	or     %edi,%eax
  801a3b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  801a3f:	f7 74 24 04          	divl   0x4(%esp)
  801a43:	d3 e7                	shl    %cl,%edi
  801a45:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a49:	89 d7                	mov    %edx,%edi
  801a4b:	f7 64 24 08          	mull   0x8(%esp)
  801a4f:	39 d7                	cmp    %edx,%edi
  801a51:	89 c1                	mov    %eax,%ecx
  801a53:	89 14 24             	mov    %edx,(%esp)
  801a56:	72 2c                	jb     801a84 <__umoddi3+0x134>
  801a58:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  801a5c:	72 22                	jb     801a80 <__umoddi3+0x130>
  801a5e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801a62:	29 c8                	sub    %ecx,%eax
  801a64:	19 d7                	sbb    %edx,%edi
  801a66:	89 e9                	mov    %ebp,%ecx
  801a68:	89 fa                	mov    %edi,%edx
  801a6a:	d3 e8                	shr    %cl,%eax
  801a6c:	89 f1                	mov    %esi,%ecx
  801a6e:	d3 e2                	shl    %cl,%edx
  801a70:	89 e9                	mov    %ebp,%ecx
  801a72:	d3 ef                	shr    %cl,%edi
  801a74:	09 d0                	or     %edx,%eax
  801a76:	89 fa                	mov    %edi,%edx
  801a78:	83 c4 14             	add    $0x14,%esp
  801a7b:	5e                   	pop    %esi
  801a7c:	5f                   	pop    %edi
  801a7d:	5d                   	pop    %ebp
  801a7e:	c3                   	ret    
  801a7f:	90                   	nop
  801a80:	39 d7                	cmp    %edx,%edi
  801a82:	75 da                	jne    801a5e <__umoddi3+0x10e>
  801a84:	8b 14 24             	mov    (%esp),%edx
  801a87:	89 c1                	mov    %eax,%ecx
  801a89:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  801a8d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801a91:	eb cb                	jmp    801a5e <__umoddi3+0x10e>
  801a93:	90                   	nop
  801a94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801a98:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  801a9c:	0f 82 0f ff ff ff    	jb     8019b1 <__umoddi3+0x61>
  801aa2:	e9 1a ff ff ff       	jmp    8019c1 <__umoddi3+0x71>
