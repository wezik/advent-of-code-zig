const std = @import("std");
const Day = @import("../domain.zig").Day;

pub fn init() Day {
    return Day{ .day = "01", .year = "2015", .part1 = part1, .part2 = part2 };
}

fn part1(allocator: *std.mem.Allocator, data: []const u8) anyerror![]const u8 {
    var floor: i32 = 0;
    for (data) |c| {
        switch (c) {
            '(' => floor += 1,
            ')' => floor -= 1,
            else => continue,
        }
    }
    return try std.fmt.allocPrint(allocator.*, "{d}", .{floor});
}

fn part2(allocator: *std.mem.Allocator, data: []const u8) anyerror![]const u8 {
    var i: usize = 0;
    var floor: i32 = 0;
    for (data) |c| {
        i += 1;
        switch (c) {
            '(' => floor += 1,
            ')' => floor -= 1,
            else => continue,
        }
        if (floor <= -1) return try std.fmt.allocPrint(allocator.*, "{d}", .{i});
    }
    return "no solution";
}
