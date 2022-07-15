import std.stdio;
import expression;
import split;
import vm;

void main() {
	string[] operators = ["/", "*", "+", "-"];
	char[] punctuation = ['(', ')', '/', '*', '+', '-'];
	string line = "10 + 5/2 - 3 + -4";
	writeln(line);
	Expression e = Expression.fromArr(splitLine(line, punctuation), operators);
	writeln(e.vals, e.ops);
	line = "if 1-1 then print 'no way'";
	writeln(splitLine(line, punctuation));

	VM vm = new VM();
	vm.addRA(0, VM.LM, 0, 5);
	vm.addRA(5, VM.LM, 1, 7);
	vm.addRRR(10, VM.ADD, 0, 0, 1);
	vm.addR(12, VM.INT, 0);
	vm.print(0, 13);
	vm.registers[15] = 0;
	writeln(vm.run());
}
