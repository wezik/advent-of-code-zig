const std = @import("std");
const Day = @import("../domain.zig").Day;

pub fn init() Day {
    return Day{ .day = "06", .year = "2015", .part1 = part1, .part2 = part2 };
}

const Seq = struct {
    start: Vec2 = Vec2{ .x = 0, .y = 0 },
    end: Vec2 = Vec2{ .x = 0, .y = 0 },
    instruction: Instruction = .@"turn on",
};

const Instruction = enum {
    @"turn on",
    @"turn off",
    toggle,
};

const Vec2 = struct {
    x: usize,
    y: usize,
};

fn parseLine(allocator: *std.mem.Allocator, line: []const u8) !Seq {
    var line_split = std.mem.split(u8, line, " through ");

    var first_split = std.mem.split(u8, line_split.next() orelse return error.InvalidInput, " ");

    var first_parts = std.ArrayList([]const u8).init(allocator.*);
    defer first_parts.deinit();
    while (first_split.next()) |part| {
        _ = try first_parts.append(part);
    }

    var start_vec = std.mem.split(u8, first_parts.items[first_parts.items.len - 1], ",");
    var end_vec = std.mem.split(u8, line_split.next() orelse return error.InvalidInput, ",");

    return Seq{
        .instruction = std.meta.stringToEnum(
            Instruction,
            try std.mem.join(allocator.*, " ", first_parts.items[0 .. first_parts.items.len - 1]),
        ) orelse return error.InvalidInput,
        .start = Vec2{
            .x = try std.fmt.parseInt(usize, start_vec.next() orelse return error.InvalidInput, 10),
            .y = try std.fmt.parseInt(usize, start_vec.next() orelse return error.InvalidInput, 10),
        },
        .end = Vec2{
            .x = try std.fmt.parseInt(usize, end_vec.next() orelse return error.InvalidInput, 10),
            .y = try std.fmt.parseInt(usize, end_vec.next() orelse return error.InvalidInput, 10),
        },
    };
}

fn part1(allocator: *std.mem.Allocator, data: []const u8) anyerror![]const u8 {
    var lines = std.mem.split(u8, data, "\n");

    var lights: [1000][1000]bool = .{.{false} ** 1000} ** 1000;
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        const seq = try parseLine(allocator, line);

        for (seq.start.y..seq.end.y + 1) |y| {
            for (seq.start.x..seq.end.x + 1) |x| {
                switch (seq.instruction) {
                    .@"turn on" => lights[y][x] = true,
                    .@"turn off" => lights[y][x] = false,
                    .toggle => lights[y][x] = !lights[y][x],
                }
            }
        }
    }

    var result: usize = 0;
    for (lights) |row| {
        result += std.mem.count(bool, &row, &.{true});
    }
    return std.fmt.allocPrint(allocator.*, "{d}", .{result});
}

fn part2(allocator: *std.mem.Allocator, data: []const u8) anyerror![]const u8 {
    var lines = std.mem.split(u8, data, "\n");

    // _ = data;
    // const foo = "turn off 0,0 through 999,999";
    // var lines = std.mem.split(u8, foo, "\n");

    var lights: [1000][1000]u8 = .{.{0} ** 1000} ** 1000;

    while (lines.next()) |line| {
        if (line.len == 0) continue;
        const seq = try parseLine(allocator, line);

        for (seq.start.y..seq.end.y + 1) |y| {
            for (seq.start.x..seq.end.x + 1) |x| {
                switch (seq.instruction) {
                    .@"turn on" => lights[y][x] += 1,
                    .@"turn off" => lights[y][x] = if (lights[y][x] > 0) lights[y][x] - 1 else 0,
                    .toggle => lights[y][x] += 2,
                }
            }
        }
    }

    var total_brightness: usize = 0;

    for (lights) |row| {
        for (row) |cell| {
            total_brightness += cell;
        }
    }

    return std.fmt.allocPrint(allocator.*, "{d}", .{total_brightness});
}