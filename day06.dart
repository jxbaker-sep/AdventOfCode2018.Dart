
import 'package:collection/collection.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import 'utils/input.dart';
import 'utils/iterable_extensions.dart';
import 'utils/parse_utils.dart';
import 'utils/position.dart';


Future<void> main() async {
  final sample = parse(await getInput('day06.sample'));
  final data = parse(await getInput('day06'));

  group('Day06', (){
    group('Part 1', () {
      test("Sample", () => expect(do1(sample), equals(17)));
      test('Data', () => expect(do1(data), equals(3251)));
    });

    group('Part 2', () {
      test("Sample", () => expect(do2(sample, 32), equals(16)));
      test('Data', () => expect(do2(data, 10000), equals(47841)));
    });
  });
}

int do1(Set<Position> grid) {
  final minx = grid.map((p) => p.x).min - 1;
  final miny = grid.map((p) => p.y).min - 1;
  final maxx = grid.map((p) => p.x).max + 1;
  final maxy = grid.map((p) => p.y).max + 1;
  final supergrid = <Position, Position>{};
  for(var y = miny ; y <= maxy; y++) {
    for(var x = minx ; x <= maxx; x++) {
      final p2 = Position(x, y);
      final mins = grid.whereMin((p) => p2.manhattanDistance(p)).toList();
      if (mins.length == 1) {
        supergrid[p2] = mins.first;
      }
    }
  }

  final infinities = supergrid.entries
    .where((e) => e.key.x == minx || e.key.x == maxx || e.key.y == miny || e.key.y == maxy)
    .map((e) => e.value)
    .toSet();

  final finities = grid.difference(infinities);
  return finities.map((f) => supergrid.values.where((v) => v == f).length).max;
}

int do2(Set<Position> grid, int maxDistance) {
  final minx = grid.map((p) => p.x).min;
  final miny = grid.map((p) => p.y).min;
  final maxx = grid.map((p) => p.x).max;
  final maxy = grid.map((p) => p.y).max;
  final supergrid = <Position>{};
  for(var y = miny ; y <= maxy; y++) {
    for(var x = minx ; x <= maxx; x++) {
      final p2 = Position(x, y);
      final z = grid.map((p) => p.manhattanDistance(p2)).sum;
      if (z < maxDistance) supergrid.add(p2);
    }
  }
  return supergrid.length;
}


Set<Position> parse(String s) => positionP.onePerLine(s).toSet();

final positionP = parserFor2("{},{}", number, number).map((m) => Position(m.$1, m.$2));