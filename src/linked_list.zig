/// Linked List... yay...
/// Let's do a link list to see if I can apply all the stuff learn from the previous test
const std = @import("std");

const LinkedListError = error{
    IndexOutOfBound,
    ElementNotFound,
};

pub fn LinkedList(comptime T: type) type {
    return struct {
        // to build a dynamic sized data structure, we need to build a base with
        // a pointer to the collections, and a struct storing the actual data
        const Self = @This();
        const Node = struct {
            item: T,
            node_ref: ?*Node = null,
        };
        head: ?*Node = null,
        tail: ?*Node = null,
        size: usize = 0,
        allocator: std.mem.Allocator,

        // this is like a constructor, returning an instance of LinkedList
        // so that I can call all the operations that manipulate the linked list.
        pub fn init(allocator: std.mem.Allocator) Self {
            // we don't need to care about the value of size because
            // a default value has been assigned, which is 0.
            return .{ .allocator = allocator };
        }

        pub fn deinit(self: *Self) void {
            var cur_ptr_opt = self.head;

            while (cur_ptr_opt) |cur_ptr| {
                // I have to do that before destory the current node;
                // otherwise, the reference will be lost
                const next_node = cur_ptr.node_ref;
                self.allocator.destroy(cur_ptr);

                cur_ptr_opt = next_node;
            }
        }

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

        pub fn insert_after(self: *Self, item: T, after: T) !void {
            const target = self.search_item_ptr(after);

            if (target == null) return LinkedListError.ElementNotFound;
            const next_opt = target.?.*.node_ref;
            const new = try self.allocator.create(Node);
            new.item = item;

            if (next_opt != null) {
                target.?.*.node_ref = new;
                new.node_ref = next_opt;
            } else {
                target.?.*.node_ref = new;
            }

            self.size += 1;
        }

        pub fn pop(self: *Self) T {
            const item = self.tail.?.item;
            const parent = self.search_parent(self.tail.?);
            parent.?.node_ref = null;
            self.allocator.destroy(self.tail.?);
            self.tail = parent;
            self.size -= 1;

            return item;
        }

        pub fn remove(self: *Self, item: T) !void {
            // this is not well thought, but the purpose of this project
            // is to be comfortable in zig, not writing a optimized linked list
            // so I decided take a slower but cleaner approach:
            const item_ptr = self.search_item_ptr(item);
            if (item_ptr == null) return LinkedListError.ElementNotFound;

            // empty pointer means the item is located at the head
            const parent_ptr_opt = self.search_parent(item_ptr.?);

            if (parent_ptr_opt) |*parent_ptr| {
                const next_ptr_opt = item_ptr.?.*.node_ref;
                self.allocator.destroy(item_ptr.?);

                if (next_ptr_opt != null) {
                    parent_ptr.*.node_ref = next_ptr_opt;
                } else {
                    parent_ptr.*.node_ref = null;
                    self.tail = parent_ptr_opt;
                }
            } else {
                const next_ptr_opt = item_ptr.?.node_ref;
                self.allocator.destroy(item_ptr.?);

                if (next_ptr_opt != null) {
                    self.head = next_ptr_opt;
                } else {
                    self.head = null;
                    self.tail = null;
                }
            }

            self.size -= 1;
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

// Please don't follow writing unit test in this way since I should test each operation separately,
// but I got a bit lazy with it.
test "linked list test" {
    var linked_list = LinkedList(i64).init(std.testing.allocator);
    defer linked_list.deinit();

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

    try std.testing.expectEqual(93, linked_list.pop());
    try std.testing.expectEqual(4, linked_list.size);

    try linked_list.remove(57);
    std.debug.print("\nThe first item is {d}\n", .{linked_list.head.?.item});
    std.debug.print("The next item is {d}\n", .{linked_list.head.?.node_ref.?.item});
    try std.testing.expectEqual(45, linked_list.head.?.item);
    try std.testing.expectEqual(69, linked_list.head.?.node_ref.?.item);
    try std.testing.expectEqual(3, linked_list.size);

    try linked_list.push(105);
    try linked_list.push(117);
    try linked_list.push(129);

    // removing the head and tail elements:
    try linked_list.remove(45);
    try linked_list.remove(129);
    try std.testing.expectError(LinkedListError.ElementNotFound, linked_list.remove(999));

    try std.testing.expectEqual(4, linked_list.size);
    const expected_answer1 = [4]i64{ 69, 81, 105, 117 };

    var cur_ptr = linked_list.head;
    var i: usize = 0;
    while (cur_ptr) |ptr| {
        const next = ptr.node_ref;
        try std.testing.expectEqual(expected_answer1[i], ptr.*.item);

        cur_ptr = next;
        i += 1;
    }

    try linked_list.insert_after(88, 105);

    try std.testing.expectEqual(5, linked_list.size);
    const expected_answer2 = [5]i64{ 69, 81, 105, 88, 117 };

    cur_ptr = linked_list.head;
    i = 0;
    while (cur_ptr) |ptr| {
        const next = ptr.node_ref;
        try std.testing.expectEqual(expected_answer2[i], ptr.*.item);

        cur_ptr = next;
        i += 1;
    }
}
