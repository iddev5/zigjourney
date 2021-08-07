const std = @import("std");

const OperatorType = enum { inc, dec, lshift, rshift, read, write, jmp, jnz };

const Operator = struct {
    op: OperatorType,
    arg: usize,
};

fn compute_jumps(table: []u32, prog: []u8) void {
    var pc: u32 = 0;

    while (pc < prog.len) {
        if (prog[pc] == '[') {
            var bracket_nesting: usize = 1;
            var seek = pc;

            while (bracket_nesting >= 1 and seek <= prog.len) {
                seek += 1;

                if (prog[seek] == ']') {
                    bracket_nesting -= 1;
                }
                else if (prog[seek] == '[') {
                    bracket_nesting += 1;
                }
            }

            if (bracket_nesting <= 0) {
                table[pc] = seek;
                table[seek] = pc;
            }
            else {
                std.log.warn("unmatched [ at pc = {}", .{pc});
            }
        }

        pc += 1;
    }
}

pub fn main() !void {
    var allocator = std.heap.page_allocator;

    const file_name = "mandelbrot.bf";
    const file = try std.fs.cwd().openFile(file_name, .{ .read = true, },);
    defer file.close();

    const prog = try file.reader().readAllAlloc(allocator, 30000);
    defer allocator.free(prog);

    var pc: u32 = 0;
    var ptr: u32 = 0;
    var memory: [30000]u32 = undefined;
    std.mem.set(u32, &memory, 0);

    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    // Jump table
    var jump_table = try allocator.alloc(u32, prog.len);
    defer allocator.free(jump_table);
    std.mem.set(u32, jump_table, 0);

    compute_jumps(jump_table, prog);

    // Interpreter
    while (pc < prog.len) {
        switch (prog[pc]) {
            '>' => { ptr += 1; },
            '<' => { ptr -= 1; },
            '+' => { memory[ptr] +%= 1; },
            '-' => { memory[ptr] -%= 1; },
            '.' => { try stdout.writeByte(@intCast(u8, memory[ptr])); },
            ',' => { memory[ptr] = try stdin.readByte(); },
            '[' => {
                if (memory[ptr] == 0) {
                    pc = jump_table[pc];
                }
            },
            ']' => {
                if (memory[ptr] != 0) {
                    pc = jump_table[pc];
                }
            },
            else => {},
        }

        pc += 1;
    }
}
