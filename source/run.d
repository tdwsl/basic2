module run;

import util;
import expression;
import std.conv;
import std.stdio;
import std.array;
import std.typecons;
import core.stdc.stdlib;

string[string] g_variables;

void sassert(bool cond, long l) {
	if(!cond) {
		writeln("SYNTAX ERROR AT ", l+1);
		exit(1);
	}
}

void setVariable(string name, string v, long l) {
	if(name[name.length-1] == '$')
		sassert(v[0] == '"', l);
	else
		sassert(isInt(v), l);
	g_variables[name] = v;
}

string getVariable(string name) {
	if(name in g_variables)
		return g_variables[name];
	if(name[name.length-1] == '$')
		return "\"";
	else
		return "0";
}

string doOp(string v1, string v2, string op, long l) {
	if(op == "+") {
		sassert(isInt(v1) && isInt(v2), l);
		return to!string(to!int(v1)+to!int(v2));
	}
	else if(op == "-") {
		sassert(isInt(v1) && isInt(v2), l);
		return to!string(to!int(v1)-to!int(v2));
	}
	else if(op == "/") {
		sassert(isInt(v1) && isInt(v2), l);
		return to!string(to!int(v1)/to!int(v2));
	}
	else if(op == "*") {
		sassert(isInt(v1) && isInt(v2), l);
		return to!string(to!int(v1)*to!int(v2));
	}
	else if(op == "=") {
		if(isInt(v1) && isInt(v2))
			return to!string(to!int(to!int(v1)==to!int(v2)));
		else
			return to!string(to!int(v1 == v2));
	}
	else if(op == ">") {
		sassert(isInt(v1) && isInt(v2), l);
		return to!string(to!int(to!int(v1) > to!int(v2)));
	}
	else if(op == "<") {
		sassert(isInt(v1) && isInt(v2), l);
		return to!string(to!int(to!int(v1) < to!int(v2)));
	}
	else if(op == ">=") {
		sassert(isInt(v1) && isInt(v2), l);
		return to!string(to!int(to!int(v1) >= to!int(v2)));
	}
	else if(op == "<=") {
		sassert(isInt(v1) && isInt(v2), l);
		return to!string(to!int(to!int(v1) <= to!int(v2)));
	}
	else if(op == "AND") {
		sassert(isInt(v1) && isInt(v2), l);
		return to!string(to!int(to!int(v1) & to!int(v2)));
	}
	else if(op == "OR") {
		sassert(isInt(v1) && isInt(v2), l);
		return to!string(to!int(to!int(v1) | to!int(v2)));
	}
	else if(op == ";") {
		sassert(v1[0] == '"', l);
		if(v2[0] == '"') v2 = v2[1..v2.length];
		return v1~v2;
	}
	else if(op == ",") {
		sassert(v1[0] == '"', l);
		if(v2[0] == '"') v2 = v2[1..v2.length];
		return v1~"\t"~v2;
	}

	sassert(0, l);
	assert(0);
}

string evalExpr(Expression e, long l) {
	sassert(e.vals.length != 0, l);
	sassert(e.ops.length == e.vals.length-1, l);

	for(long i = 0; i < e.vals.length; i++)
		if(!isInt(e.vals[i]) && e.vals[i][0] != '"')
			e.vals[i] = getVariable(e.vals[i]);

	for(long i = 0; i < e.ops.length; i++)
		e.vals[0] = doOp(e.vals[0], e.vals[i+1], e.ops[i], l);

	return e.vals[0];
}

export void runString(string text) {
	string[] operators = ["/", "*", "+", "-", "=", ">", "<", ">=", "<=", "AND", "OR", ",", ";"];
	char[] punctuation = ['(', ')', '/', '*', '+', '-', '=', '>', '<', ',', ';', ':'];

	string[] lines = text.split('\n');

	long[string] labels;
	Tuple!(long, bool, bool)[256] rstack;
	ubyte rsp = 0;

	bool wasif=false, lastif;
	for(long l = 0; l < lines.length; l++) {
		string[] line = splitLine(lines[l], punctuation);
		for(;;) {
			if(line.length == 0)
				break;

			if(line[0] != "ELSE")
				wasif = false;

			if(line[0] == "IF") {
				long t = indexOf(line, "THEN");
				sassert(t != -1, l);
				string r = evalExpr(Expression.from(line[1..t], operators), l);
				bool tf;
				if(isInt(r))
					tf = to!int(r) != 0;
				else
					tf = r != "";

				wasif = true;
				lastif = tf;

				if(tf) {
					line = line[t+1..line.length];
					continue;
				}
				else
					break;
			}

			if(line[0] == "ELSE") {
				sassert(wasif, l);
				wasif = false;
				if(lastif) break;
				line = line[1..line.length];
				continue;
			}

			if(line[0] == "REM")
				break;

			if(line[0] == "PRINT") {
				string s = evalExpr(Expression.from(line[1..line.length], operators), l);
				if(s[0] == '"') s = s[1..s.length];
				writeln(s);
			}
			else if(line[0] == "GOTO") {
				sassert(line.length == 2, l);
				sassert((line[1] in labels) != null, l);
				l = labels[line[1]]-1;
				wasif = false;
			}
			else if(line[0] == "GOSUB") {
				sassert(line.length == 2, l);
				sassert((line[1] in labels) != null, l);
				rstack[rsp++] = tuple(l, wasif, lastif);
				l = labels[line[1]]-1;
			}
			else if(line[0] == "RETURN") {
				sassert(line.length == 1, l);
				rsp--;
				l = rstack[rsp][0];
				wasif = rstack[rsp][1];
				lastif = rstack[rsp][2];
			}
			else if(line[1] == ":") {
				sassert(line.length == 2, l);
				labels[line[0]] = l;
			}
			else if(line[1] == "=") {
				sassert(line.length >= 3, l);
				sassert(line[0][0] != '"', l);
				sassert(!isInt(line[0]), l);
				setVariable(line[0], evalExpr(Expression.from(line[2..line.length], operators), l), l);
			}
			else
				sassert(0, l);

			break;
		}
	}
}
