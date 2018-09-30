module scenes.game;

import std.conv;
import std.algorithm;
import std.range;
import lib;

struct P
{
public:
    long x = 0;
    long y = 0;
}

enum Input
{
    NONE,
    UP,
    DOWN,
    LEFT,
    RIGHT,
}

class GameScene : Scene
{
protected:
    Image wallImg;
    Image playerImg;
    Image mapImg;
    Image boxImg;
    Image goalImg;

    char[][] stage;

    P player;

    Input keyInput(const(GameState) state) const
    {
        auto input = Input.NONE;

        if (state.key(SDL_SCANCODE_W) == 1)
        {
            input = Input.UP;
        }
        else if (state.key(SDL_SCANCODE_A) == 1)
        {
            input = Input.LEFT;
        }
        else if (state.key(SDL_SCANCODE_S) == 1)
        {
            input = Input.DOWN;
        }
        else if (state.key(SDL_SCANCODE_D) == 1)
        {
            input = Input.RIGHT;
        }
        return input;
    }

    bool checkIsGameClear() const
    {
        foreach (l; stage)
        {
            if (l.canFind("o"))
            {
                return false;
            }
        }
        return true;
    }

public:
    this()
    {
    }

    void load()
    {
        wallImg = loadImage("wall.png");
        playerImg = loadImage("player.png");
        boxImg = loadImage("box.png");
        mapImg = loadImage("map.png");
        goalImg = loadImage("goal.png");

        stage = ["########", "# ..   #", "# oo   #", "#      #", "########",].to!(char[][]);
        player = P(5, 1);
    }

    Scene update(const(GameState) state)
    {
        const input = this.keyInput(state);
        P newp = player;
        P dp;
        final switch (input)
        {
        case Input.NONE:
            return this;

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

        if (newp.y < 0 || newp.y >= stage.length)
        {
            return this;
        }
        if (newp.x < 0 || newp.x >= stage[newp.y].length)
        {
            return this;
        }

        const c = stage[newp.y][newp.x];
        if (c == '#')
        {
            return this;
        }

        if (c == 'o' || c == 'O')
        {
            const c2 = stage[newp.y + dp.y][newp.x + dp.x];
            if (c2 == ' ')
            {
                stage[newp.y + dp.y][newp.x + dp.x] = 'o';
                stage[newp.y][newp.x] = (c == 'o') ? ' ' : '.';
            }
            else if (c2 == '.')
            {
                stage[newp.y + dp.y][newp.x + dp.x] = 'O';
                stage[newp.y][newp.x] = (c == 'o') ? ' ' : '.';
            }
            else
            {
                return this;
            }
        }

        player = newp;
        return this;
    }

    void draw(GameDrawer drawer)
    {
        foreach (y, l; stage)
        {
            foreach (x, c; l)
            {

                auto img = mapImg;
                if (c == '.')
                {
                    img = goalImg;
                }
                else if (c == 'o')
                {
                    img = boxImg;
                }
                else if (c == 'O')
                {
                    img = boxImg;
                }
                else if (c == '#')
                {
                    img = wallImg;
                }

                drawer.drawImage(x * 32, y * 32, mapImg);
                drawer.drawImage(x * 32, y * 32, img);

                if (player == P(x, y))
                {
                    drawer.drawImage(x * 32, y * 32, playerImg);
                }
            }
        }
    }
}
