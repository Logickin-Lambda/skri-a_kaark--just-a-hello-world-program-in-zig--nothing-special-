const std = @import("std");

fn virtual_print_function(input: i32) anyerror!void {
    _ = input;
    return error.OperationNotSupported;
}

/// Seems like function overloading works, but it is only possible
/// for any non comptime type such as comptime, anytype and anyopaque
pub var print: *const fn (i32) anyerror!void = virtual_print_function;
