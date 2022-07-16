module expression;

import util;
import std.algorithm.searching;

export struct Expression {
	string[] ops;
	string[] vals;
	const static string sep = "!";

	void addVal(string v) {
		if(v != sep) vals ~= v;
	}

	static Expression from(string[] arr, string[] operators) {
		Expression e;
		if(arr.length == 1) {
			e.vals = arr;
			return e;
		}

		int depth = 0;
		int start;
		for(int i = 0; i < arr.length; i++) {
			if(arr[i] == "(") {
				if(depth++ == 0) start = i;
			}
			else if(arr[i] == ")") {
				if(--depth == 0) {
					Expression x = from(arr[start+1..i], operators);
					arr = arr[0..start] ~ arr[i+1..arr.length];
					e.vals ~= x.vals;
					e.ops ~= x.ops;
				}
			}
			else if(arr[i] == "-" && i+1 < arr.length) {
				if(!isInt(arr[i+1])) continue;
				bool n = false;
				if(i == 0) n = true;
				else if(canFind(operators, arr[i-1])) n = true;
				if(n) {
					arr[i] ~= arr[i+1];
					arr = arr[0..i+1] ~ arr[i+2..arr.length];
				}
			}
			else if(arr[i] == "=" && i+1 < arr.length && i != 0) {
				if(arr[i-1] == ">" || arr[i-1] == "<") {
					arr[i-1] ~= arr[i];
					arr = arr[0..i] ~ arr[i+1..arr.length];
					i--;
				}
			}
		}
		arr = sep.dup ~ arr ~ sep.dup;
		foreach(string o; operators)
			for(int i = 0; i < arr.length; i++)
				if(arr[i] == o) {
					e.ops ~= arr[i];
					e.addVal(arr[i-1]);
					e.addVal(arr[i+1]);
					arr[i-1] = sep.dup;
					arr[i+1] = sep.dup;
				}
		return e;
	}
}
