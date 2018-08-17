import std.stdio;
import std.conv;
import std.algorithm;
import lib.game;

struct P
{
  public:
    long y = 0;
    long x = 0;
}

enum Input
{
  NONE,
  UP,
  DOWN,
  LEFT,
  RIGHT,
}


void updateGame(ref char[][] stage, ref P player, Input input)
{
  P newp = player;
  P dp;
  final switch (input) {
    case Input.NONE:
      return;

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


void drawRect(ref int[][] pixels, long x, long y, long w, long h, int color)
{
  foreach (dy; 0..h) {
    pixels[y+dy][x] = color;
    pixels[y+dy][x+w-1] = color;
  }
  foreach (dx; 0..w) {
    pixels[y][x+dx]= color;
    pixels[y+h-1][x+dx]= color;
  }
}

void fillRect(ref int[][] pixels, long x, long y, long w, long h, int color)
{
  foreach (dx; 0..w) {
    foreach (dy; 0..h) {
      pixels[y+dy][x+dx] = color;
    }
  }
}

void drawStage(Game game, const(char[][]) stage, const(P) player)
{
  auto pixels = new int[][](game.width, game.height);

  foreach (y, l; stage) {
    foreach (x, c; l) {
      auto color = 0xffffff;
      if (c == '.') {
        color = 0x0000ff;
      }
      else if (c == 'o') {
        color = 0xff00ff;
      }
      else if (c == 'O') {
        color = 0x00ffff;
      }
      else if (c == '#') {
        color = 0xcccccc;
      }
      pixels.fillRect(y * 20, x * 20, 20, 20, color);

      if (player == P(y, x)) {
        pixels.drawRect(y * 20, x * 20, 20, 20, 0xff0000);
      }
    }
  }

  game.draw(pixels);
}

bool checkIsGameClear(const(char[][]) stage)
{
  foreach (l; stage) {
    if (l.canFind("o")) { return false; }
  }
  return true;
}


void main() {
  auto game = new Game();

  auto stage = [
    "########",
    "# ..   #",
    "# oo   #",
    "#      #",
    "########",
  ].to!(char[][]);
  auto player = P(1, 5);

  drawStage(game, stage, player);
  while (game.handleEvent()) {
    Input input = Input.NONE;
    if (game.key(SDL_SCANCODE_Q) == 1) {
      break;
    }
    else if (game.key(SDL_SCANCODE_W) == 1) {
      input = Input.UP;
    }
    else if (game.key(SDL_SCANCODE_A) == 1) {
      input = Input.LEFT;
    }
    else if (game.key(SDL_SCANCODE_S) == 1) {
      input = Input.DOWN;
    }
    else if (game.key(SDL_SCANCODE_D) == 1) {
      input = Input.RIGHT;
    }

    updateGame(stage, player, input);
    drawStage(game, stage, player);
    if (checkIsGameClear(stage)) {
      break;
    }
  }
}
