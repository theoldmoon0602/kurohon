import std.stdio;

struct P
{
  public:
    long y;
    long x;
}


void drawStage(const(string[]) stage, const(P) player)
{
  foreach (y, l; stage) {
    foreach (x, c; l) {
      if (player == P(y, x)) {
        write('p');
      }
      else {
        write(c);
      }
    }
    writeln();
  }
}


void main()
{
  string[] stage = [
    "########",
    "# ..   #",
    "# oo   #",
    "#      #",
    "########",
  ];
  auto player = P(1, 5);
  
  drawStage(stage, player);
}
