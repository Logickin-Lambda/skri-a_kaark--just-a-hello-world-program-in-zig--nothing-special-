const std = @import("std");

const ModuleType = enum { generator, filter, metamodule };
const ModuleClass = enum { synth, effect, misc };

const SunVoxModule = struct {
    module_name: ModuleType,
    module_class: ModuleClass,
    no_controllers: u8,
};

pub fn experimenting_structs_with_ds(bw: anytype, stdout: anytype) !void {
    try stdout.print("\nPlaying around structs\n", .{});
    try bw.flush();

    // declare a struct:
    var generator = SunVoxModule{
        .module_name = ModuleType.generator,
        .module_class = ModuleClass.synth,
        .no_controllers = 16,
    };
    const filter = SunVoxModule{
        .module_name = ModuleType.filter,
        .module_class = ModuleClass.effect,
        .no_controllers = 12,
    };
    const metamodule = SunVoxModule{
        .module_name = ModuleType.metamodule,
        .module_class = ModuleClass.misc,
        .no_controllers = 18,
    };

    // @tagName can print the name of an enum
    try stdout.print("Module: {s}\n", .{@tagName(generator.module_name)});
    try bw.flush();

    // And here, I am going to apply everything I have learnt, to see if I can create:
    // - Array of Struct
    // - ArrayList of Struct
    // - HashMap of Struct, indexed by u32

    const page = std.heap.page_allocator;
    var arena = std.heap.ArenaAllocator.init(page);
    defer arena.deinit();

    // fixed sized array:
    var struct_arr = [3]?SunVoxModule{ null, null, null };

    struct_arr[0] = generator;
    struct_arr[1] = filter;
    struct_arr[2] = metamodule;

    try stdout.print("\nHere are the full list of Modules:\n\n", .{});

    for (struct_arr) |module| {
        try stdout.print("Module {s}, type: {s}, no. controllers: {d}\n", .{
            @tagName(module.?.module_name),
            @tagName(module.?.module_class),
            module.?.no_controllers,
        });
    }

    try bw.flush();

    // Now, let me declare an ArrayList, but with struct just to see my understanding
    var module_list = std.ArrayList(?SunVoxModule).init(arena.allocator());
    defer module_list.deinit();

    try module_list.append(generator);
    try module_list.append(filter);
    try module_list.append(metamodule);

    try stdout.print("\nHere are the full list of Modules, but with ArrayList:\n\n", .{});

    for (module_list.items) |module| {
        try stdout.print("Module {s}, type: {s}, no. controllers: {d}\n", .{
            @tagName(module.?.module_name),
            @tagName(module.?.module_class),
            module.?.no_controllers,
        });
    }

    try bw.flush();

    // along with a map of struct
    var module_map = std.AutoHashMap(u32, ?SunVoxModule).init(arena.allocator());
    defer module_map.deinit();

    try module_map.put(69, generator);
    try module_map.put(420, filter);
    try module_map.put(69420, metamodule);

    try stdout.print("\nHere are the full list of Modules, but with HashMap.\n", .{});
    try stdout.print("You can observe the unordered nature of hashmap\n", .{});
    try stdout.print("because it is not aligned to the insertion order:\n\n", .{});
    var map_iter = module_map.iterator();

    while (map_iter.next()) |entry| {
        const module = entry.value_ptr.*;
        const module_id = entry.key_ptr.*;

        try stdout.print("Module {s} ({d}), type: {s}, no. controllers: {d}\n", .{
            @tagName(module.?.module_name),
            module_id,
            @tagName(module.?.module_class),
            module.?.no_controllers,
        });
    }

    try bw.flush();

    // Bonus: I need to know if the all the declared structs are passed by reference or value,
    // so I will try to modify the connection property of the generator module.
    // If the changes applies to all data structure, it will be pass by refernce, otherwise value.
    generator.no_controllers = 99;
    struct_arr[0].?.no_controllers = 89;
    module_list.items[0].?.no_controllers = 79;
    // module_map.get(69).?.?.no_controllers = 69; // don't seem to find a way currently, but this is not the point

    try stdout.print("\nthe controller number for {s} is the following:\n", .{@tagName(generator.module_name)});
    try stdout.print("{d},{d},{d},{d}\n", .{
        generator.no_controllers,
        struct_arr[0].?.no_controllers,
        module_list.items[0].?.no_controllers,
        module_map.get(69).?.?.no_controllers,
    });

    try stdout.print("Since all values are updated independently, zig struct is pass by value\n", .{});
    try stdout.print("This is similar to C, so I will do a experiment about the overhead on function calls\n", .{});

    try bw.flush();
}
