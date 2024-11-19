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
    const generator = SunVoxModule{
        .module_name = ModuleType.generator,
        .module_class = ModuleClass.synth,
        .no_controllers = 16,
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
    struct_arr[1] = SunVoxModule{
        .module_name = ModuleType.filter,
        .module_class = ModuleClass.effect,
        .no_controllers = 12,
    };
    struct_arr[2] = SunVoxModule{
        .module_name = ModuleType.metamodule,
        .module_class = ModuleClass.misc,
        .no_controllers = 18,
    };

    try stdout.print("\nHere are the full list of Modules:\n", .{});

    for (struct_arr) |module| {
        try stdout.print("Module {s}, type: {s}, no. controllers: {d}\n", .{
            @tagName(module.?.module_name),
            @tagName(module.?.module_class),
            module.?.no_controllers,
        });
    }

    try bw.flush();
}
