import std.stdio;
import std.conv;
import std.algorithm;
import derelict.sdl2.sdl;

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

void drawStage(SDL_Renderer* renderer, const(char[][]) stage, const(P) player)
{
  SDL_RenderClear(renderer);

  // foreach (y, l; stage) {
  //   foreach (x, c; l) {
  //     if (player == P(y, x)) {
  //       if (c == '.') {
  //         write('P');
  //       }
  //       else {
  //         write('p');
  //       }
  //     }
  //     else {
  //       write(c);
  //     }
  //   }
  //   writeln();
  // }

  SDL_RenderPresent(renderer);
}

bool checkIsGameClear(const(char[][]) stage)
{
  foreach (l; stage) {
    if (l.canFind("o")) { return false; }
  }
  return true;
}


void main() {
  DerelictSDL2.load();
  SDL_Init(SDL_INIT_EVERYTHING);

  auto window = SDL_CreateWindow(
      "Kurohon",
      SDL_WINDOWPOS_UNDEFINED,
      SDL_WINDOWPOS_UNDEFINED,
      640, 480,
      SDL_WINDOW_ALLOW_HIGHDPI);
  auto renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);

  auto stage = [
    "########",
    "# ..   #",
    "# oo   #",
    "#      #",
    "########",
  ].to!(char[][]);
  auto player = P(1, 5);

  drawStage(renderer, stage, player);

  while (true) {
    SDL_Event e;
    Input input = Input.NONE;
    while (SDL_PollEvent(&e) != 0) {
      if (e.type == SDL_QUIT) {
        goto quit;
      }
      else if (e.type == SDL_KEYDOWN) {
        switch (e.key.keysym.sym) {
          case SDLK_w:
            input = Input.UP;
            break;
          case SDLK_a:
            input = Input.LEFT;
            break;
          case SDLK_s:
            input = Input.DOWN;
            break;
          case SDLK_d:
            input = Input.RIGHT;
            break;
          case SDLK_q:
            goto quit;
          default:
            break;
        }
      }
    }
    
    updateGame(stage, player, input);
    drawStage(renderer, stage, player);
    if (checkIsGameClear(stage)) {
      goto quit;
    }
  }

quit:
  SDL_DestroyWindow(window);
  SDL_Quit();
}
