// Compute string length in Mini-*-C-*-.
function int strlen(*char string) {
  var int length;
  length = 0;
  while (string) {
    length = length + 1;
    string = string + 1;
  }
  return length;
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
  temp = temp / temp;
  temp = temp % temp;
  temp = temp - temp;
  temp = temp < temp;
  temp = p == p;
  temp = temp == temp;
  temp = temp && p;
  return 0;
}

function int main(*char input) {
  var int dummy;
  var *char temp;
  temp = malloc(dummy);
  dummy = atoi(temp);
  dummy = div(dummy, dummy);
  dummy = mod(dummy, dummy);
  dummy = puts("The length of the string is ");
  dummy = puti(strlen(input));
  return 0;
}
