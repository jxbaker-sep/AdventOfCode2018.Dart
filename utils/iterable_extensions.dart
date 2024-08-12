import 'dart:collection';

extension MyIterableExtensions<T> on Iterable<T> {
  Iterable<T> whereMin(int Function(T) test) {
    return fold<(List<T>, int)>(([], 0), (p, item) {
      final x = test(item);
      if (p.$1.isEmpty || x == p.$2) return (p.$1..add(item), x);
      if (x < p.$2) return ([item], x);
      return p;
    }).$1;
  }

  Iterable<T> whereMax(int Function(T) test) {
    return fold<(List<T>, int)>(([], 0), (p, item) {
      final x = test(item);
      if (p.$1.isEmpty || x == p.$2) return (p.$1..add(item), x);
      if (x > p.$2) return ([item], x);
      return p;
    }).$1;
  }



  Iterable<T2> flatmap<T2>(Iterable<T2> Function(T t) callback) {
    return map(callback).expand((i)=>i);
  }

  Map<T2, T3> toMap<T2, T3>(T2 Function(T t) asKey, T3 Function(T t) asValue) {
    final result = <T2, T3>{};
    for(final item in this) {
      result[asKey(item)] = asValue(item);
    }
    return result;
  }

  Iterable<List<T>> windows(int length) sync* {
    if (length < 1) throw Exception();
    final accum = Queue<T>();
    for(final item in this) {
      accum.add(item);
      if (accum.length > length) accum.removeFirst();
      if (accum.length == length) yield accum.toList();
    }
  }
}

extension MyIterableNumericExtension on Iterable<int> {
  int get product => reduce((a,b) => a*b);
}