
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
  final data = parse(await getInput('day15'));

  group('Day15', (){
    group('Part 1', () {
      test("Sample", () => expect(do1(sample), equals(27730)));
      test('Data', () => expect(do1(data), equals(0)));
    });
    group('Part 2', () {
    });
  });
}

typedef Grid = Map<Position, Item>;

int do1(Grid grid) {
  grid = Grid.from(grid);
  
  for(final round in xrange(0xFFFF)) {
    print(round);
    printGrid(grid);
    final turnOrder = grid.entries.where((e) => e.value is Creature)
      .map((it) => it.key).toList()..sort(readingOrder);

    for (var p in turnOrder) {
      final pc = grid[p];
      // skip newly dead creatures
      if (pc is! Creature) continue;
      print('$p');
      final enemies = grid.entries.where((it) => pc.isEnemy(it.value)).map((e) => e.key).toList();
      if (enemies.isEmpty) {
        return (round) * grid.values.whereType<Creature>()
          .map((e) => e.hitPoints).sum;
      }
      // If already adjacent to an enemy, skip pathfinding
      if (!enemies.any((e) => e.manhattanDistance(p) == 1)) {
        final targetSquare = pathFind(p, enemies.flatmap((e) => e.orthogonalNeighbors()).toSet().toList(), grid);
        if (targetSquare == null) continue;
        grid[targetSquare[0]] = pc;
        grid.remove(p);
        // print('$p $targetSquare');
        p = targetSquare[0];
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



List<Position>? pathFind(Position original, List<Position> destinations, Grid grid) {
  var (goals, shortest) = reachables(original, destinations.toSet(), grid);
  if (goals.isEmpty || shortest is! int) return null;
  final chosen = goals.reduce((a,b) => readingOrder(a, b) <= 0 ? a : b);
  final temp = pathFind2(original, chosen, grid, shortest).toList();
  return temp.reduce((a,b) => readingOrder(a.first, b.first) <= 0 ? a : b);
}

// List<Position>? pathFind(Position original, List<Position> destinations, Grid grid) {
//   final goals = reachables(original, destinations.toSet(), grid).toSet();
//   if (goals.isEmpty) return null;
//   List<List<Position>> paths = [];
//   int? shortest;
//   final open = Queue<List<Position>>();
//   open.add([original]);
//   final closed = {original: 1};
//   // final closed = <Position, int>{original: 0};
//   while (open.isNotEmpty) {
//     final current = open.removeFirst();
//     if (shortest is int && goals.map((d) => d.manhattanDistance(current.last) + current.length).min >= shortest) continue;
//     for (final neighbor in current.last.orthogonalNeighbors().where((n) => !current.contains(n) && grid[n] == null)) {
//       final path = current + [neighbor];
//       if ((closed[neighbor] ?? 0xFFFFFFFF) < path.length) continue;
//       closed[neighbor] = [closed[neighbor] ?? 0xFFFFFFFF, path.length].min;
//       // closed[neighbor] = path.length;
//       if (goals.contains(neighbor)) {
//         if (shortest is! int || path.length <= shortest) {
//           paths.add(path);
//           shortest = path.length;
//         }
//       }
//       open.add(path);
//     }
//   }

//   if (paths.isEmpty) throw Exception();

//   final chosen = paths.reduce((a,b) => readingOrder(a.last, b.last) <= 0 ? a : b).last;
//   return paths.where((p) => p.last == chosen).reduce((a,b) => readingOrder(a.first, b.first) <= 0 ? a : b).sublist(1);
// }

(Set<Position>, int?) reachables(Position original, Set<Position> goals, Grid grid) {
  final result = <Position>{};
  final open = Queue<(Position, int)>.from([(original, 0)]);
  final closed = {original};
  int? shortest;
  while (open.isNotEmpty) {
    final current = open.removeFirst();
    if (shortest is int && current.$2 > shortest) break;
    for (final neighbor in current.$1.orthogonalNeighbors().where((n) => !closed.contains(n) && grid[n] == null)) {
      if (goals.contains(neighbor)) {
        result.add(neighbor);
        shortest = shortest ?? (current.$2 + 1);
      }
      closed.add(neighbor);
      open.add((neighbor, current.$2 + 1));
    }
  }
  return (result, shortest);
}

typedef Step = List<Position>;

Iterable<List<Position>> pathFind2(Position original, Position destination, Grid grid, final int shortest) sync* {
  bool isEmpty(Position p) => !grid.containsKey(p);
  int priorityFct(List<Position> p) => p.length + p.last.manhattanDistance(destination);
  final open = PriorityQueue<Step>((a,b) => priorityFct(a) - priorityFct(b));

  for(final neighbor in original.orthogonalNeighbors().where((n) => isEmpty(n))) {
    if (neighbor == destination) {
      yield [neighbor]; 
      return;
    }
    else {
      open.add([neighbor]);
    }
  }

  if (shortest == 1) return;

  while (open.isNotEmpty) {
    final current = open.removeFirst();
    for(final neighbor in current.last.orthogonalNeighbors().where((n) => isEmpty(n) && !current.contains(n))) {
      final path = current + [neighbor];
      if (neighbor == destination) {
        if (path.length <= shortest) {
          yield path;
        } else {
          return;
        }
        continue;
      }

      if (priorityFct(path) <= shortest) {
        open.add(path);
      }
    }
  }
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