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
  ALPHABLEND
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

    void setPixel(long x, long y, uint c1, BlendMode mode = BlendMode.NOBLEND)
    {
      if (x < 0 || width <= x || y < 0 || height <= y) {
        return;
      }
      int c;
      uint c2 = cast(uint)pixelbuf[y][x];
      final switch (mode) {
        case BlendMode.NOBLEND:
          c = cast(uint)c1;
          break;
        case BlendMode.ALPHABLEND:
        {
          // alpha blending (additional completion)
          int a  = (c1&0xff000000) >> 24;
          int r1 = (c1&0x00ff0000) >> 16;
          int g1 = (c1&0x0000ff00) >> 8;
          int b1 = (c1&0x000000ff);

          int r2 = (c2&0x00ff0000) >> 16;
          int g2 = (c2&0x0000ff00) >> 8;
          int b2 = (c2&0x000000ff);

          double a1 = a / 255.0;
          double a2 = (255 - a) / 255.0;

          int r = cast(int)(a1 * r1 + a2 * r2);
          int g = cast(int)(a1 * g1 + a2 * g2);
          int b = cast(int)(a1 * b1 + a2 * b2);

          c = (r<<16)|(g<<8)|b;
          break;
        }
      }
      pixelbuf[y][x] = c;
    }
}
