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

    int frame_ms;
    uint last_tick;
    uint last_calc_tick;
    uint fps_calc_count;
  public:
    SDL_Window* window;
    SDL_Renderer* renderer;
    SDL_Texture* texture;
    uint[256] keystate;

    const uint width = 640;
    const uint height = 480;
    const uint FPS;
    const uint FPS_CALC_MSECONDS = 5000;

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
      this.fps_calc_count = 0;
      frame_ms = cast(int)(1000.0 / FPS);
      last_tick = SDL_GetTicks();
      last_calc_tick = last_tick;
    }
    ~this() {
      SDL_Quit();
    }

    /// wait some milliseconds 
    void wait() {
      // sleep
      auto now_tick = SDL_GetTicks();
      // show frame rate at window title
      if ((now_tick - last_calc_tick) > FPS_CALC_MSECONDS) {
        auto fps = cast(double)(fps_calc_count) * 1000.0 / FPS_CALC_MSECONDS;
        SDL_SetWindowTitle(window, "%.1f".format(fps).toStringz());
        fps_calc_count = 0;
        last_calc_tick = now_tick;
      }
      fps_calc_count++;

      auto tick_diff = now_tick - last_tick;
      last_tick = now_tick;

      if (frame_ms > tick_diff) {
        SDL_Delay(frame_ms - tick_diff);
      }

    }

    bool handleEvent()
    {
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

