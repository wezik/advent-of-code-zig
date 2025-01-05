const std = @import("std");
const Day = @import("../domain.zig").Day;

pub fn init() Day {
    return Day{ .day = "06", .year = "2015", .part1 = part1, .part2 = part2 };
}

const Seq = struct {
    start: Vec2 = .{ .x = 0, .y = 0 },
    end: Vec2 = .{ .x = 0, .y = 0 },
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

fn parseLine(line: []const u8) !Seq {
    var line_split = std.mem.split(u8, line, " through ");
    const first_part = line_split.next() orelse return error.InvalidInput;

    const last_space = std.mem.lastIndexOf(u8, first_part, " ") orelse return error.InvalidInput;
    const instruction_str = first_part[0..last_space];
    const start_coords = first_part[last_space + 1 ..];

    var start_vec = std.mem.split(u8, start_coords, ",");
    var end_vec = std.mem.split(u8, line_split.next() orelse return error.InvalidInput, ",");

    return Seq{
        .instruction = std.meta.stringToEnum(Instruction, instruction_str) orelse return error.InvalidInput,
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
        const seq = try parseLine(line);

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

    var lights: [1000][1000]u8 = .{.{0} ** 1000} ** 1000;
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        const seq = try parseLine(line);

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

test "part1 has no memory leaks" {
    var allocator = std.testing.allocator;
    const given = "turn on 0,0 through 999,999\n" ++
        "turn off 499,499 through 500,500\n" ++
        "toggle 0,0 through 999,999";
    const result = try part1(&allocator, given);
    allocator.free(result);
}

test "part2 has no memory leaks" {
    var allocator = std.testing.allocator;
    const given = "turn on 0,0 through 999,999\n" ++
        "turn off 499,499 through 500,500\n" ++
        "toggle 0,0 through 999,999";
    const result = try part2(&allocator, given);
    allocator.free(result);
}
