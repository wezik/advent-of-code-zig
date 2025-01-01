const std = @import("std");
const Day = @import("../domain.zig").Day;

pub fn init() Day {
    return Day{ .day = "02", .year = "2015", .part1 = part1, .part2 = part2 };
}

fn part1(allocator: *std.mem.Allocator, data: []const u8) anyerror![]const u8 {
    var lines = std.mem.split(u8, data, "\n");
    var sum: i32 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        var lines_split = std.mem.split(u8, line, "x");
        var values = std.ArrayList(i32).init(allocator.*);
        while (lines_split.next()) |val_str| {
            _ = try values.append(std.fmt.parseInt(i32, val_str, 10) catch return error.InvalidInput);
        }
        const a = values.items[0] * values.items[1];
        const b = values.items[1] * values.items[2];
        const c = values.items[2] * values.items[0];
        sum += 2 * a + 2 * b + 2 * c;
        sum += std.mem.min(i32, &.{ a, b, c });
    }

    return try std.fmt.allocPrint(allocator.*, "{d}", .{sum});
}

fn part2(allocator: *std.mem.Allocator, data: []const u8) anyerror![]const u8 {
    var lines = std.mem.split(u8, data, "\n");
    var sum: i32 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        var lines_split = std.mem.split(u8, line, "x");
        var values = std.ArrayList(i32).init(allocator.*);
        while (lines_split.next()) |val_str| {
            _ = try values.append(std.fmt.parseInt(i32, val_str, 10) catch return error.InvalidInput);
        }
        std.mem.sort(i32, values.items, {}, std.sort.asc(i32));
        sum += 2 * values.items[0] + 2 * values.items[1] + values.items[0] * values.items[1] * values.items[2];
    }

    return try std.fmt.allocPrint(allocator.*, "{d}", .{sum});
}
