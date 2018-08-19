module lib.util;

import std.algorithm;
import std.typecons;

T[][] fill2d(T)(ref T[][] xss, T v)
{
  foreach (ref xs; xss) {
    xs.fill(v);
  }
  return xss;
}

int to_color(ubyte r, ubyte g, ubyte b, ubyte a = 0x00)
{
  return (a<<24)|(r<<16)|(g<<8)|b;
}

auto from_color(int c)
{
  return tuple!("a", "r", "g", "b")(
    cast(ubyte)((c & 0xff000000) >> 24),
    cast(ubyte)((c & 0x00ff0000) >> 16),
    cast(ubyte)((c & 0x0000ff00) >> 8),
    cast(ubyte)((c & 0x000000ff) >> 0),
  );
}
