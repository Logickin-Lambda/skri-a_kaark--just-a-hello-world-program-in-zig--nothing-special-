/// Linked List... yay...
/// Let's do a link list to see if I can apply all the stuff learn from the previous test
const std = @import("std");

pub fn LinkedList(comptime T: type) type {
    return struct {
        const Self = @This();

        data: T,
        node_ref: *LinkedList,
        allocator: *std.mem.Allocator,

        fn init(self: *Self, allocator: *std.mem.Allocator) Self {
            return try allocator.create(self);
        }

        // deinit will be tough because it requires to recursively
        // remove all the linked elements
        // pub fn deinit(self: *Self) void {}
    };
}
