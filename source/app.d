import std.stdio;
import std.conv;
import std.algorithm;
import std.range;
import imageformats;
import lib.game;
import lib.util;

Image wallImg;
Image playerImg;
Image mapImg;
Image boxImg;
Image goalImg;

struct P
{
  public:
    long x = 0;
    long y = 0;
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


void drawImage(Game game, long x, long y, Image img)
{
  foreach (dy; 0..img.h) {
    foreach (dx; 0..img.w) {
      game.setPixel(x + dx, y + dy, img.pixels[dy * img.w + dx], BlendMode.ALPHABLEND);
    }
  }
}

void drawStage(Game game, const(char[][]) stage, const(P) player)
{
  foreach (y, l; stage) {
    foreach (x, c; l) {

      auto img = mapImg;
      if (c == '.') {
        img = goalImg;
      }
      else if (c == 'o') {
        img = boxImg;
      }
      else if (c == 'O') {
        img = boxImg;
      }
      else if (c == '#') {
        img = wallImg;
      }

      game.drawImage(x * 32, y * 32, mapImg);
      game.drawImage(x * 32, y * 32, img);

      if (player == P(x, y)) {
        game.drawImage(x * 32, y * 32, playerImg);
      }
    }
  }
}

bool checkIsGameClear(const(char[][]) stage)
{
  foreach (l; stage) {
    if (l.canFind("o")) { return false; }
  }
  return true;
}

Image loadImage(string filepath)
{
    auto img = read_image(filepath, ColFmt.RGBA);
    uint[] pixels = [];
    foreach (rgba; img.pixels.chunks(4)) {
      pixels ~= cast(uint)((rgba[3]<<24)|(rgba[0]<<16)|(rgba[1]<<8)|rgba[2]);
    }
    return Image(img.w, img.h, pixels);
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
  auto player = P(5, 1);

  wallImg = loadImage("wall.png");
  playerImg = loadImage("player.png");
  boxImg = loadImage("box.png");
  mapImg = loadImage("map.png");
  goalImg = loadImage("goal.png");

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
    game.redraw();
    if (checkIsGameClear(stage)) {
      break;
    }
  }
}
