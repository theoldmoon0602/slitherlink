import std.stdio;
import std.string;
import std.algorithm;
import std.conv;
import std.range;
import std.math;

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

void print(int[][] vs, int[][][] grid)
{
  // grid line
  foreach (y; 0..vs.length) {
    writeln(grid[YOKO][y][0..$-1].map!(x => "+"~gridconv(x, true)).join("") ~ "+");
    grid[TATE][y].map!(x => gridconv(x, false)).zip(vs[y].map!(numconv)).map!"a[0]~a[1]".array.join("").writeln;
  }
  writeln(grid[YOKO][$-1][0..$-1].map!(x => "+"~gridconv(x, true)).join("") ~ "+");
}

bool inrange(ulong size, long y, long x)
{
  return 0 <= x && x < size && 0 <= y && y < size;
}

int distance(int y1, int x1,int y2, int x2)
{
  return abs(x1-x2) + abs(y1-y2);
}

void set(ref int[][][] grid, long d, long y, long x, int v)
{
  if (inrange(grid[0].length, y, x)) {
    grid[d][y][x] = v;
  }
}

void solveit(ref int[][] vs, ref int[][][] grid)
{
  int[] zx = [];
  int[] zy = [];

  int[] tx = [];
  int[] ty = [];

  // mark zero
  foreach (y; 0..vs.length) {
    foreach (x; 0..vs[0].length) {
      if (vs[y][x] == 3) {
        tx ~= cast(int)x;
        ty ~= cast(int)y;
      }
      else if (vs[y][x] == 0) {
        zx ~= cast(int)x;
        zy ~= cast(int)y;

        grid.set(TATE, y, x, FORBID);
        grid.set(TATE, y, x+1, FORBID);
        grid.set(YOKO, y, x, FORBID);
        grid.set(YOKO, y+1, x, FORBID);
      }
    }
  }

  auto dy = [-1, 0, 0, 1];
  auto dx = [0, -1, 1, 0];

  auto c = (int x) {
    if (x == -1) {
      return 0;
    }
    return x;
  };

  // line 3 around zero 
  foreach (i; 0..zx.length) {
    foreach (j; 0..dx.length) {
      auto x = zx[i] + dx[j];
      auto y = zy[i] + dy[j];
      if (!inrange(vs.length, y, x)) { continue; }
      if (vs[y][x] == 3) {
        // 3を囲う
        grid.set(abs(dx[j]), y + c(dy[j]), x + c(dx[j]), LINE);
        grid.set(1-abs(dx[j]), y, x, LINE);
        grid.set(1-abs(dx[j]), y + abs(dx[j]), x + abs(dy[j]), LINE);

        // 周りに x を
        grid.set(abs(dx[j]), y + c(dy[j]) + dx[j], x + c(dx[j]) + dy[j], FORBID);
        grid.set(abs(dx[j]), y + c(dy[j]) - dx[j], x + c(dx[j]) - dy[j], FORBID);

        grid.set(1-abs(dx[j]), y + dy[j], x + dx[j], FORBID);
        grid.set(1-abs(dx[j]), y + abs(dx[j]) + dy[j], x + abs(dy[j]) + dx[j], FORBID);
      }
    }
  }

  // // 隣接する 3
  // foreach (i; 0..tx.length) {
  //   foreach (j; 0..tx.length) {
  //     if (i == j) { continue; }
  //     if (distance(tx[i], ty[i], tx[j], ty[j]) == 1) {
  //       // 横隣接
  //       if (ty[i] == ty[j]) {
  //         grid[TATE][ty[i]][tx[i]] = LINE;
  //         grid[TATE][ty[i]][tx[i]+1] = LINE;
  //         grid[TATE][ty[j]][tx[j]] = LINE;
  //         grid[TATE][ty[j]][tx[j]+1] = LINE;
  //       }

  //       // 縦隣接
  //       else if (tx[i] == tx[j]) {
  //         grid[YOKO][ty[i]][tx[i]] = LINE;
  //         grid[YOKO][ty[i] + 1][tx[i]] = LINE;
  //         grid[YOKO][ty[j]][tx[j]] = LINE;
  //         grid[YOKO][ty[j] + 1][tx[j]] = LINE;
  //       }
  //     }
  //   }
  // }
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
  solveit(vs, grid);
  print(vs, grid);

  foreach (gri; grid) {
    foreach (g; gri) {
      writeln(g);
    }
    writeln();
  }

}

