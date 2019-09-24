// Compute string length in Mini-*-C-*-.
function int strlen(*char string) {
  var int length;
  length = 0;
  while (*string) {
    length = length + 1;
    string = string + 1;
  }
  return length;
}

function int main(*char input) {
  var int dummy;
  dummy = puts("The length of the string is ");
  dummy = puti(strlen(input));
  return 0;
}
