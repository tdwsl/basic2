module util;

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
