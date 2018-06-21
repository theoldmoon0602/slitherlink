import std.stdio;
import std.string;
import std.algorithm;
import std.conv;
import std.range;
import std.math;
import std.typecons;
import std.traits;
import std.format;

enum YOKO = 0;
enum TATE = 1;

enum EMPTY = 0;
enum EDGE = 1;
enum FORBID = 2;
enum INVALID = 3;

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



bool inrange(const(int[][]) vs, long y, long x)
{
  auto size = vs.length;
  return 0 <= x && x < size && 0 <= y && y < size;
}
bool inrange(const(int[][][]) grid, long[] p)
{
  if (grid.length <= p[0]) {
    return false;
  }
  auto size = grid[p[0]].length;
  if (p[0] == TATE) {
    return 0 <= p[1] && p[1] < size-1 && 0 <= p[2] && p[2] < size;
  }
  return 0 <= p[1] && p[1] < size && 0 <= p[2] && p[2] < size-1;
}

long distance4(long[] p1, long[] p2)
{
  return abs(p1[0]-p2[0]) + abs(p1[1]-p2[1]);
}
long distance8(long[] p1, long[] p2)
{
  return max(abs(p1[0]-p2[0]), abs(p1[1]-p2[1]));
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

long get(const(int[][][]) grid, long[] p, long[] dp)
{
  long y = p[0]; long x = p[1];
  long dy = dp[0]; long dx = dp[1];

  auto d = (dy == 0)?TATE:YOKO;
  if (d == TATE && dx == -1) { dx = 0; }
  if (d == YOKO && dy == -1) { dy = 0; }

  y += dy;
  x += dx;

  return grid.get([d, y, x]);
}

long get(const(int[][][]) grid, long[] p)
{
  if (grid.inrange(p)) {
    return grid[p[0]][p[1]][p[2]];
  }
  return INVALID;
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

  grid.set(d, y, x, v);
}

void set(ref int[][][] grid, long[] p, int v)
{
  grid.set(p[0], p[1], p[2], v);
}

void set(ref int[][][] grid, long d, long y, long x, int v)
{
  if (!grid.inrange([d, y, x])) {
    return;
  }
  if (grid[d][y][x] != EMPTY && grid[d][y][x] != v) {
    auto msg = "at: (%d %d %d) is %s but assigning %s".format(d, x, y, gridconv(grid[d][y][x], d == YOKO),  gridconv(v, d == YOKO));
    throw new Exception("Program error: " ~ msg);
  }

  grid[d][y][x] = v;

  if (v == EDGE) {
    for (auto i = 0; i < 2; i++) {
      // MARK FORBID
      foreach (e; scanedge(d, y, x, i)) {
        if (grid.get(e) == EDGE) {
          foreach (e2; scanedge(d, y, x, i).remove!(x => x == e)) {
            grid.set(e2, FORBID);
          }
          break;
        }
      }
    }
    // DRAW EDGE IF ONLY ONE WAY REMAINED
    for (auto i = 0; i < 2; i++) {
      auto cnt = [0, 0, 0, 0];
      foreach (e; scanedge(d, y, x, i)) {
        cnt[grid.get(e)]++;
      }


      if (cnt[EDGE] == 0 && cnt[EMPTY] == 1) {
        foreach (e; scanedge(d, y, x, i)) {
          if (grid.get(e) == EMPTY) {
            grid.set(e, EDGE);
            break;
          }
        }
      }
    }
  }
}

void print(const(int[][][]) grid)
{
  foreach (y; 0..grid[0].length-1) {
    writeln(grid[YOKO][y][0..$-1].map!(x => "+"~gridconv(x, true)).join("") ~ "+");
    writeln(grid[TATE][y].map!(x => gridconv(x, false)).array.join(" ") ~ gridconv(grid[TATE][y][$-1], false));
  }
  writeln(grid[YOKO][$-1][0..$-1].map!(x => "+"~gridconv(x, true)).join("") ~ "+");
}

void print(const(int[][]) vs, const(int[][][]) grid)
{
  // grid EDGE
  foreach (y; 0..vs.length) {
    writeln(grid[YOKO][y][0..$-1].map!(x => "+"~gridconv(x, true)).join("") ~ "+");
    writeln(grid[TATE][y].map!(x => gridconv(x, false)).zip(vs[y].map!(numconv)).map!"a[0]~a[1]".array.join("") ~ gridconv(grid[TATE][y][$-1], false));
  }
  writeln(grid[YOKO][$-1][0..$-1].map!(x => "+"~gridconv(x, true)).join("") ~ "+");
}

long[][] scanedge(long d, long y, long x, int i)
{
  if (d == YOKO) {
    if (i == 0) {
      return [
        [TATE, y-1, x+1],
        [YOKO, y, x+1],
        [TATE, y, x+1],
      ];
    }
    return [
      [TATE, y-1, x],
      [YOKO, y, x-1],
      [TATE, y, x],
    ];
  }

  if (i == 0) {
    return [
      [YOKO, y, x-1],
      [TATE, y-1, x],
      [YOKO, y, x],
    ];
  }
  return [
    [YOKO, y+1, x-1],
    [TATE, y+1, x],
    [YOKO, y+1, x],
  ];
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

void try_surround(ref int[][][] grid, const(int[][]) vs, long[] p)
{
  switch (vs[p[0]][p[1]]) {
    case 1:
      grid.try_surround1(p);
      break;
    case 2:
      grid.try_surround2(p);
      break;
    case 3:
      grid.try_surround3(p);
      break;
    default:
      break;
  }
}

void try_surround1(ref int[][][] grid, long[] p)
{
  int[] cnt = [0, 0, 0, 0];
  foreach (dp; scan) {
    cnt[grid.get(p, dp)]++;
  }

  if (cnt[EDGE] == 1 && cnt[FORBID] != 3) {
    foreach (dp; scan) {
      if (grid.get(p, dp) != EDGE) {
        grid.set(p, dp, FORBID);
      }
    }
  }
  if (cnt[FORBID] == 3) {
    foreach (dp; scan) {
      if (grid.get(p, dp) != FORBID) {
        grid.set(p, dp, EDGE);
      }
    }
  }
}

void try_surround2(ref int[][][] grid, long[] p)
{
  int[] cnt = [0, 0, 0, 0];
  foreach (dp; scan) {
    cnt[grid.get(p, dp)]++;
  }

  if (cnt[EDGE] == 2 || cnt[FORBID] == 2) {
    foreach (dp; scan) {
      if (grid.get(p, dp) == FORBID) {
        grid.set(p, dp, FORBID);
      }
      else {
        grid.set(p, dp, EDGE);
      }
    }
  }
}

void try_surround3(ref int[][][] grid, long[] p)
{
  int[] cnt = [0, 0, 0, 0];
  foreach (dp; scan) {
    cnt[grid.get(p, dp)]++;
  }

  if (cnt[FORBID] == 1) {
    foreach (dp; scan) {
      if (grid.get(p, dp) != FORBID) {
        grid.set(p, dp, EDGE);
      }
    }
  }
  else if (cnt[EDGE] == 3 && cnt[EMPTY] == 1) {
    foreach (dp; scan) {
      if (grid.get(p, dp) != EDGE) {
        grid.set(p, dp, FORBID);
        break;
      }
    }
  }

}


void solve(const(int[][]) vs, ref int[][][] grid, uint dotimes=10)
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
        break;
      }
    }
  }


  // three neighbored of another one
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

  // three 8-neighbored of another one
  foreach (i; 0..threes.length) {
    foreach (j; (i+1)..threes.length) {
      if (distance4(threes[i], threes[j]) == 2 &&
          distance8(threes[i], threes[j]) == 1) {
        int up = (threes[i][0] < threes[j][0]) ? 1 : -1;
        int left = (threes[i][1] < threes[j][1]) ? 1 : -1;

        grid.set(threes[i], [-1 * up, 0], EDGE);
        grid.set(threes[i], [0, -1 * left], EDGE);
        grid.set(threes[j], [1 * up, 0], EDGE);
        grid.set(threes[j], [0, 1 * left], EDGE);

        try_surround3(grid, threes[i]);
        try_surround3(grid, threes[j]);
      }
    }
  }

  // three at corner
  foreach(p; threes) {
    auto n = vs.length - 1;
    if (p == [0, 0]) {
      grid.set(p, [-1, 0], EDGE);
      grid.set(p, [0, -1], EDGE);
      try_surround3(grid, p);
    }
    else if (p == [0, n]) {
      grid.set(p, [-1, 0], EDGE);
      grid.set(p, [0, 1], EDGE);
      try_surround3(grid, p);
    }
    else if (p == [n, 0]) {
      grid.set(p, [1, 0], EDGE);
      grid.set(p, [0, -1], EDGE);
      try_surround3(grid, p);
    }
    else if (p == [n, n]) {
      grid.set(p, [1, 0], EDGE);
      grid.set(p, [0, 1], EDGE);
      try_surround3(grid, p);
    }
  }


  // surround remaineds
  foreach (_; 0..dotimes) {
    foreach (y; 0..vs.length) {
      foreach (x; 0..vs[y].length) {
        grid.try_surround(vs, [y, x]);
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
  solve(vs, grid, 100);
  print(vs, grid);
}

