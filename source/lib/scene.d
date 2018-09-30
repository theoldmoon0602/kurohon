module lib.scene;

import lib;

interface Scene {
    Scene update(const(GameState) state);
    void draw(GameDrawer drawer);
    void load();
}
