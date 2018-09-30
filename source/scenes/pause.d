module scenes.pause;

import lib;

class PauseScene : Scene
{
  protected:
    Scene prev;
    Image pause;
    Image screen;
  public:
    this(Scene prev, Image screen)
    {
      this.prev = prev;
      this.screen = screen;
    }

    bool isLoaded() const {
      return false;
    }
    void load()
    {
      pause = loadImage("pause.png");
    }

    Scene update(const(GameState) state)
    {
      if (state.key(SDL_SCANCODE_SPACE) == 1) {
        return prev;
      }
      return this;
    }

    void draw(GameDrawer drawer)
    {
      drawer.drawImage(0, 0, screen);
      drawer.drawImage(0, 0, pause);
    }
}
