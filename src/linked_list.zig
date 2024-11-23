/// Linked List... yay...
/// Let's do a link list to see if I can apply all the stuff learn from the previous test
const std = @import("std");

const LinkedListError = error{
    IndexOutOfBound,
    ElementNotFound,
};

pub fn LinkedList(comptime T: type) type {
    return struct {
        const Self = @This();
        const Node = struct {
            item: T,
            node_ref: *?Node,
        };

        head: *?Node = null,
        tail: *?Node = null,
        size: usize,
        allocator: std.mem.Allocator,

        fn init(allocator: std.mem.Allocator) Self {
            return try Self{ .allocator = allocator };
        }
        // deinit will be tough because it requires to recursively
        // remove all the linked elements
        // pub fn deinit(self: *Self) void {}

        fn push(self: *Self, item: T) !void {
            const node = try self.allocator.create(Node);
            node.*.item = item;

            // optional pattern with the reference to the object
            if (self.tail) |*prev_node| {
                prev_node.node_ref = node;
                self.tail = node;
            } else {
                self.head = node;
                self.tail = node;
            }

            self.size += 1;
        }
    };
}
