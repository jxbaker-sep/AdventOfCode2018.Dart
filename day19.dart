import 'package:test/test.dart';

import 'utils/input.dart';
import 'utils/string_extensions.dart';


Future<void> main() async {
  final sample = parse(await getInput('day19.sample'));
  final data = parse(await getInput('day19'));

  group('Day19', (){
    group('Part 1', () {
      test('Sample', () => expect(do1(sample), equals(7)));
      test('Data', () => expect(do1(data), equals(1140)));
    });
    group('Part 2', () {
      // Note: day19 part 2 was done by reading the assembly by hand. further notes in Input repo.
      // test('Data', () => expect(do1(data, r0: 1), equals(0)));
    });
  });
}

int do1((int, List<(Opcode, Instruction)>) data, {int r0 = 0}) {
  final pc = data.$1;
  final ops = data.$2;

  var r = [r0,0,0,0,0,0];
  var i = 100;
  while (r[pc] >= 0 && r[pc] < ops.length && --i > 0) {
    print(r);
    final (op, i) = ops[r[pc]];
    r = op(i, r);
    r[pc] += 1;
  }
  print(r);
  return r[0];
}

(int, List<(Opcode, Instruction)>) parse(String s) {
  final lines = s.lines;
  final pc = int.parse(lines.first.substring(4));
  final map = {
    "addr": addr, "addi": addi, 
    "mulr": mulr, "muli": muli, 
    "banr": banr, "bani": bani, 
    "setr": setr, "seti": seti, 
    "gtir": gtir, "gtri": gtri, "gtrr": gtrr,
    "eqir": eqir, "eqri": eqri, "eqrr": eqrr
  };
  final instructions = <(Opcode, Instruction)>[];
  for (final line in lines.skip(1)) {
    final x = line.split(' ');
    instructions.add((map[x[0]]!, (a: int.parse(x[1]), b: int.parse(x[2]), output: int.parse(x[3]))));
  }
  return (pc, instructions);
}


typedef Opcode = Registers Function(Instruction i, Registers input);
typedef Instruction = ({int a, int b, int output});
typedef Registers = List<int>;

typedef Sample = ({Registers before, Instruction instruction, Registers after});


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
