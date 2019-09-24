// Copy a string in Mini-*-C-*-.
function int strlen(*char string) {
  var int length;
  length = 0;
  while (string) {
    length = length + 1;
    string = string + 1;
  }
  return length;
}

function *char strcpy(*char string) {
  var int length;
  length = strlen(string);
  var *char copy;
  copy = malloc(length+1);
  var *char p;
  p = copy;
  while (string) {
    *p = *string;
    string = string + 1;
    p = copy + 1;
  }
  //*p = 0;
  return copy;
}

function int main(*char input) {
  var int dummy;
  dummy = puts("The copy of the string is ");
  dummy = puts(strcpy(input));
  return 0;
}
