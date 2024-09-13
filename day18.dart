import 'package:test/test.dart';

import 'utils/input.dart';
import 'utils/iterable_extensions.dart';
import 'utils/position.dart';
import 'utils/string_extensions.dart';
import 'utils/xrange.dart';


Future<void> main() async {
  final sample = parse(await getInput('day18.sample'));
  final data = parse(await getInput('day18'));

  group('Day18', (){
    group('Part 1', () {
      test('Sample', () => expect(do1(sample, 10), equals(1147)));
      test('Data', () => expect(do1(data, 10), equals(466312)));
    });
    group('Part 2', () {
      test('Data', () => expect(do1(data, 1000000000), equals(176782)));
    });
  });
}

String key(Grid grid) => (grid.entries.toList()..sort((a,b) => a.key.compare(b.key)))
  .map((e) => '${e.key}:${e.value}').join(',');

int do1(Grid grid, final int minutes) {
  Map<String, (int, Grid)> closed = {};
  for(final i in xrange(minutes)) {
    final k = key(grid);
    if (closed[k] case (int, Grid) needle) {
      final loop = needle.$1;
      final loopSize = i - loop;
      final n = (minutes - i) % loopSize;
      final x = closed.entries.where((e) => e.value.$1 == loop + n).first.value.$2;
      return x.values.where((v) => v == Acre.trees).length * 
        x.values.where((v) => v == Acre.lumberyard).length;
    }
    closed[k] = (i, grid);
    Grid temp = Grid();
    for(final item in grid.entries) {
      switch(item.value) {
        case Acre.open:
          temp[item.key] = item.key.neighbors().where((n) => grid[n] == Acre.trees).take(3).length >= 3 ?
            Acre.trees : Acre.open;
          break;
        case Acre.trees:
          temp[item.key] = item.key.neighbors().where((n) => grid[n] == Acre.lumberyard).take(3).length >= 3 ?
            Acre.lumberyard : Acre.trees;
          break;
        case Acre.lumberyard:
          temp[item.key] = 
            item.key.neighbors().any((n) => grid[n] == Acre.lumberyard) &&
            item.key.neighbors().any((n) => grid[n] == Acre.trees)
             ? Acre.lumberyard : Acre.open;
          break;
      }
    }
    grid = temp;
  }
  return grid.values.where((v) => v == Acre.trees).length * 
    grid.values.where((v) => v == Acre.lumberyard).length;
}

enum Acre {
  open,
  trees,
  lumberyard
}

typedef Grid = Map<Position, Acre>;

Grid parse(String s) => s.lines.indexed.flatmap((row) =>
  row.$2.split('').indexed.map((col) => (Position(col.$1, row.$1), switch (col.$2){
    '#' => Acre.lumberyard,
    '|' => Acre.trees,
    '.' => Acre.open,
    _ => (throw Exception())
  }))
).toMap((it) => it.$1, (it) => it.$2);