const std = @import("std");

const OperatorType = enum { invalid, inc, dec, lshift, rshift, read, write, jmp, jnz };

const Operator = struct {
    op: OperatorType,
    arg: usize,
};

fn compile_prog(allocator: *std.mem.Allocator, prog: []u8) !std.ArrayList(Operator) {
    var pc: u32 = 0;
    var ops = std.ArrayList(Operator).init(allocator);
    var loop_stack = std.ArrayList(usize).init(allocator);

    while (pc < prog.len) {
        if (prog[pc] == '[') {
            try loop_stack.append(ops.items.len);
            try ops.append(.{ .op = .jmp, .arg = 0 });
            pc += 1;
        }
        else if (prog[pc] == ']') {
            if (loop_stack.items.len == 0) {
                std.log.warn("unmatched [ at pc = {}", .{pc});
                return error.UnmatchedLoop;
            }

            var brac_offset = loop_stack.pop();

            ops.items[brac_offset].arg = ops.items.len;
            try ops.append(.{ .op = .jnz, .arg = brac_offset });
            pc += 1;
        }
        else {
            const begin = pc;
            pc += 1;
            while (pc < prog.len and prog[pc] == prog[pc - 1]) {
                pc += 1;
            }

            const num_repeats = pc - begin;
            const optype: OperatorType = switch (prog[begin]) {
                '>' => .rshift,
                '<' => .lshift,
                '+' => .inc,
                '-' => .dec,
                '.' => .write,
                ',' => .read,
                else => .invalid
            };
            if(optype != .invalid)
                try ops.append(.{ .op = optype, .arg = num_repeats });
        }
    }

    return ops;
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

    // Compile
    var ops = try compile_prog(allocator, prog);
    defer ops.deinit();

    while (pc < ops.items.len): (pc += 1) {
        var i = ops.items[pc];
        var arg = @intCast(u32, i.arg);

        switch (i.op) {
            .inc => { memory[ptr] +%= arg; },
            .dec => { memory[ptr] -%= arg; },
            .rshift => { ptr += arg; },
            .lshift => { ptr -= arg; },
            .read => {
                while (arg > 0): (arg -= 1) {
                    memory[ptr] = try stdin.readByte();
                }
            },
            .write => {
                try stdout.writeByteNTimes(@truncate(u8, memory[ptr]), arg);
            },
            .jmp => {
                if (memory[ptr] == 0) {
                    pc = arg;
                }
            },
            .jnz => {
                if (memory[ptr] != 0) {
                    pc = arg;
                }
            },
            else => {}
        }
    }
}
