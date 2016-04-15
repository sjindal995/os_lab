#include <inc/string.h>
#include <inc/lib.h>

uint64_t fibonacci(int n){
  if(n<0){
    cprintf("invalid paramter\n");
    return -1;
  }
  int i;
  uint64_t m1,m2,curr;
  m1=0;
  m2=1;
  curr=0;
  for(i=1; i<=n; i++){
    curr = m1+m2;
    m2 = m1;
    m1 = curr;
  }
  return curr;



}

void
umain(int argc, char **argv)
{
  if(argc<1)
  {
    cprintf("not enough arguments\n");
    return;
  }
  char* endptr;
  int n = strtol((const char*)argv[0], &endptr, 10 );
  uint64_t f = fibonacci(n);
  if(f>=0){
    cprintf("%lld\n",f);
  }


}
