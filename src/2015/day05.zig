const std = @import("std");
const Day = @import("../domain.zig").Day;

pub fn init() Day {
    return Day{ .day = "05", .year = "2015", .part1 = part1, .part2 = part2 };
}

fn part1(allocator: *std.mem.Allocator, data: []const u8) anyerror![]const u8 {
    var input = std.mem.split(u8, data, "\n");

    const vowels = "aeiou";
    const breaking_combos = [_][]const u8{
        "ab",
        "cd",
        "pq",
        "xy",
    };

    var sum: usize = 0;
    outer: while (input.next()) |line| {
        if (line.len < 3) continue;

        // check breaking combinations
        for (breaking_combos) |combo| {
            if (std.mem.containsAtLeast(u8, line, 1, combo)) continue :outer;
        }

        // check vowel count
        var vowel_count: usize = 0;
        vowels: for (vowels) |vowel| {
            vowel_count += std.mem.count(u8, line, &.{vowel});
            if (vowel_count >= 3) break :vowels;
        } else continue :outer;

        // check if has at least one duplicate
        for (0..line.len - 1) |i| {
            if (line[i] == line[i + 1]) break;
        } else continue :outer;

        sum += 1;
    }

    return std.fmt.allocPrint(allocator.*, "{d}", .{sum});
}

fn part2(allocator: *std.mem.Allocator, data: []const u8) anyerror![]const u8 {
    var input = std.mem.split(u8, data, "\n");

    var sum: usize = 0;
    outer: while (input.next()) |line| {
        // below 4 is invalid since it won't even contain a pair
        if (line.len < 4) continue;

        // find repeating pair
        for (0..line.len - 2) |i| {
            const pair = line[i .. i + 2];
            if (std.mem.containsAtLeast(u8, line[i + 2 ..], 1, pair)) break;
        } else continue :outer;

        // find repeating char with offset of 1
        for (line[0 .. line.len - 2], 0..line.len - 2) |c, i| {
            if (c == line[i + 2]) break;
        } else continue :outer;

        sum += 1;
    }

    return std.fmt.allocPrint(allocator.*, "{d}", .{sum});
}
