module split;

import std.algorithm.searching;

export string[] splitLine(string line, char[] punctuation) {
	string[] strings;
	string s = "";
	char quote = 0;
	foreach(char c; line) {
		if(quote) {
			if(c == quote) {
				strings ~= "\""~s;
				quote = 0;
				s = "";
			}
			else
				s ~= c;
		}
		else if(c == '"' || c == '\'') {
			if(s.length) strings ~= s;
			s = "";
			quote = c;
		}
		else if(canFind(punctuation, c)) {
			if(s.length) strings ~= s;
			s = "";
			strings ~= [c];
		}
		else if(c == ' ' || c == '\t') {
			if(s.length) strings ~= s;
			s = "";
		}
		else {
			if(c >= 'a' && c <= 'z')
				c += 'A'-'a';
			s ~= c;
		}
	}
	if(s.length)
		strings ~= s;
	return strings;
}
