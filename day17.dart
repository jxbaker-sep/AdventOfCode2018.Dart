import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import 'utils/input.dart';
import 'utils/iterable_extensions.dart';
import 'utils/parse_utils.dart';
import 'utils/position.dart';

enum State {
  Water,
  Wall,
  Seen
}


Future<void> main() async {
  final sample = parse(await getInput('day17.sample'));
  final data = parse(await getInput('day17'));

  group('Day17', (){
    group('Part 1', () {
      test('Sample', () => expect(do1(sample), equals((57, 29))));
      test('Data', () => expect(do1(data), equals((31788, 25800))));
    });
    group('Part 2', () {
    });
  });
}

typedef Grid = Map<Position, State>;

(int, int) do1(Grid grid) {
  final ys = grid.keys.map((k) => k.y).bounds;
  final spring = Position(500, ys.min-1);
  drop(grid, spring, ys);
  // printGrid(grid);
  return (
    grid.entries
      .where((e) => ys.contains(e.key.y))
      .where((v) => v.value == State.Water || v.value == State.Seen)
      .length, 
    grid.entries
      .where((e) => ys.contains(e.key.y))
      .where((v) => v.value == State.Water)
      .length
  );
}

void drop(Grid grid, Position start, Bounds ys) {
  if (start.y > ys.max) return;
  var current = start;
  if (grid[current] == State.Seen) return;
  if (grid[current] != null) throw Exception();
  grid[current] = State.Seen;
  while ((grid[current + Vector.South] ?? State.Seen) == State.Seen) {
    current = current + Vector.South;
    if (grid[current] == State.Seen) return;
    if (current.y > ys.max) return;
    grid[current] = State.Seen;
  }

  while (true) {
    var leftExit = findExit(grid, current, Vector.West);
    if (leftExit != null) {
      while (leftExit != null) {
        drop(grid, leftExit, ys);
        if (grid[leftExit] != State.Water) {
          leftExit = null;
        } else {
          leftExit = findExit(grid, leftExit + Vector.North, Vector.West);
        }
      }
      continue;
    }

    var rightExit = findExit(grid, current, Vector.East);
    if (rightExit != null) {
      while (rightExit != null) {
        drop(grid, rightExit, ys);
        if (grid[rightExit] != State.Water) {
          rightExit = null;
        } else {
          rightExit = findExit(grid, rightExit + Vector.North, Vector.East);
        }
      }
      continue;
    }

    // find exit
    final leftWall = findWall(grid, current, Vector.West);
    final rightWall = findWall(grid, current, Vector.East);
    if (leftWall != null && rightWall != null) {
      // hemmed by walls
      for(var x = leftWall.x + 1 ; x < rightWall.x ; x++) {
        grid[Position(x, current.y)] = State.Water;
      }
      current += Vector.North;
      continue;
    }
    break;
  }

}

Position? findWall(Grid grid, Position start, Vector v) {
  var current = start + v;
  while (true) {
    if (grid[current] == State.Wall) return current;
    if (grid[current + Vector.South] == null) return null;
    current += v;
  }
}

Position? findExit(Grid grid, Position start, Vector v) {
  if (grid[start] == null) grid[start] = State.Seen;
  var current = start + v;
  while (true) {
    if (grid[current] != null) return null;
    grid[current] = State.Seen;
    if (grid[current + Vector.South] == null) return current + Vector.South;
    current += v;
  }
}

Grid parse(String s) {
  final result = Grid();
  for (final line in matcherP.onePerLine(s)) {
    for(var x = line[0]; x <= line[1]; x++) {
      for(var y = line[2]; y <= line[3]; y++) {
        result[Position(x, y)] = State.Wall;
      }
    }
  }
  return result;
}

final matcherP = [matcher1P, matcher2P].toChoiceParser();
final matcher1P = parserFor3("y={}, x={}..{}", number, number, number).map((m) => [m.$2, m.$3, m.$1, m.$1]);
final matcher2P = parserFor3("x={}, y={}..{}", number, number, number).map((m) => [m.$1, m.$1, m.$2, m.$3]);

void printGrid(Grid grid) {
  final ys = grid.keys.map((k) => k.y).bounds;
  final xs = grid.keys.map((k) => k.x).bounds;
  for (var y = ys.min; y <= ys.max; y++) {
    var s = "";
    for (var x = xs.min; x <= xs.max; x++) {
      s += switch (grid[Position(x,y)]) {
        null => ' ',
        State.Wall => '#',
        State.Seen => '|',
        State.Water => '~'
      };
    }
    print(s);
  }
}
