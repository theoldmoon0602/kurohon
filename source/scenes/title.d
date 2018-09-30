module scenes.title;

import lib;
import scenes.game;

class TitleScene : Scene
{
protected:
  Image title;
  bool is_loaded;
public:
    this()
    {
      this.is_loaded = false;
    }

    bool isLoaded() const { return is_loaded; }
    void load()
    {
      title = loadImage("title.png");
      is_loaded = true;
    }

    Scene update(const(GameState) state)
    {
      if (state.key(SDL_SCANCODE_SPACE) == 1) {
        return new GameScene();
      }
      return this;
    }

    void draw(GameDrawer drawer)
    {
      drawer.drawImage(0, 0, title);
    }
}
