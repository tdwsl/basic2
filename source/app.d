import expression;
import util;
import run;
import std.stdio;
import std.file;

void main(string[] args) {
	if(args.length != 2) {
		writeln("basic2 - tdwsl 2022");
		writefln("usage: %s <filename>", args[0]);
		return;
	}

	if(args[1] == "-d") {
		string[] arr = splitLine("10 + (2-3) * 20 / -2", ['/','*','+','-','(',')']);
		Expression e = Expression.from(arr, ["/", "*", "+", "-"]);
		writeln(e.vals, e.ops);
		return;
	}

	if(!exists(args[1])) {
		writefln("failed to open %s", args[1]);
		return;
	}

	string text = cast(string)(read(args[1]));
	runString(text);
}
