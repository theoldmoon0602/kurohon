module lib.game;
import lib.util;
import lib.image;

import std.format;
import std.string;
import std.range;
import std.algorithm;
public import derelict.sdl2.sdl;

enum BlendMode {
  NOBLEND,
  ALPHABLEND,
  ADDBLEND,
}

interface GameState {
  uint key(long) const;
  Image getScreen() const;
}
interface GameDrawer {
    void setPixel(long x, long y, uint color, BlendMode mode = BlendMode.NOBLEND);
}


class Game : GameState, GameDrawer
{
  protected:
    int[][] pixelbuf;
    int[] screenbuf;

  public:
    SDL_Window* window;
    SDL_Renderer* renderer;
    SDL_Texture* texture;
    uint[256] keystate;

    const uint width = 640;
    const uint height = 480;
    const uint FPS;
    int frame_ms;
    uint last_tick;
    uint[] frameseconds;
    const uint fps_calc_frames = 10;

    this(uint FPS=30)
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
      this.FPS = FPS;
      frame_ms = cast(int)(1.0 / FPS * 1000);
      last_tick = SDL_GetTicks();
      this.frameseconds = [];
    }
    ~this() {
      SDL_Quit();
    }

    bool handleEvent()
    {
      // sleep
      auto now_tick = SDL_GetTicks();
      auto tick_diff = now_tick - last_tick;
      last_tick = now_tick;

      if (frame_ms > tick_diff) {
        SDL_Delay(frame_ms - tick_diff);
      }

      // show frame rate at window title
      frameseconds ~= tick_diff;
      if (frameseconds.length >= fps_calc_frames) {
        auto frame_rate = (1000.0 / frameseconds.sum()) * frameseconds.length;

        SDL_SetWindowTitle(window, "%.1f".format(frame_rate).toStringz);
        frameseconds.length = 0;
      }

      // handle events
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
      screenbuf.length = 0;
      foreach (y; 0..height) {
        foreach (x; 0..width) {
          screenbuf ~= pixelbuf[y][x];
        }
      }
      SDL_UpdateTexture(texture, null, &(screenbuf[0]), cast(int)(width * int.sizeof));
      SDL_SetRenderDrawColor(renderer, 0x00,0x00,0x00,0x00);
      SDL_RenderClear(renderer);
      SDL_RenderCopy(renderer, texture, null, null);
      SDL_RenderPresent(renderer);

      pixelbuf.fill2d(0x00000000);
    }

    uint key(long code) const {
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

    Image getScreen() const {
      auto buf = new uint[](width * height);
      foreach (y; 0..height) {
        foreach (x; 0..width) {
          buf[y*width + x] = 0xff000000 | screenbuf[y*width + x];
        }
      }
      return Image(width, height, buf);
    }
}

