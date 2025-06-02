const std = @import("std");
const dyn = @import("dynamic_fuction_defining.zig");

fn print_impl(input: i32) anyerror!void {
    std.debug.print("\nprinting something {d} 420 \n", .{input});
}

pub fn load() !void {
    dyn.print = &print_impl;
    try dyn.print(69);
}

test "function overloading" {
    try load();
}
