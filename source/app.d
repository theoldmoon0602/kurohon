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


void updateGame(ref string[] stage, ref P player, Input input)
{
  P newp = player;
  final switch (input) {
    case Input.UP:
      newp.y--;
      break;
    case Input.DOWN:
      newp.y++;
      break;
    case Input.LEFT:
      newp.x--;
      break;
    case Input.RIGHT:
      newp.x++;
      break;
    case Input.EXIT:
      throw new Exception("Program error");
  }
  
  if (newp.y < 0 || newp.y >= stage.length) {
    return;
  }
  if (newp.x < 0 || newp.x >= stage[newp.y].length) {
    return;
  }
  if (stage[newp.y][newp.x] == '#') {
    return;
  }
  
  player = newp;
}

void drawStage(const(string[]) stage, const(P) player)
{
  foreach (y, l; stage) {
    foreach (x, c; l) {
      if (player == P(y, x)) {
        if (c == '.') {
          write('P');
        }
        else {
          write('p');
        }
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
  
  drawStage(stage, player);
  while (true) {
    auto input = getInput();
    if (input == Input.EXIT) { break; }
    updateGame(stage, player, input);
    drawStage(stage, player);
  }
}
