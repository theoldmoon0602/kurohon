module lib.game;
import lib.util;

public import derelict.sdl2.sdl;

struct Image {
  public:
    long w;
    long h;
    uint[] pixels;
}

enum BlendMode {
  NOBLEND,
  ALPHABLEND,
  ADDBLEND,
}

class Game
{
  public:
    SDL_Window* window;
    SDL_Renderer* renderer;
    SDL_Texture* texture;
    uint[256] keystate;
  protected:
    int[][] pixelbuf;

  public:
    const uint width = 640;
    const uint height = 480;

    this()
    {
      DerelictSDL2.load();
      SDL_Init(SDL_INIT_EVERYTHING);

      window = SDL_CreateWindow(
          "Kurohon",
          SDL_WINDOWPOS_UNDEFINED,
          SDL_WINDOWPOS_UNDEFINED,
          width, height,
          SDL_WINDOW_ALLOW_HIGHDPI);
      renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
      texture = SDL_CreateTexture(renderer,
          SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STATIC, width, height);
      pixelbuf = new int[][](height, width);
    }
    ~this() {
      SDL_Quit();
    }

    bool handleEvent()
    {
      SDL_Event e;
      while (SDL_PollEvent(&e) != 0) {
        if (e.type == SDL_QUIT) {
          return false;
        }
      }
      auto state = SDL_GetKeyboardState(null);
      foreach (i, ref k; keystate) {
        if (state[i]) {
          k++;
        }
        else {
          k = 0;
        }
      }

      return true;
    }

    void redraw() {
      int[] vs = [];
      foreach (y; 0..height) {
        foreach (x; 0..width) {
          vs ~= pixelbuf[y][x];
        }
      }
      SDL_UpdateTexture(texture, null, &(vs[0]), cast(int)(width * int.sizeof));
      SDL_SetRenderDrawColor(renderer, 0x00,0x00,0x00,0x00);
      SDL_RenderClear(renderer);
      SDL_RenderCopy(renderer, texture, null, null);
      SDL_RenderPresent(renderer);

      pixelbuf.fill2d(0x00000000);
    }

    uint key(long code) {
      return keystate[code];
    }

    void setPixel(long x, long y, uint color, BlendMode mode = BlendMode.NOBLEND)
    {
      if (x < 0 || width <= x || y < 0 || height <= y) {
        return;
      }
      int c;
      final switch (mode) {
        case BlendMode.NOBLEND:
          c = cast(uint)color;
          break;
        case BlendMode.ALPHABLEND:
        {
          auto c1 = from_color(color);
          auto c2 = from_color(pixelbuf[y][x]);

          double a1 = c1.a / 255.0;
          double a2 = (255 - c1.a) / 255.0;

          auto r = cast(ubyte)(a1 * c1.r + a2 * c2.r);
          auto g = cast(ubyte)(a1 * c1.g + a2 * c2.g);
          auto b = cast(ubyte)(a1 * c1.b + a2 * c2.b);

          c = to_color(r,g,b);
          break;
        }
        case BlendMode.ADDBLEND:
        {
          auto c1 = from_color(color);
          auto c2 = from_color(pixelbuf[y][x]);

          double a1 = c1.a / 255.0;

          auto r = cast(ubyte)(a1 * c1.r + c2.r);
          auto g = cast(ubyte)(a1 * c1.g + c2.g);
          auto b = cast(ubyte)(a1 * c1.b + c2.b);

          c = to_color(r,g,b);
          break;
        }
      }
      pixelbuf[y][x] = c;
    }
}
