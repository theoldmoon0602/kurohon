import std.stdio;

struct P
{
  public:
    long y;
    long x;
}

enum Input
{
  UP,
  DOWN,
  LEFT,
  RIGHT,
  EXIT
}


void drawStage(const(string[]) stage, const(P) player)
{
  foreach (y, l; stage) {
    foreach (x, c; l) {
      if (player == P(y, x)) {
        write('p');
      }
      else {
        write(c);
      }
    }
    writeln();
  }
}

Input getInput()
{
  writeln("WASD or Q");
  while (true) {
    char c;
    readf("%c", &c);
    
    if (c == 'w') {
      return Input.UP;
    }
    else if (c == 'a') {
      return Input.LEFT;
    }
    else if (c == 's') {
      return Input.DOWN;
    }
    else if (c == 'd') {
      return Input.RIGHT;
    }
    else if (c == 'q') {
      return Input.EXIT;
    }
  }
}


void main()
{
  string[] stage = [
    "########",
    "# ..   #",
    "# oo   #",
    "#      #",
    "########",
  ];
  auto player = P(1, 5);
  
  while (true) {
    drawStage(stage, player);
    auto input = getInput();
    if (input == Input.EXIT) { break; }
  }
}
