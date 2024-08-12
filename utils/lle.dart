import 'dart:collection';

final class LLE<T> extends LinkedListEntry<LLE<T>> {
  T value;
  LLE(this.value);
}

extension LLExtension<T> on LLE<T> {
  LLE<T> advance(int n) => Iterable.generate(n).fold(this, (p, _) => p.next!);
  LLE<T> advanceWrap(int n) => Iterable.generate(n).fold(this, (p, _) => p.next ?? list!.first);
  (LLE<T>, int?) advanceWrap2(int n) {
    int? wrappedAt = 0;
    LLE<T> result = this;
    for (final i in Iterable.generate(n, (i) => i)) {
      final temp = result.next;
      if (temp == null) {
        wrappedAt = i;
        result = result.list!.first;
      } else {
        result = temp;
      }
    };
    return (result, wrappedAt);
  }
}