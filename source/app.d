import std.stdio;
import std.conv;

struct P
{
  public:
    long y = 0;
    long x = 0;
}

enum Input
{
  UP,
  DOWN,
  LEFT,
  RIGHT,
  EXIT
}


void updateGame(ref char[][] stage, ref P player, Input input)
{
  P newp = player;
  P dp;
  final switch (input) {
    case Input.UP:
      newp.y--;
      dp.y--;
      break;
    case Input.DOWN:
      newp.y++;
      dp.y++;
      break;
    case Input.LEFT:
      newp.x--;
      dp.x--;
      break;
    case Input.RIGHT:
      newp.x++;
      dp.x++;
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
  
  auto c = stage[newp.y][newp.x];
  if (c == '#') {
    return;
  }
  
  if (c == 'o' || c == 'O') {
    auto c2 = stage[newp.y + dp.y][newp.x + dp.x];
    if (c2 == ' ') {
      stage[newp.y + dp.y][newp.x + dp.x] = 'o';
      stage[newp.y][newp.x] = (c == 'o') ? ' ' : '.';
    } else if (c2 == '.') {
      stage[newp.y + dp.y][newp.x + dp.x] = 'O';
      stage[newp.y][newp.x] = (c == 'o') ? ' ' : '.';
    }
    else {
      return;
    }
  }
  
  player = newp;
}

void drawStage(const(char[][]) stage, const(P) player)
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
  auto stage = [
    "########",
    "# ..   #",
    "# oo   #",
    "#      #",
    "########",
  ].to!(char[][]);
  auto player = P(1, 5);
  
  drawStage(stage, player);
  while (true) {
    auto input = getInput();
    if (input == Input.EXIT) { break; }
    updateGame(stage, player, input);
    drawStage(stage, player);
  }
}
