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

    try list.append("Notey"); // foo bar are overrated, I wanna use Notey (yep) instead
    try list.append("(yep)");
    try list.append("(what)");
    try list.append("(???)");

    for (list.items) |item| {
        try stdout.print("{s}\n", .{item});
    }
    try bw.flush();

    list.deinit();
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
