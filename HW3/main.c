#include <stdio.h>


void delay(int ms);
void digitalWrite(int pin, int value);
void codegen() asm("codegen");

int main()
{
  codegen();
  return 0;
}


void delay(int ms)
{
  printf("Arduino delay(%d);\n", ms);
}


void digitalWrite(int pin, int value)
{
  printf("Arduino digitalWrite(%d, %d);\n", pin, value);
}

