import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:test/test.dart';

import 'utils/input.dart';
import 'utils/iterable_extensions.dart';
import 'utils/lle.dart';
import 'utils/string_extensions.dart';

List<int> parse(String s) => s.lines.single.split('').map(int.parse).toList();

Future<void> main() async {
  final data = parse(await getInput('day01'));

  group('Day01', (){
    group('Part 1', () {
      test("Sample 1", () => expect(do1(parse('1122')), equals(3)));
      test("Sample 2", () => expect(do1(parse('1111')), equals(4)));
      test("Sample 3", () => expect(do1(parse('1234')), equals(0)));
      test("Sample 4", () => expect(do1(parse('91212129')), equals(9)));
      test('Data', () => expect(do1(data), equals(1228)));
    });

    group('Part 2', () {
      test("Sample 1", () => expect(do2(parse('1212')), equals(6)));
      test("Sample 2", () => expect(do2(parse('1221')), equals(0)));
      test("Sample 3", () => expect(do2(parse('123425')), equals(4)));
      test("Sample 4", () => expect(do2(parse('123123')), equals(12)));
      test("Sample 5", () => expect(do2(parse('12131415')), equals(4)));
      test('Data', () => expect(do2(data), equals(1238))); 
    });
    group('Part 3', () {
      test("Sample 1", () => expect(do3(parse('1212')), equals(6)));
      test("Sample 2", () => expect(do3(parse('1221')), equals(0)));
      test("Sample 3", () => expect(do3(parse('123425')), equals(4)));
      test("Sample 4", () => expect(do3(parse('123123')), equals(12)));
      test("Sample 5", () => expect(do3(parse('12131415')), equals(4)));
      test('Data', () => expect(do3(data), equals(1238))); 
    });
  });
}

int do3(List<int> data) {
  final mid = data.length ~/ 2;
  return IterableZip([data, data.sublist(mid) + data.sublist(0, mid)])
    .where((pair) => pair[0] == pair[1])
    .map((pair) => pair[0])
    .sum;
}


int do2(List<int> data) {
  int sum = 0;
  final ll = LinkedList<LLE<int>>();
  ll.addAll(data.map((it) => LLE<int>(it)));
  var current = ll.firstOrNull;
  var tail = current?.advance(data.length ~/ 2);
  while (current != null && tail != null) {
    if (current.value == tail.value) sum += current.value;
    current = current.next;
    tail = tail.advanceWrap(1);
  }
  return sum;
}

int do1(List<int> data) {
  return data.windows(2).followedBy([[data.last, data.first]])
    .where((pair) => pair[0] == pair[1])
    .map((pair) => pair[0])
    .sum;
}