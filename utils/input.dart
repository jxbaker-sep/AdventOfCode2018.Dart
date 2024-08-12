import 'dart:io';

Future<String> getInput(String section) async {
  final home = Platform.environment['HOME'];
  return File('$home/dev/AdventOfCode2017.Input/$section.input').readAsString();
}

Future<String> getAnswer(String section) async {
  final home = Platform.environment['HOME'];
  return File('$home/dev/AdventOfCode2017.Input/$section.answer').readAsString();
}