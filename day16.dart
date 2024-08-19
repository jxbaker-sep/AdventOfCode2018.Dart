import 'package:collection/collection.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import 'utils/input.dart';
import 'utils/parse_utils.dart';
import 'utils/string_extensions.dart';
import 'utils/xrange.dart';

Future<void> main() async {
  final samples = parseSamples(await getInput('day16'));
  final program = parseProgram(await getInput('day16'));

  group('Day16', (){
    group('Part 1', () {
      test('Data', () => expect(do1(samples), equals(580)));
    });
    group('Part 2', () {
      test('Data', () => expect(do2(samples, program), equals(537)));
    });
  });
}

int do2(List<Sample> samples, List<Instruction> program) {
  final ops = [addr, addi, mulr, muli, banr, bani, borr, bori, setr, seti,
    gtir, gtrr, gtri, eqir, eqrr, eqri];
  final mopcodes = xrange(16).map((_) => ops.toList()).toList();
  for (final sample in samples) {
    mopcodes[sample.instruction.opcode] = mopcodes[sample.instruction.opcode]
      .where((op) => ListEquality().equals(sample.after, op(sample.instruction, sample.before)))
      .toList();
  }

  final zopcodes = xrange(16).map((_) => ops.toList()..clear()).toList();

  while (mopcodes.any((v) => v.isNotEmpty)) {
    final one = mopcodes.indexed.where((v) => v.$2.length == 1).first;
    final element = one.$2.first;
    zopcodes[one.$1] = [element];
    for (final i in xrange(16)) {
      mopcodes[i].remove(element);
    } 
  }

  if (zopcodes.any((v) => v.length != 1)) throw Exception();

  return program.fold([0, 0, 0, 0], (r, i) => zopcodes[i.opcode].first(i, r))[0];
}

int do1(List<Sample> samples) {
  final ops = [addr, addi, mulr, muli, banr, bani, borr, bori, setr, seti,
    gtir, gtrr, gtri, eqir, eqrr, eqri];
  return samples.where((sample) => ops
    .where((op) => ListEquality().equals(sample.after, op(sample.instruction, sample.before)))
    .length >= 3
  ).length;
}

Registers rr(int Function(int a, int b) fct, Instruction i, Registers input) {
  final output = input.toList();
  output[i.output] = fct(input[i.a], input[i.b]);
  return output;
}

Registers ri(int Function(int a, int b) fct, Instruction i, Registers input) {
  final output = input.toList();
  output[i.output] = fct(input[i.a], i.b);
  return output;
}

Registers ir(int Function(int a, int b) fct, Instruction i, Registers input) {
  final output = input.toList();
  output[i.output] = fct(i.a, input[i.b]);
  return output;
}

Registers ii(int Function(int a, int b) fct, Instruction i, Registers input) {
  final output = input.toList();
  output[i.output] = fct(i.a, i.b);
  return output;
}

Registers addr(Instruction i, Registers input) => rr((a, b) => a + b, i, input);
Registers addi(Instruction i, Registers input) => ri((a, b) => a + b, i, input);

Registers mulr(Instruction i, Registers input) => rr((a, b) => a * b, i, input);
Registers muli(Instruction i, Registers input) => ri((a, b) => a * b, i, input);

Registers banr(Instruction i, Registers input) => rr((a, b) => a & b, i, input);
Registers bani(Instruction i, Registers input) => ri((a, b) => a & b, i, input);

Registers borr(Instruction i, Registers input) => rr((a, b) => a | b, i, input);
Registers bori(Instruction i, Registers input) => ri((a, b) => a | b, i, input);

Registers setr(Instruction i, Registers input) => rr((a, b) => a, i, input);
Registers seti(Instruction i, Registers input) => ii((a, b) => a, i, input);

Registers gtir(Instruction i, Registers input) => ir((a, b) => a > b ? 1 : 0, i, input);
Registers gtrr(Instruction i, Registers input) => rr((a, b) => a > b ? 1 : 0, i, input);
Registers gtri(Instruction i, Registers input) => ri((a, b) => a > b ? 1 : 0, i, input);

Registers eqir(Instruction i, Registers input) => ir((a, b) => a == b ? 1 : 0, i, input);
Registers eqrr(Instruction i, Registers input) => rr((a, b) => a == b ? 1 : 0, i, input);
Registers eqri(Instruction i, Registers input) => ri((a, b) => a == b ? 1 : 0, i, input);

List<Sample> parseSamples(String s) => s.paragraphs.takeWhile((p) => p[0].startsWith("Before"))
  .map((p) => matcherP.allMatches(p.join(' ')).single).toList();

List<Instruction> parseProgram(String s) {
  final remainder = s.paragraphs.skipWhile((p) => p[0].startsWith("Before")).toList();
  if (remainder.length > 1) throw Exception();
  return instructionP.onePerLine(remainder.first.join('\n'));
}

typedef Instruction = ({int opcode, int a, int b, int output});
typedef Registers = List<int>;

typedef Sample = ({Registers before, Instruction instruction, Registers after});

final beforeRegisterP = parserFor4("Before: [{}, {}, {}, {}]", number, number, number, number)
  .map((m) => [m.$1, m.$2, m.$3, m.$4]);
final afterRegisterP = parserFor4("After:  [{}, {}, {}, {}]", number, number, number, number)
  .map((m) => [m.$1, m.$2, m.$3, m.$4]);
Parser<Instruction> instructionP = parserFor4("{} {} {} {}", number, number, number, number)
  .map((m) => (opcode: m.$1, a: m.$2, b: m.$3, output: m.$4));
Parser<Sample> matcherP = seq3(beforeRegisterP, instructionP, afterRegisterP)
  .map((m) => (before: m.$1, instruction: m.$2, after: m.$3));