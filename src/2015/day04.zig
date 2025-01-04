const std = @import("std");
const hash = std.crypto.hash;
const Day = @import("../domain.zig").Day;

pub fn init() Day {
    return Day{ .day = "04", .year = "2015", .part1 = part1, .part2 = part2 };
}

var starting_offset: usize = 0;

fn part1(allocator: *std.mem.Allocator, data: []const u8) anyerror![]const u8 {
    const input = std.mem.trim(u8, data, "\n");

    var i: usize = starting_offset;

    outer: while (true) : (i += 1) {
        const str_to_hash = try std.fmt.allocPrint(allocator.*, "{s}{d}", .{ input, i });
        defer allocator.free(str_to_hash);

        // idk yet how to define such buffer using allocators with this hash function :(
        // this causes memory leak
        var buf: [hash.Md5.digest_length]u8 = undefined;
        hash.Md5.hash(str_to_hash, &buf, .{});

        for (0..3) |j| {
            const hex = try std.fmt.allocPrint(allocator.*, "{X}", .{buf[j]});
            defer allocator.free(hex);
            if (!std.mem.eql(u8, hex, "0") and !(hex.len < 2 and j == 2)) {
                continue :outer;
            }
        }
        return try std.fmt.allocPrint(allocator.*, "{d}", .{i});
    }
    unreachable;
}

fn part2(allocator: *std.mem.Allocator, data: []const u8) anyerror![]const u8 {
    const input = std.mem.trim(u8, data, "\n");

    var i: usize = 0;

    outer: while (true) : (i += 1) {
        const str_to_hash = try std.fmt.allocPrint(allocator.*, "{s}{d}", .{ input, i });
        defer allocator.free(str_to_hash);

        // idk yet how to define such buffer using allocators with this hash function :(
        // this causes memory leak
        var buf: [hash.Md5.digest_length]u8 = undefined;
        hash.Md5.hash(str_to_hash, &buf, .{});

        for (0..3) |j| {
            const hex = try std.fmt.allocPrint(allocator.*, "{X}", .{buf[j]});
            defer allocator.free(hex);
            if (!std.mem.eql(u8, hex, "0")) {
                continue :outer;
            }
        }
        return try std.fmt.allocPrint(allocator.*, "{d}", .{i});
    }
    unreachable;
}

test "part1 abcdef" {
    var allocator = std.testing.allocator;
    const given = "abcdef";
    starting_offset = 600000;
    const result = try part1(&allocator, given);
    _ = try std.testing.expectEqualStrings("609043", result);
}
