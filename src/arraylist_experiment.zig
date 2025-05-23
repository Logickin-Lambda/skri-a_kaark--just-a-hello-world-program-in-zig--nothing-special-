const std = @import("std");

pub fn experimenting_array_list(bw: anytype, stdout: anytype) !void {
    // play around with the basic data structures:
    // ArrayList
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var list = std.ArrayList([]const u8).init(allocator);
    defer list.deinit();

    try list.append("Notey"); // foo bar are overrated, I wanna use Notey (yep) instead
    try list.append("(yep)");
    try list.append("(what)");
    try list.append("(???)");

    for (list.items) |item| {
        try stdout.print("{s}\n", .{item});
    }
    try bw.flush();

    // I wanna use the arenaAllocator for a list, let see how to make one:
    const page = std.heap.page_allocator;
    var arena = std.heap.ArenaAllocator.init(page);
    defer arena.deinit();

    // Now, let me build another ArrayList again, but with arena allocator
    // Now I know why I got an error on using the arena allocator. It turns out
    // ArenaAllocator and Allocator are two different things, which is different
    // from java which they can be the same class of things due to inheritance.
    var list2 = std.ArrayList([]const u8).init(arena.allocator());
    defer list2.deinit();

    try list2.append("Accipiter");
    try list2.append("Nova");

    try stdout.print("\n{s}\n", .{list2.items[0]});
    try stdout.print("{s}\n", .{list2.items[1]});
    try bw.flush();

    // replace with a total new string
    list2.items[0] = "Tachyspiza";

    try stdout.print("\n{s}\n", .{list2.items[0]});
    try stdout.print("{s}\n", .{list2.items[1]});
    try bw.flush();

    // extend the string with the original slices
    list2.items[0] = try std.fmt.allocPrint(
        arena.allocator(),
        "{s} is the new scientific name for Goshawks",
        .{list2.items[0]},
    );

    try stdout.print("\n{s}\n", .{list2.items[0]});
    try stdout.print("{s}\n", .{list2.items[1]});
    try bw.flush();

    // I am going to build an identity matrix this time, just to see how I can do a nested array list
    var matrix = std.ArrayList(std.ArrayList(i32)).init(arena.allocator());
    defer matrix.deinit();

    // I decided to do the dumb way just to understand how indicing in a nested array works
    const array_size = 10;
    for (0..array_size) |i| {
        var column = std.ArrayList(i32).init(arena.allocator());

        for (0..array_size) |j| {
            if (i == j) {
                try column.append(1);
            } else {
                try column.append(0);
            }
        }

        try matrix.append(column);
    }

    for (0..array_size) |i| {
        for (0..array_size) |j| {
            try stdout.print("{d:<3}", .{matrix.items[i].items[j]});
        }
        try stdout.print("\n", .{});
    }

    try bw.flush();
}
