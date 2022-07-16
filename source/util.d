module util;

import std.algorithm.searching;

export long indexOf(T)(T[] arr, T e) {
	for(long i = 0; i < arr.length; i++)
		if(arr[i] == e) return i;
	return -1;
}

export bool isInt(string s) {
	if(s.length == 0) return false;
	for(long i = 0; i < s.length; i++) {
		if(s[i] == '-') {
			if(s.length == 1 || i != 0)
				return false;
		}
		else if(s[i] < '0' || s[i] > '9')
			return false;
	}
	return true;
}

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
