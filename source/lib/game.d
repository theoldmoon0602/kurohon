module lib.game;

public import derelict.sdl2.sdl;

class Game
{
  public:
    SDL_Window* window;
    SDL_Renderer* renderer;
    SDL_Texture* texture;
    uint[256] keystate;
    int[][] pixelbuf;

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
    }

    uint key(long code) {
      return keystate[code];
    }

}
