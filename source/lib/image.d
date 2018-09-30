module lib.image;
import lib.game;

import std.range;

import imageformats;

struct Image {
  public:
    long w;
    long h;
    uint[] pixels;
}

void drawImage(GameDrawer drawer, long x, long y, Image img)
{
  foreach (dy; 0..img.h) {
    foreach (dx; 0..img.w) {
      drawer.setPixel(x + dx, y + dy, img.pixels[dy * img.w + dx], BlendMode.ALPHABLEND);
    }
  }
}

Image loadImage(string filepath)
{
    auto img = read_image(filepath, ColFmt.RGBA);
    uint[] pixels = [];
    foreach (rgba; img.pixels.chunks(4)) {
      pixels ~= cast(uint)((rgba[3]<<24)|(rgba[0]<<16)|(rgba[1]<<8)|rgba[2]);
    }
    return Image(img.w, img.h, pixels);
}
