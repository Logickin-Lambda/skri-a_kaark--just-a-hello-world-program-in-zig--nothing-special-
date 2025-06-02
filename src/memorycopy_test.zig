const std = @import("std");

fn memory_copy_experiment() !void {
    const test_sequence = "Skri-a Kaark";
    var test_dest: [128]u8 = std.mem.zeroes([128]u8);

    const output = try std.fmt.bufPrint(&test_dest, "<!-- {s} -->", .{test_sequence});

    std.debug.print("\nresult: {s}\n", .{test_dest});
    std.debug.print("output: {s}\n", .{output});
}

test "memory copy test" {
    try memory_copy_experiment();
}
