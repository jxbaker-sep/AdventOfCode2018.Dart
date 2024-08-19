import 'package:petitparser/petitparser.dart';

import 'iterable_extensions.dart';
import 'string_extensions.dart';

extension ParserExtensions<T> on Parser<T> {
  Parser<T> before(String b) => b.trim().isNotEmpty ? skip(before: string(b.trim()).trim()) : this;

  Parser<T> after(String a) => a.trim().isNotEmpty ? skip(after: string(a.trim()).trim()) : this;

  Parser<T> between(String before, String after) => this.before(before).after(after);

  List<T> onePerLine(String s) => s.lines.map((line) => allMatches(line).single).toList();

}

final letters = letter().plus().flatten();

final lexical = letter().plus().flatten().trim();

final number = (string("-").optional() & digit().plus()).flatten().trim().map(int.parse);

ChoiceParser<T> choice2<T>(Parser<T> c1, Parser<T> c2) => [c1,c2].toChoiceParser();
ChoiceParser<T> choice3<T>(Parser<T> c1, Parser<T> c2, Parser<T> c3) => [c1,c2,c3].toChoiceParser();
ChoiceParser<T> choice4<T>(Parser<T> c1, Parser<T> c2, Parser<T> c3, Parser<T> c4) => [c1,c2,c3, c4].toChoiceParser();
ChoiceParser<T> choice5<T>(Parser<T> c1, Parser<T> c2, Parser<T> c3, Parser<T> c4) => [c1,c2,c3, c4].toChoiceParser();

ChoiceParser<String> oneOf(List<String> choices) => ChoiceParser(choices.map((s) => string(s).trim()));

List<String> _flogl(String format) {
  final rxm = RegExp(r"\{\}").allMatches(format).toList();
  return [
    format.substring(0, rxm[0].start), 
    ...rxm.windows(2).map((w) => format.substring(w[0].end, w[1].start)),
    format.substring(rxm.last.end)
  ];
}

Parser<(T1, T2)> parserFor2<T1, T2>(String format, Parser<T1> p1, Parser<T2> p2) {
  final a = _flogl(format);
  return seq2(p1.between(a[0], a[1]), p2.after(a[2]));
}

Parser<(T1, T2, T3)> parserFor3<T1, T2, T3>(String format, Parser<T1> p1, Parser<T2> p2, Parser<T3> p3) {
  final a = _flogl(format);
  return seq3(p1.between(a[0], a[1]), p2.after(a[2]), p3.after(a[3]));
}

Parser<(T1, T2, T3, T4)> parserFor4<T1, T2, T3, T4>(String format, Parser<T1> p1, Parser<T2> p2, Parser<T3> p3, Parser<T4> p4) {
  final a = _flogl(format);
  return seq4(p1.between(a[0], a[1]), p2.after(a[2]), p3.after(a[3]), p4.after(a[4]));
}
