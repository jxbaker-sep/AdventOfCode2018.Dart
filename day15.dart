
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:test/test.dart';

import 'utils/input.dart';
import 'utils/iterable_extensions.dart';
import 'utils/position.dart';
import 'utils/string_extensions.dart';
import 'utils/xrange.dart';



Future<void> main() async {
  final sample = parse(await getInput('day15.sample'));
  final sample2 = parse(await getInput('day15.sample.2'));
  final data = parse(await getInput('day15'));

  group('Day15', (){
    group('Part 1', () {
      test("Sample 1", () => expect(do1(sample), equals(27730)));
      test("Sample 2", () => expect(do1(sample2), equals(36334)));
      test('Data', () => expect(do1(data), equals(229798)));
    });
    group('Part 2', () {
    });
  });
}

typedef Grid = Map<Position, Item>;

int do1(Grid grid) {
  grid = Grid.from(grid);
  
  for(final round in xrange(0xFFFF)) {
    // print(round);
    // printGrid(grid);
    final turnOrder = (grid.entries.where((e) => e.value is Creature)
      .toList()..sort((a, b) => readingOrder(a.key, b.key)))
      .map((it) => it.value).whereType<Creature>().toList();

    for (var pc in turnOrder) {
      // skip newly dead creatures
      if (pc.hitPoints <= 0) continue;
      var p = grid.entries.where((e) => e.value == pc).first.key;
      // print('$p');
      final enemies = grid.entries.where((it) => pc.isEnemy(it.value)).map((e) => e.key).toList();
      if (enemies.isEmpty) {
        return (round) * grid.values.whereType<Creature>()
          .map((e) => e.hitPoints).sum;
      }
      // If already adjacent to an enemy, skip pathfinding
      if (!enemies.any((e) => e.manhattanDistance(p) == 1)) {
        final targetSquare = pathFind(p, enemies.flatmap((e) => e.orthogonalNeighbors()).toSet().toList(), grid);
        if (targetSquare == null) continue;
        grid[targetSquare] = pc;
        grid.remove(p);
        // print('$p $targetSquare');
        p = targetSquare;
      }
      // Now moved, determine an enemy to attack
      final adjacentEnemies = enemies.where((e) => e.manhattanDistance(p) == 1)
        .map((e) => (e, grid[e] as Creature))
        .whereMin((e) => e.$2.hitPoints).toList();
      if (adjacentEnemies.isEmpty) continue;
      final e = adjacentEnemies.reduce((a,b) => readingOrder(a.$1, b.$1) <= 0 ? a : b);
      e.$2.hitPoints -= pc.attackPower;
      if (e.$2.hitPoints <= 0) {
        grid.remove(e.$1);
      }
    }
  }
  throw Exception();
}



Position? pathFind(Position original, List<Position> destinations, Grid grid) {
  final List<({Position first, Position last, int length})> goals = [];
  for(final v in [Vector.North, Vector.West, Vector.East, Vector.South]) {
    final (g, s) = reachables(original, destinations.toSet(), grid, v);
    if (g.isEmpty || s is! int) continue;
    final gmap = g.map((it) => (first: original + v, last: it, length: s));
    goals.addAll(gmap);
  }
  if (goals.isEmpty) return null;
  final chosen = goals.whereMin((it) => it.length).reduce((a,b) => readingOrder(a.last, b.last) <= 0 ? a : b).last;
  // print(goals.where((g) => g.last == chosen).toList());
  final temp = goals.whereMin((it) => it.length).where((g) => g.last == chosen).reduce((a,b) => readingOrder(a.first, b.first) <= 0 ? a : b);
  // print(temp);
  return temp.first;
}


(Set<Position>, int?) reachables(Position original, Set<Position> goals, Grid grid, Vector vopen) {
  final result = <Position>{};
  final open = Queue<(Position, int)>.from([(original, 0)]);
  final closed = {original};
  int? shortest;
  while (open.isNotEmpty) {
    final current = open.removeFirst();
    if (shortest is int && current.$2 >= shortest) break;
    final neighbors = current.$2 == 0 ? [original + vopen] : current.$1.orthogonalNeighbors();
    for (final neighbor in neighbors.where((n) => !closed.contains(n) && grid[n] == null)) {
      if (goals.contains(neighbor)) {
        result.add(neighbor);
        shortest = shortest ?? (current.$2 + 1);
        continue;
      }
      closed.add(neighbor);
      open.add((neighbor, current.$2 + 1));
    }
  }
  return (result, shortest);
}

abstract class Item {}

abstract class Creature extends Item {
  int hitPoints = 200;
  int attackPower = 3;
  bool isEnemy(Item? other);
}

class Elf extends Creature { @override bool isEnemy(Item? other) => other is Goblin; }
class Goblin extends Creature { @override bool isEnemy(Item? other) => other is Elf; }
class Wall extends Item {}

Grid parse(String s) => s.lines.indexed
  .flatmap((row) => row.$2.split('').indexed.map((col) => (col.$1, row.$1, col.$2)))
  .where((it) => it.$3 != '.')
  .toMap((it) => Position(it.$1, it.$2), (it) => switch (it.$3){
    '#' => Wall(),
    'G' => Goblin(),
    'E' => Elf(),
    _ => (throw Exception())
  });

int readingOrder(Position a, Position b) {
  if (a.y == b.y) return a.x - b.x;
  return a.y - b.y;
}
  
void printGrid(Grid grid) {
  var minx = grid.keys.map((it) => it.x).min;
  var miny = grid.keys.map((it) => it.y).min;
  var maxx = grid.keys.map((it) => it.x).max;
  var maxy = grid.keys.map((it) => it.y).max;
  for(var y = miny; y <= maxy; y++) {
    var line = "";
    for(var x = minx; x <= maxx; x++) {
      line += switch(grid[Position(x,y)]) {
        Elf _ => 'E',
        Goblin _ => 'G',
        Wall _ => '#',
        _ => '.'
      };
    }
    print(line);
  }
}