const std = @import("std");

fn test_function() void {
    std.debug.print("Simple Function\n", .{});
}

const func = test_function;

fn test_function_in_1(input: i32) void {
    std.debug.print("Fuction with input: {d}\n", .{input});
}

const func_b = test_function_in_1;

fn test_function_in_1_out(input: i32) i32 {
    std.debug.print("Fuction with input: {d}\n", .{input});
    return input + 1;
}

const func_e = test_function_in_1;

fn test_function_in_2_out_add(input_a: i32, input_b: i32) i32 {
    const result = input_a + input_b;
    std.debug.print("{d} + {d} = {d}\n", .{ input_a, input_b, result });
    return result;
}

const func_c = test_function_in_2_out_add;

fn test_function_in_2_out_mul(input_a: i32, input_b: i32) i32 {
    const result = input_a * input_b;
    std.debug.print("{d} x {d} = {d}\n", .{ input_a, input_b, result });
    return result;
}

const func_d = test_function_in_2_out_mul;

// here is the main cause, trying to pass a function into another function
fn test_function_complex(func_complex: (fn (i32, i32) i32), input_a: i32, input_b: i32) void {
    const result = func_complex(input_a, input_b);
    std.debug.print("With complex function, the result is {d}\n", .{result});
}

test "passing function as an input" {
    test_function_complex(test_function_in_2_out_mul, 4, 5);
}

test "passing function with wrong input parameter size" {
    test_function_complex(test_function_in_1_out, 4, 5);
}
