import std.stdio;
import std.string;
import std.algorithm;
import std.conv;
import std.range;
import std.math;
import std.typecons;

enum YOKO = 0;
enum TATE = 1;

enum EMPTY = 0;
enum LINE = 1;
enum FORBID = 2;

string gridconv(int v, bool yoko)
{
  if (v == EMPTY) {
    return " ";
  }
  if (v == LINE) {
    return (yoko) ? "-" : "|";
  }
  if (v == FORBID) {
    return "x";
  }
  throw new Exception("invalid");
}

string numconv(int v)
{
  if (v == 4) {
    return " ";
  }
  return v.to!string;
}



bool inrange(ulong size, long y, long x)
{
  return 0 <= x && x < size && 0 <= y && y < size;
}

int distance(int y1, int x1,int y2, int x2)
{
  return abs(x1-x2) + abs(y1-y2);
}

long get(const(int[][]) vs, long[] p)
{
  return vs[p[0]][p[1]];
}

long get(const(int[][][]) grid, long[] p, long[] dd)
{
  long y = p[0]; long x = p[1];
  long dy = dp[0]; long dx = dp[1];

  auto d = (dy == 0)?TATE:YOKO;
  if (d == TATE && dx == -1) { dx = 0; }
  if (d == YOKO && dy == -1) { dy = 0; }

  y += dy;
  x += dx;

  if (inrange(grid[0].length, y, x)) {
    return grid[d][y][x];
  }
  return -1;
}

void set(ref int[][][] grid, long[] p, long[] dp, int v)
{
  long y = p[0]; long x = p[1];
  long dy = dp[0]; long dx = dp[1];

  auto d = (dy == 0)?TATE:YOKO;
  if (d == TATE && dx == -1) { dx = 0; }
  if (d == YOKO && dy == -1) { dy = 0; }

  y += dy;
  x += dx;

  if (inrange(grid[0].length, y, x)) {
    grid[d][y][x] = v;
  }
}

void print(int[][] vs, int[][][] grid)
{
  // grid line
  foreach (y; 0..vs.length) {
    writeln(grid[YOKO][y][0..$-1].map!(x => "+"~gridconv(x, true)).join("") ~ "+");
    grid[TATE][y].map!(x => gridconv(x, false)).zip(vs[y].map!(numconv)).map!"a[0]~a[1]".array.join("").writeln;
  }
  writeln(grid[YOKO][$-1][0..$-1].map!(x => "+"~gridconv(x, true)).join("") ~ "+");
}

long[][] scan() {
  return [
    [-1, 0],
    [0, -0],
    [0, 1],
    [1, 0],
  ];
}

void solve(const(int[][]) vs, ref int[][][] grid)
{
  // mark zero
  long[][] zeros = [];
  foreach (y; 0..vs.length) {
    foreach (x; 0..vs[y].length) {
      if (get([y, x]) == 0) {
        zeros ~= [y, x];

        // HERE
        foreach (dp; scan) {
        }

      }
    }
  }


}

void main()
{
  int n;
  write("size:");
  readf("%d\n", &n);

  int[][] vs = [];
  auto grid = new int[][][](2, n+1, n+1);

  foreach (y; 0..n) {
    auto l = readln.strip.split("").to!(int[]);
    vs ~= l;
  }

  writeln();
  solve(vs, grid);
  print(vs, grid);

}

