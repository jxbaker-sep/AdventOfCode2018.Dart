import 'package:petitparser/petitparser.dart';

import 'string_extensions.dart';

extension ParserExtensions<T> on Parser<T> {
  Parser<T> before(String b) => skip(before: string(b).trim());

  Parser<T> after(String a) => skip(after: string(a).trim());

  Parser<T> between(String before, String after) => skip(before: string(before).trim(), after: string(after).trim());

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

Parser<(T1, T2)> parserFor2<T1, T2>(String format, Parser<T1> p1, Parser<T2> p2) {
  final matches = RegExp(r"\{\}").allMatches(format).toList();
  final a1 = format.substring(0, matches[0].start);
  final a2 = format.substring(matches[0].end, matches[1].start);
  final a3 = format.substring(matches[1].end);
  var xp1 = p1;
  var xp2 = p2;
  if (a1.isNotEmpty) xp1 = xp1.before(a1);
  if (a2.isNotEmpty) xp1 = xp1.after(a2);
  if (a3.isNotEmpty) xp2 = xp2.after(a3);
  return seq2(xp1, xp2);
}