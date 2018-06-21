import std.stdio;
import std.string;
import std.algorithm;
import std.conv;
import std.range;
import std.math;
import std.typecons;
import std.traits;

enum YOKO = 0;
enum TATE = 1;

enum EMPTY = 0;
enum EDGE = 1;
enum FORBID = 2;

string gridconv(int v, bool yoko)
{
  if (v == EMPTY) {
    return " ";
  }
  if (v == EDGE) {
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



bool inrange(T)(T[] c, long y, long x)
{
  auto size = c.length;
  return 0 <= x && x < size && 0 <= y && y < size;
}

long distance4(long[] p1, long[] p2)
{
  return abs(p1[0]-p2[0]) + abs(p1[1]-p2[1]);
}

long get(const(int[][]) vs, long[] p, long[] dp = [0, 0])
{
  long y = p[0] + dp[0];
  long x = p[1] + dp[1];

  if (vs.inrange(y, x)) {
    return vs[y][x];
  }
  return 4;
}

long get(const(int[][][]) grid, long[] p, long[] dp = [0, 0])
{
  long y = p[0]; long x = p[1];
  long dy = dp[0]; long dx = dp[1];

  auto d = (dy == 0)?TATE:YOKO;
  if (d == TATE && dx == -1) { dx = 0; }
  if (d == YOKO && dy == -1) { dy = 0; }

  y += dy;
  x += dx;

  if (grid[d].inrange(y, x)) {
    return grid[d][y][x];
  }
  return 4;
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

  if (grid[d].inrange(y, x)) {
    grid[d][y][x] = v;
  }
}

void print(int[][] vs, int[][][] grid)
{
  // grid EDGE
  foreach (y; 0..vs.length) {
    writeln(grid[YOKO][y][0..$-1].map!(x => "+"~gridconv(x, true)).join("") ~ "+");
    grid[TATE][y].map!(x => gridconv(x, false)).zip(vs[y].map!(numconv)).map!"a[0]~a[1]".array.join("").writeln;
  }
  writeln(grid[YOKO][$-1][0..$-1].map!(x => "+"~gridconv(x, true)).join("") ~ "+");
}

long[][] scan(int mode = -1) {
  if (mode == TATE) {
    return [
      [-1, 0], [1, 0]
    ];
  }
  if (mode == YOKO) {
    return [
      [0, -1], [0, 1]
    ];
  }
  return [
    [-1, 0],
    [0, -1],
    [0, 1],
    [1, 0],
  ];
}

long[] rev(long[] a) {
  return a.map!(x => -x).array;
}

long[][] rotdp(long[] dp) {
  return scan.remove!(x => x == dp || x == dp.rev);
}

long[] shift(long[] a, long[] b) {
  return a.zip(b).map!"a[0] + a[1]".array;
}

void try_surround3(ref int[][][] grid, long[] p)
{
  int[] cnt = [0, 0, 0];
  foreach (dp; scan) {
    cnt[grid.get(p, dp)]++;
  }

  bool is_surrounded = false;
  if (cnt[FORBID] == 1) {
    foreach (dp; scan) {
      if (grid.get(p, dp) != FORBID) {
        grid.set(p, dp, EDGE);
      }
    }
    is_surrounded = true;
  }
  else if (cnt[EDGE] == 3 && cnt[EMPTY] == 1) {
    foreach (dp; scan) {
      if (grid.get(p, dp) != EDGE) {
        grid.set(p, dp, FORBID);
        break;
      }
    }
    is_surrounded = true;
  }

  if (is_surrounded) {
    surrounded3(grid, p);
  }

}

void surrounded3(ref int[][][] grid, long[] p)
{
  foreach (dp; scan) {
    if (grid.get(p, dp) == FORBID) {
      foreach (rdp; rotdp(dp)) {
        grid.set(p.shift(dp.rev).shift(rdp), dp, FORBID);
        grid.set(p.shift(dp.rev).shift(rdp), rdp.rev, FORBID);
      }
      break;
    }
  }
}

void solve(const(int[][]) vs, ref int[][][] grid)
{
  long[][] zeros = [];
  long[][] threes = [];

  foreach (y; 0..vs.length) {
    foreach (x; 0..vs[y].length) {
      if (vs.get([y, x]) == 3) {
        threes ~= [y, x];
      }
      if (vs.get([y, x]) == 0) {
        zeros ~= [y, x];

        // mark forbid around zero
        foreach (dp; scan) {
          grid.set([y, x], dp, FORBID);          
        }
      }
    }
  }

  // three neighbored of zero
  foreach (p; threes) {
    foreach (dp; scan) {
      if (vs.get(p, dp) == 0) {
        foreach (op; scan.remove!(x => x == dp)) {
          grid.set(p, op, EDGE);  // other sides
        }
        grid.surrounded3(p);  // forbid mark
        break;
      }
    }
  }


  // three neighbored of another
  foreach (i; 0..threes.length) {
    foreach (j; (i+1)..threes.length) {
      // is neighbored?
      if (distance4(threes[i], threes[j]) == 1) {
        // y is same --> YOKO else --> TATE
        int direction = (threes[i][0] == threes[j][0]) ? YOKO : TATE;
        foreach (dp; scan(direction)) {
          grid.set(threes[i], dp, EDGE);
          grid.set(threes[j], dp, EDGE);
        }

        try_surround3(grid, threes[i]);
        try_surround3(grid, threes[j]);
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

