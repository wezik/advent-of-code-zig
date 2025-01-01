const std = @import("std");
const Day = @import("../domain.zig").Day;

pub fn init() Day {
    return Day{ .day = "01", .year = "2015", .part1 = part1, .part2 = part2 };
}

fn part1(allocator: *std.mem.Allocator, data: []const u8) anyerror![]const u8 {
    _ = allocator;
    _ = data;
    return "part 1 not implemented";
}

fn part2(allocator: *std.mem.Allocator, data: []const u8) anyerror![]const u8 {
    _ = allocator;
    _ = data;
    return "part 2 not implemented";
}
