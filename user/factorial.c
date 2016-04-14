#include <inc/string.h>
#include <inc/lib.h>

int factorial(int n){
  if(n<0){
    cprintf("invalid argument\n");
    return -1;
  }
  int i,res=1;
  for(i=1; i<=n;i++){
    res *=i;
  }
  return res;
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
  // return factorial(n);
  int f = factorial(n);
  if(f>=0)
    cprintf("%d\n",f);

}
