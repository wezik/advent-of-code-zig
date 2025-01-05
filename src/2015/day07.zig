const std = @import("std");
const Day = @import("../domain.zig").Day;

pub fn init() Day {
    return Day{ .day = "07", .year = "2015", .part1 = part1, .part2 = part2 };
}

const Op = enum {
    AND,
    OR,
    LSHIFT,
    RSHIFT,
    NOT,
    ASSIGN,
};

const Seq = struct {
    id: []const u8,
    op: Op,
    id2: ?[]const u8,
    dest: []const u8,
};

fn parseLineToSeq(line: []const u8) !Seq {
    var split = std.mem.split(u8, line, " -> ");
    const instr = split.next() orelse return error.InvalidInput;
    const dest = split.next() orelse return error.InvalidInput;

    var instr_split = std.mem.split(u8, instr, " ");
    const arg1 = instr_split.next() orelse return error.InvalidInput;
    const arg2 = instr_split.next() orelse "";
    const arg3 = instr_split.next() orelse "";

    const op: Op = if (std.mem.eql(u8, arg2, ""))
        .ASSIGN
    else if (std.mem.eql(u8, arg1, "NOT"))
        .NOT
    else
        std.meta.stringToEnum(Op, arg2) orelse return error.InvalidInput;

    return Seq{
        .id = switch (op) {
            .NOT => arg2,
            else => arg1,
        },
        .op = op,
        .id2 = switch (op) {
            .RSHIFT, .LSHIFT, .AND, .OR => arg3,
            else => null,
        },
        .dest = dest,
    };
}

fn containsOrNumber(mem_map: std.StringHashMap(u16), key: []const u8) bool {
    return (std.fmt.parseInt(u16, key, 10) catch null) != null or mem_map.contains(key);
}

fn getOrNumber(mem_map: std.StringHashMap(u16), key: []const u8) !u16 {
    return std.fmt.parseInt(u16, key, 10) catch mem_map.get(key) orelse return error.InvalidInput;
}

fn part1(allocator: *std.mem.Allocator, data: []const u8) anyerror![]const u8 {
    var lines = std.mem.split(u8, data, "\n");

    var mem_map = std.StringHashMap(u16).init(allocator.*);
    defer mem_map.deinit();

    var exec_stack = std.ArrayList(Seq).init(allocator.*);
    defer exec_stack.deinit();

    while (lines.next()) |line| {
        if (line.len == 0) continue;
        _ = try exec_stack.append(try parseLineToSeq(line));
    }

    while (exec_stack.items.len > 0) {
        const next_index = for (exec_stack.items, 0..exec_stack.items.len) |seq, i| {
            switch (seq.op) {
                .ASSIGN => if (containsOrNumber(mem_map, seq.id)) break i,
                .NOT, .RSHIFT, .LSHIFT => if (containsOrNumber(mem_map, seq.id)) break i,
                .AND, .OR => if (containsOrNumber(mem_map, seq.id) and containsOrNumber(mem_map, seq.id2.?)) break i,
            }
        } else return error.InvalidInput;

        const next_seq = exec_stack.orderedRemove(next_index);

        switch (next_seq.op) {
            .ASSIGN => try mem_map.put(next_seq.dest, try getOrNumber(mem_map, next_seq.id)),
            .RSHIFT => try mem_map.put(next_seq.dest, try getOrNumber(mem_map, next_seq.id) >> try std.fmt.parseInt(u4, next_seq.id2.?, 10)),
            .LSHIFT => try mem_map.put(next_seq.dest, try getOrNumber(mem_map, next_seq.id) << try std.fmt.parseInt(u4, next_seq.id2.?, 10)),
            .AND => try mem_map.put(next_seq.dest, try getOrNumber(mem_map, next_seq.id) & try getOrNumber(mem_map, next_seq.id2.?)),
            .OR => try mem_map.put(next_seq.dest, try getOrNumber(mem_map, next_seq.id) | try getOrNumber(mem_map, next_seq.id2.?)),
            .NOT => try mem_map.put(next_seq.dest, ~try getOrNumber(mem_map, next_seq.id)),
        }
    }

    return try std.fmt.allocPrint(allocator.*, "{d}", .{mem_map.get("a").?});
}

fn part2(allocator: *std.mem.Allocator, data: []const u8) anyerror![]const u8 {
    const a = try part1(allocator, data);

    var split = std.mem.split(u8, data, "\n");
    var split_arr = std.ArrayList([]const u8).init(allocator.*);
    defer split_arr.deinit();
    while (split.next()) |line| {
        _ = try split_arr.append(line);
    }

    const index_to_replace = for (split_arr.items, 0..split_arr.items.len) |line, i| {
        if (std.mem.endsWith(u8, line, " -> b")) break i;
    } else return error.InvalidInput;

    split_arr.items[index_to_replace] = try std.fmt.allocPrint(allocator.*, "{s} -> b", .{a});
    defer allocator.free(split_arr.items[index_to_replace]);
    const new_data = try std.mem.join(allocator.*, "\n", split_arr.items);
    defer allocator.free(new_data);

    const new_a = try part1(allocator, new_data);

    return new_a;
}

test "part1 has no memory leaks" {
    var allocator = std.testing.allocator;
    const given = "123 -> x\n" ++
        "456 -> y\n" ++
        "x AND y -> a\n" ++
        "x OR y -> e\n" ++
        "x LSHIFT 2 -> f\n" ++
        "y RSHIFT 2 -> g\n" ++
        "NOT x -> h\n" ++
        "NOT y -> i\n";
    const result = try part1(&allocator, given);
    allocator.free(result);
}

test "part2 has no memory leaks" {
    var allocator = std.testing.allocator;
    const given = "123 -> x\n" ++
        "456 -> y\n" ++
        "x AND y -> a\n" ++
        "x OR y -> b\n" ++
        "x LSHIFT 2 -> f\n" ++
        "y RSHIFT 2 -> g\n" ++
        "NOT x -> h\n" ++
        "NOT y -> i\n";
    const result = try part1(&allocator, given);
    allocator.free(result);
}
