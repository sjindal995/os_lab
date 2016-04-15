#include <inc/string.h>
#include <inc/lib.h>

uint64_t factorial(int n){
  if(n<0){
    cprintf("invalid argument\n");
    return -1;
  }
  int i;
  uint64_t res=1;
  for(i=1; i<=n;i++){
    res *= i;
  }
  return res;
}

void
umain(int argc, char **argv)
{
  if(argc<1)
  {
    cprintf("not enough arguments: %d\n",argc);
    return;
  }
  char* endptr;
  int n = strtol((const char*)argv[0], &endptr, 10 );
  // return factorial(n);
  uint64_t f = factorial(n);
  if(f>=0)
    cprintf("%lld\n",f);

}
