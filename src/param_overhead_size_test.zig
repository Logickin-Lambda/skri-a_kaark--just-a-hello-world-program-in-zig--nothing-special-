const std = @import("std");

const TrackerTrackRow = struct {
    // just like C, without predefine a value, the default value are all garbage data
    // However, this design doesn't work even a constant is specificed becuase
    // the create function from the allocator only provide the space without setting any variables
    //
    pitch: ?u8 = 0, // Doesn't work; after an allocation, we will still receive garbage
    velocity: ?u8 = 0, // which is understanble because setting the value inside the allocator
    module_id: ?u16 = 0, // does sounds like a a hidden behavior which zig discourages.
    fx: ?u16 = 0,
    param: ?u16 = 0,
    meta_data: ?u32 = 0,

    // I am also thinking of testing a function that construct the struct, but
    // this will cause memory leak because there is no destructor,
    // but that will be another story for creating a proper con/destructor pattern
    fn init(allocator: std.mem.Allocator) !*TrackerTrackRow {
        const row = try allocator.create(TrackerTrackRow);

        // this is the only way to initialize the struct with default value on the heap
        row.* = .{ .pitch = 69, .velocity = 0, .module_id = 0, .fx = 0, .param = 0, .meta_data = 0 };

        return row;
    }
};

pub fn function_input_payload_test(bw: anytype, stdout: anytype) !void {
    try stdout.print("\nI am going to test the input payload size with function calls in different input type:\n", .{});
    try bw.flush();

    const page = std.heap.page_allocator;
    var arena = std.heap.ArenaAllocator.init(page);
    defer arena.deinit();

    const row1 = try TrackerTrackRow.init(arena.allocator());
    try pass_by_value(bw, stdout, row1.*);
    try pass_by_refernce(bw, stdout, row1);
}

fn pass_by_value(bw: anytype, stdout: anytype, tracker_row: TrackerTrackRow) !void {
    const byte_size = @sizeOf(@TypeOf(tracker_row));
    try stdout.print("the input size is {d} byte, passing a struct\n", .{byte_size});

    const pitch = tracker_row.pitch.?;
    try stdout.print("the pitch of the row: {d}\n", .{pitch});

    try bw.flush();
}

fn pass_by_refernce(bw: anytype, stdout: anytype, tracker_row: *TrackerTrackRow) !void {
    const byte_size = @sizeOf(@TypeOf(tracker_row));
    try stdout.print("the input size is {d} byte, passing a pointer\n", .{byte_size});

    const pitch = tracker_row.*.pitch.?;
    try stdout.print("the pitch of the row: {d}", .{pitch});

    try bw.flush();
}

// Here is the printed results:
//
// I am going to test the input payload size with function calls in different input type:
// the input size is 24 byte, passing a struct
// the pitch of the row: 0
// the input size is 8 byte, passing a pointer
// the pitch of the row: 0
//
// Not surprisingly, passing a reference is more efficient than an struct
// because reference is just an pointer which is a 64 bit number,
// while passing a struct requires to pass all the contents within.
