const std = @import("std");

pub fn experimenting_hashmap(bw: anytype, stdout: anytype) !void {
    const page = std.heap.page_allocator;
    var arena = std.heap.ArenaAllocator.init(page);
    defer arena.deinit();

    // declare a basic hashmap
    var map = std.AutoHashMap(i32, i32).init(arena.allocator());
    defer map.deinit();

    try map.put(1, 2);
    try map.put(2, 4);
    try map.put(4, 7);
    try map.put(7, 3);
    try map.put(3, 5);
    try map.put(5, 1);

    try stdout.print("\nPrinting a hashmap: ", .{});
    try get_key(stdout, &map, 1, 10);
    try bw.flush();

    // using a string hashmap
    var map_str = std.StringHashMap(f64).init(arena.allocator());
    defer map_str.deinit();

    try map_str.put("pi", 3.14);
    try map_str.put("mole fraction", 6.02);
    try map_str.put("gravity", 9.81);

    const gravity = "gravity";
    try stdout.print("the value for {s}: {d:.2}\n", .{ gravity, map_str.get(gravity).? });
    try bw.flush();

    // trying to get something that is non-existance
    const unknown_key = "Notey";

    if (map_str.get(unknown_key)) |unknown_value| {
        try stdout.print("the value for {s}: {d:.2}\n", .{ unknown_key, unknown_value });
    } else {
        try stdout.print("Nah... Nothing for {s}\n", .{unknown_key});
    }

    try bw.flush();

    // now, let me messing around the fetchPut() function to see how it works
    // We're heading for Venus and still we stand tall
    const earth_accel = try map_str.fetchPut("gravity", 8.87);

    try stdout.print("The current gravity acceleration is: {d}\n", .{map_str.get("gravity").?});
    try stdout.print("The earth gravity acceleration is: {d}\n", .{earth_accel.?.value});
    try bw.flush();
}

pub fn get_key(stdout: anytype, map: *std.AutoHashMap(i32, i32), cur_index: i32, no_iter: i32) !void {
    try stdout.print("{d} -> ", .{cur_index});

    if (no_iter == 0) {
        try stdout.print("{d}\n", .{map.get(cur_index).?});
        return;
    } else {
        try get_key(stdout, map, map.get(cur_index).?, no_iter - 1);
    }
}
