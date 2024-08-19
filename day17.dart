import 'package:collection/collection.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import 'utils/input.dart';
import 'utils/iterable_extensions.dart';
import 'utils/parse_utils.dart';
import 'utils/position.dart';
import 'utils/xrange.dart';

enum State {
  Water,
  Wall,
  Seen
}

typedef Grid = Map<Position, State>;

Future<void> main() async {
  final sample = parse(await getInput('day17.sample'));
  final data = parse(await getInput('day17'));

  group('Day17', (){
    group('Part 1', () {
      test('Sample', () => expect(do1(sample), equals(57)));
      test('Data', () => expect(do1(data), equals(0)));
    });
    group('Part 2', () {
    });
  });
}

int do1(Grid grid) {
  final ys = grid.keys.map((k) => k.y).bounds;
  final spring = Position(500, ys.min);
  drop(grid, spring, ys);
  // printGrid(grid);
  return grid.entries
    .where((e) => ys.contains(e.key.y))
    .where((v) => v.value == State.Water || v.value == State.Seen)
    .length;
}

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

extension on State? {
  bool get isEmpty => (this ?? State.Seen) == State.Seen;
}

void drop(Grid grid, Position start, Bounds ys) {
  if (start.y > ys.max) return;
  var current = start;
  if (!grid[current].isEmpty) throw Exception();
  grid[current] = State.Seen;
  while (grid[current + Vector.South].isEmpty) {
    current = current + Vector.South;
    if (current.y > ys.max) return;
    grid[current] = State.Seen;
  }

  // find exit
  var left = findExitOrWall(grid, current, Vector.West);
  var right = findExitOrWall(grid, current, Vector.East);
  while (current.y >= ys.min) {
    if (left.y == current.y && right.y == current.y) { // hemmed by walls
      for(var x = left.x + 1 ; x < right.x ; x++) {
        grid[Position(x, current.y)] = State.Water;
      }
      current += Vector.North;
      left = findExitOrWall(grid, current, Vector.West);
      right = findExitOrWall(grid, current, Vector.East);
      continue;
    }
    break;
  }

  if (left.y != current.y) drop(grid, left, ys);
  if (right.y != current.y) drop(grid, right, ys);
}

Position findExitOrWall(Grid grid, Position start, Vector v) {
  var current = start + v;
  while (true) {
    if (grid[current] == State.Wall) return current;
    if (grid[current] == State.Water) throw Exception();
    grid[current] = State.Seen;
    if (grid[current + Vector.South].isEmpty) return current + Vector.South;
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