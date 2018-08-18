module lib.util;

import std.algorithm;

T[][] fill2d(T)(ref T[][] xss, T v)
{
  foreach (ref xs; xss) {
    xs.fill(v);
  }
  return xss;
}
