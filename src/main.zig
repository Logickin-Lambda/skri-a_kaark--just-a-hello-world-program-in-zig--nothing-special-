const std = @import("std");

pub fn main() !void {
    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    // Hello world in Techispiza
    // Freedom Mech! (G'day Mate!)
    try stdout.print("<!--Skri-A Kaark-->\n", .{});
    // Mech Hawk "Nova" I am. (I am Accipiter Nova)
    try stdout.print("/// Kaark.Skryka.Now-Va Zor Se\n", .{});

    try bw.flush(); // don't forget to flush!

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

    // Now, let me build another ArrayList again, but with arena allocator
    // Now I know why I got an error on using the arena allocator. It turns out
    // ArenaAllocator and Allocator are two different things, which is different
    // from java which they can be the same class of things due to inheritance.
    var list2 = std.ArrayList([]const u8).init(arena.allocator());
    defer list2.deinit();

    try list2.append("Accipiter");
    try list2.append("Nova");

    try stdout.print("{s}\n", .{list2.items[0]});
    try bw.flush();
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
