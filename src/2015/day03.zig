const std = @import("std");
const Day = @import("../domain.zig").Day;

pub fn init() Day {
    return Day{ .day = "03", .year = "2015", .part1 = part1, .part2 = part2 };
}

fn part1(allocator: *std.mem.Allocator, data: []const u8) anyerror![]const u8 {
    const Pos = struct {
        x: i32,
        y: i32,
    };
    var unique_locations = std.AutoHashMap(Pos, void).init(allocator.*);
    defer unique_locations.deinit();

    var santa = Pos{ .x = 0, .y = 0 };
    _ = try unique_locations.put(santa, {});

    for (data) |c| {
        switch (c) {
            '^' => santa.y += 1,
            'v' => santa.y -= 1,
            '>' => santa.x += 1,
            '<' => santa.x -= 1,
            else => continue,
        }
        _ = try unique_locations.put(santa, {});
    }
    return try std.fmt.allocPrint(allocator.*, "{d}", .{unique_locations.count()});
}

fn part2(allocator: *std.mem.Allocator, data: []const u8) anyerror![]const u8 {
    const Pos = struct {
        x: i32,
        y: i32,
    };
    var unique_locations = std.AutoHashMap(Pos, void).init(allocator.*);
    defer unique_locations.deinit();

    var santa = Pos{ .x = 0, .y = 0 };
    var robo_santa = santa;
    _ = try unique_locations.put(santa, {});

    var i: usize = 0;
    for (data) |c| {
        const current_move = if (i % 2 == 0) &santa else &robo_santa;
        switch (c) {
            '^' => current_move.*.y += 1,
            'v' => current_move.*.y -= 1,
            '>' => current_move.*.x += 1,
            '<' => current_move.*.x -= 1,
            else => continue,
        }
        i += 1;
        _ = try unique_locations.put(current_move.*, {});
    }
    return try std.fmt.allocPrint(allocator.*, "{d}", .{unique_locations.count()});
}
