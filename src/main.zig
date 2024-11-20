const std = @import("std");
const array_exp = @import("arraylist_experiment.zig");
const hash_exp = @import("hashmap_experiment.zig");
const struct_exp = @import("struct_with_data_structures.zig");
const paylaod_exp = @import("param_overhead_size_test.zig");
const condest_exp = @import("constructor_pattern.zig");

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
    try array_exp.experimenting_array_list(&bw, &stdout);
    try hash_exp.experimenting_hashmap(&bw, &stdout);
    try struct_exp.experimenting_structs_with_ds(&bw, &stdout);
    try paylaod_exp.function_input_payload_test(&bw, &stdout);
    try condest_exp.test_con_destructor(&bw, &stdout);
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
