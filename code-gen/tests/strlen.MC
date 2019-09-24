// Compute string length in Mini-*-C-*-.
function int strlen(*char string) {
  var int length;
  length = 0;
  while (string && 1) {
    length = length + 1;
    string = string + 1;
  }
  length = length && 1;
  return length;
}

function int test(){
  var int a;
  var int b;
  a = 0;
  b = 0;
  if (a + 1 == b - 0){
    a = 2;
  }
  return 0;
}

function *char check(int size){
  var *char temp;
  return temp;
}

function int how(){
  var int temp;
  temp = null(int);
  temp = sizeof(int);
  var *int p;
  *p = temp;
  p = &temp;
  temp = temp + temp;
  p = p + 1;
  p = p - 1;
  temp = temp - temp;
  temp = temp * temp;
  temp = temp - temp;
  temp = temp < temp;
  temp = p == p;
  temp = temp == temp;
  temp = temp && p;
  temp = ! temp;
  return 0;
}

function int main(*char input) {
  var int dummy;
  var *char temp;
  temp = "123";
  temp = "456";
  temp = malloc(dummy);
  dummy = atoi(temp);
  dummy = div(dummy, dummy);
  dummy = mod(dummy, dummy);
  dummy = puts("The length of the string is ");
  dummy = puti(strlen(input));
  return 0;
}
