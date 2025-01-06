const std = @import("std");
const Day = @import("../domain.zig").Day;

pub fn init() Day {
    return Day{ .day = "08", .year = "2015", .part1 = part1, .part2 = part2 };
}

fn part1(allocator: *std.mem.Allocator, data: []const u8) anyerror![]const u8 {
    var input = std.mem.split(u8, data, "\n");

    var code_sum: usize = 0;
    var mem_sum: usize = 0;

    while (input.next()) |line| {
        if (line.len == 0) continue;

        var i: usize = 1;
        var offset: usize = 0;
        while (i + offset <= line.len - 1) : (i += 1) {
            if (line[i + offset] != '\\') continue;
            switch (line[i + offset + 1]) {
                'x' => offset += 3,
                '\\', '"' => offset += 1,
                else => return error.InvalidEscapeCharacter,
            }
        }

        code_sum += line.len;
        // length - quotes - escape chars
        mem_sum += line.len - 2 - offset;
    }
    return std.fmt.allocPrint(allocator.*, "{d}", .{code_sum - mem_sum});
}

fn part2(allocator: *std.mem.Allocator, data: []const u8) anyerror![]const u8 {
    var input = std.mem.split(u8, data, "\n");

    var old_len: usize = 0;
    var new_len: usize = 0;

    while (input.next()) |line| {
        if (line.len == 0) continue;
        old_len += line.len;

        const new_line_p1 = try std.mem.replaceOwned(u8, allocator.*, line, "\\", "\\\\");
        defer allocator.free(new_line_p1);

        const new_line_p2 = try std.mem.replaceOwned(u8, allocator.*, new_line_p1, "\"", "\\\"");
        defer allocator.free(new_line_p2);

        new_len += new_line_p2.len + 2;
    }
    return std.fmt.allocPrint(allocator.*, "{d}", .{new_len - old_len});
}

test "part 1 no memory leaks" {
    var allocator = std.testing.allocator;

    const input = "\"abc\"\n\"\\x12def\"\n\"ghi\"\n\"jkl\"\n\"mno\"\n\"pqr\"\n\"stu\"\n\"vwx\"\n\"yz\"";
    const result = try part1(&allocator, input);
    allocator.free(result);
}

test "part 2 no memory leaks" {
    var allocator = std.testing.allocator;

    const input = "\"abc\"\n\"\\x12def\"\n\"ghi\"\n\"jkl\"\n\"mno\"\n\"pqr\"\n\"stu\"\n\"vwx\"\n\"yz\"";
    const result = try part2(&allocator, input);
    allocator.free(result);
}
