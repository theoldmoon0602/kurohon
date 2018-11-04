import lib;

import scenes.title;

void main() {
  auto game = new Game();
  Scene curScene = new TitleScene();
  curScene.load();

  while (game.handleEvent()) {
    if (game.key(SDL_SCANCODE_Q) > 0) {
      break;
    }
    
    Scene nextScene = curScene.update(game);
    game.wait();
    curScene.draw(game);
    game.redraw();

    if (nextScene is null) {
      break;
    }
    if (nextScene != curScene) {
      curScene = nextScene;
      if (!curScene.isLoaded()) {
        curScene.load();
      }
    }
  }
}
