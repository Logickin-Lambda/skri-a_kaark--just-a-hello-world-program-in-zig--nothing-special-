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
            node_ref: ?*Node,
        };

        head: ?*Node = null,
        tail: ?*Node = null,
        size: usize = 0,
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator) Self {
            // we don't need to care about the value of size because
            // a default value has been assigned, which is 0.
            return .{ .allocator = allocator };
        }
        // deinit will be tough because it requires to recursively
        // remove all the linked elements
        // pub fn deinit(self: *Self) void {}

        pub fn push(self: *Self, item: T) !void {
            const node = try self.allocator.create(Node);
            node.*.item = item;
            node.*.node_ref = null;

            // optional pattern with the reference to the object
            if (self.tail) |*tail| {
                tail.*.node_ref = node;
                self.*.tail = node;
            } else {
                self.head = node;
                self.tail = node;
            }

            self.size += 1;
        }

        fn search_parent(self: *Self, target: *Node) ?*Node {
            var cur_node_ptr = self.head;

            while (cur_node_ptr) |*cur_node| : (cur_node_ptr = cur_node.*.node_ref) {
                if (cur_node.*.node_ref == target) {
                    return cur_node_ptr;
                }
            }

            return null;
        }

        fn search_item_ptr(self: *Self, target: T) ?*Node {
            var cur_node_ptr_opt = self.head;

            while (cur_node_ptr_opt) |*cur_node_ptr| : (cur_node_ptr_opt = cur_node_ptr.*.node_ref) {
                if (cur_node_ptr.*.item == target) {
                    return cur_node_ptr_opt;
                }
            }

            return null;
        }

        pub fn contains(self: *Self, target: T) bool {
            if (self.search_item_ptr(target)) |_| {
                return true;
            } else {
                return false;
            }
        }
    };
}

test "linked list test" {
    var linked_list = LinkedList(i64).init(std.testing.allocator);

    try linked_list.push(45);
    std.debug.print("\nThe first item is {d}\n", .{linked_list.head.?.item});
    try std.testing.expectEqual(45, linked_list.head.?.item);
    try std.testing.expectEqual(1, linked_list.size);

    try linked_list.push(57);
    std.debug.print("\nThe first item is {d}\n", .{linked_list.head.?.item});
    std.debug.print("The next item is {d}\n", .{linked_list.head.?.node_ref.?.item});
    try std.testing.expectEqual(57, linked_list.head.?.node_ref.?.item);
    try std.testing.expectEqual(2, linked_list.size);

    try linked_list.push(69);
    const nice_ptr = linked_list.tail; // used for index search;

    try linked_list.push(81);
    const to_be_cleared_ptr = linked_list.tail; // used for index search;
    try linked_list.push(93);

    try std.testing.expectEqual(true, linked_list.contains(69));
    try std.testing.expectEqual(false, linked_list.contains(70));
    // it is used for understanding the reference assign behavior and
    try std.testing.expect(nice_ptr != to_be_cleared_ptr);

    try std.testing.expectEqual(to_be_cleared_ptr, linked_list.search_parent(linked_list.tail.?));
    try std.testing.expectEqual(nice_ptr, linked_list.search_parent(to_be_cleared_ptr.?));
}
