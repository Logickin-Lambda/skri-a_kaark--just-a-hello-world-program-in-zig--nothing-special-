/// There is no such thing as Object and Constructor in zig,
/// but it is possible to make one behave like one;
/// however, it needs proper init and deinit function
/// to prevent memory leak; thus, I am going to create a
/// "class" in this file.
const std = @import("std");

const SynthisisMethod = enum { Substractive, Additive, FM, Sample };

// let's do a horrible stack to see how to write an init and deinit functions.
fn NumberStack() type {
    return struct {
        const Self = @This();

        items: []i64,
        stack_ptr: usize,
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator) !Self {
            const slot = try allocator.alloc(i64, 1);
            return Self{ .allocator = allocator, .items = slot, .stack_ptr = 0 };
        }

        // Not sure if this is the correct way to free memory
        pub fn deinit(self: Self) void {
            self.allocator.free(self.items);
        }

        pub fn push(self: *Self, input: i64) !void {
            const len = self.items.len;

            if (self.stack_ptr == len) {
                const new_block = try self.allocator.alloc(i64, len * 2);
                @memcpy(new_block[0..len], self.items);
                self.allocator.free(self.items);
                self.items = new_block;
            }

            self.items[self.stack_ptr] = input;
            self.stack_ptr += 1;
        }

        pub fn pop(self: *Self) i64 {
            const output = self.items[self.stack_ptr - 1];
            self.items[self.stack_ptr - 1] = 0;
            self.stack_ptr -= 1;

            return output;
        }

        pub fn peek(self: Self) i64 {
            return if (self.stack_ptr - 1 >= 0) self.items[self.stack_ptr - 1] else 0;
        }
    };
}

pub fn test_con_destructor(bw: anytype, stdout: anytype) !void {
    try stdout.print("\nTesting Constructor and Distructor: \n", .{});
    try bw.flush();

    const page = std.heap.page_allocator;
    var arena = std.heap.ArenaAllocator.init(page);
    defer arena.deinit();

    var number_stack = try NumberStack().init(arena.allocator());
    defer number_stack.deinit();

    try number_stack.push(40);
    try number_stack.push(27);
    try number_stack.push(63);

    try stdout.print("\nthe top item is {d}", .{number_stack.peek()});
    try stdout.print("\nthe popped item is {d}", .{number_stack.pop()});
    try stdout.print("\nthe top item is {d}", .{number_stack.peek()});
    try bw.flush();
}
