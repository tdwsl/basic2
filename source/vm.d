module vm;

import std.stdio;
import std.conv;

export class VM {
public:
	enum {
		MOV=0,
		MOVZ=1,
		LD=2,
		LDB=3,
		LM=4,
		ST=5,
		STB=6,

		INT=7,
		CMP=8,
		NAND=9,

		ADD=10,
		SUB=11,
		MUL=12,
		DIV=13,
		PUSH=14,
		POP=15,
	}

	uint[16] registers; // 0-15, r14 is sp, r15 is pc
	ubyte[256*1024] memory;

private:
	enum args {
		r=0,
		rr=1,
		rrr=2,
		ra=3,
	};

	static const string[16] istrings = [
		"MOV",
		"MOVZ",
		"LD",
		"LDB",
		"LM",
		"ST",
		"STB",

		"INT",
		"CMP",
		"NAND",

		"ADD",
		"SUB",
		"MUL",
		"DIV",
		"PUSH",
		"POP",
	];

	static const ubyte[16] iargs = [
		args.rr,
		args.rrr,
		args.rr,
		args.rr,
		args.ra,
		args.rr,
		args.rr,

		args.r,
		args.rrr,
		args.rrr,

		args.rrr,
		args.rrr,
		args.rrr,
		args.rrr,
		args.r,
		args.r,
	];

	static const ubyte[] asteps = [
		1,
		2,
		2,
		5,
	];

	static uint decode(ubyte[] arr) {
		return cast(uint)arr[0]<<24
			| cast(uint)arr[1]<<16
			| cast(uint)arr[2]<<8
			| cast(uint)arr[3];
	}

	static ubyte[] encode(uint n) {
		return [
			cast(ubyte)(n>>24),
			cast(ubyte)(n>>16),
			cast(ubyte)(n>>8),
			cast(ubyte)(n),
		];
	}

public:
	void print(uint start, uint end) {
		for(uint pc = start; pc < end; ) {
			ubyte i = memory[pc] >> 4;
			if(i < 0 || i >= 16) {
				writeln(i);
				assert(0);
			}
			writef("$%08X       %s", pc, istrings[i]);

			switch(iargs[i]) {
			default: assert(0);
			case args.ra:
				writefln(" R%d,$%08X", memory[pc]&0x0f, decode(memory[pc+1..pc+5]));
				break;
			case args.rrr:
				writefln(" R%d,R%d,R%d", memory[pc]&0x0f, memory[pc+1]>>4, memory[pc+1]&0x0f);
				break;
			case args.rr:
				writefln(" R%d,R%d", memory[pc]&0x0f, memory[pc+1]>>4);
				break;
			case args.r:
				writefln(" R%d", memory[pc]&0x0f);
				break;
			}

			pc += asteps[iargs[i]];
		}
	}

	uint run() {
		for(;;) {
			uint pc = registers[15];
			ubyte ri = memory[pc] & 0x0f;
			ubyte i = memory[pc] >> 4;
			int s;

			switch(i) {
			default: assert(0);
			case MOV:
				registers[ri] = registers[memory[pc+1]>>4];
				break;
			case MOVZ:
				if(!registers[ri])
					registers[memory[pc+1]>>4] = registers[memory[pc+1]&0x0f];
				break;
			case LD:
				registers[ri] = memory[registers[memory[pc+1]>>4]];
				break;
			case LDB:
				registers[ri] = (registers[ri] & 0xfff0) | memory[registers[memory[pc+1]>>4]];
				break;
			case LM:
				registers[ri] = decode(memory[pc+1..pc+5]);
				break;
			case ST:
				memory[registers[ri]..registers[ri]+4] = encode(registers[memory[pc+1]>>4]);
				break;
			case STB:
				memory[registers[ri]] = cast(ubyte)(registers[memory[pc+1]>>4]);
				break;
			case INT:
				registers[15] += asteps[iargs[i]];
				return registers[ri];
			case CMP:
				if(cast(int)(registers[memory[pc+1]>>4]) < cast(int)(registers[memory[pc+1]&0x0f]))
					registers[ri] = -1;
				else if(cast(int)(registers[memory[pc+1]>>4]) > cast(int)(registers[memory[pc+1]&0x0f]))
					registers[ri] = 1;
				else
					registers[ri] = 0;
				break;
			case NAND:
				registers[ri] = ~(registers[memory[pc+1]>>4] & registers[memory[pc+1]&0x0f]);
				break;
			case ADD:
				registers[ri] = cast(int)(registers[memory[pc+1]>>4]) + cast(int)(registers[memory[pc+1]&0x0f]);
				break;
			case SUB:
				registers[ri] = cast(int)(registers[memory[pc+1]>>4]) - cast(int)(registers[memory[pc+1]&0x0f]);
				break;
			case MUL:
				registers[ri] = cast(int)(registers[memory[pc+1]>>4]) * cast(int)(registers[memory[pc+1]&0x0f]);
				break;
			case DIV:
				s = cast(int)(registers[memory[pc+1]>>4]) / cast(int)(registers[memory[pc+1]&0x0f]);
				registers[memory[pc+1]>>4] = cast(int)(registers[memory[pc+1]>>4]) % cast(int)(registers[memory[pc+1]&0x0f]);
				registers[ri] = s;
				break;
			case PUSH:
				memory[registers[14]..registers[14]+4] = encode(registers[ri]);
				registers[14] += 4;
				break;
			case POP:
				registers[ri] = decode(memory[registers[14]..registers[14]+4]);
				registers[14] -= 4;
				break;
			}

			if(pc != registers[15])
				continue;

			registers[15] += asteps[iargs[i]];
		}
	}

	void addR(uint i, ubyte ins, ubyte r) {
		memory[i] = cast(ubyte)((ins<<4) | r);
	}

	void addRR(uint i, ubyte ins, ubyte r1, ubyte r2) {
		memory[i] = cast(ubyte)((ins<<4) | r1);
		memory[i+1] = cast(ubyte)(r2<<4);
	}

	void addRRR(uint i, ubyte ins, ubyte r1, ubyte r2, ubyte r3) {
		memory[i] = cast(ubyte)((ins<<4) | r1);
		memory[i+1] = cast(ubyte)((r2<<4) | r3);
	}

	void addRA(uint i, ubyte ins, ubyte r, uint addr) {
		memory[i] = cast(ubyte)((ins<<4) | r);
		memory[i+1..i+5] = encode(addr);
	}
}
