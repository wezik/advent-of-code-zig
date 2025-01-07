const std = @import("std");
const Day = @import("../domain.zig").Day;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const mem = std.mem;

pub fn init() Day {
    return Day{ .day = "09", .year = "2015", .part1 = part1, .part2 = part2 };
}

fn part1(allocator: *Allocator, data: []const u8) anyerror![]const u8 {
    var input = try initInput(allocator.*, data);
    defer input.deinit();

    const product = try input.getProductDistances();
    defer allocator.free(product);

    return std.fmt.allocPrint(allocator.*, "{d}", .{mem.min(u16, product)});
}

fn part2(allocator: *std.mem.Allocator, data: []const u8) anyerror![]const u8 {
    var input = try initInput(allocator.*, data);
    defer input.deinit();

    const product = try input.getProductDistances();
    defer allocator.free(product);

    return std.fmt.allocPrint(allocator.*, "{d}", .{mem.max(u16, product)});
}

const Destination = struct {
    name: []const u8,
    distance: u16,
};

fn initInput(allocator: Allocator, data: []const u8) !Input {
    return try parse(allocator, data);
}

const Input = struct {
    allocator: Allocator,
    cities: std.StringHashMap(ArrayList(Destination)),

    // deinits parsed data
    fn deinit(self: *Input) void {
        var it = self.cities.iterator();
        while (it.next()) |entry| {
            entry.value_ptr.*.deinit();
        }
        self.cities.deinit();
    }

    // gets cartesian product and maps it to u16 distances
    fn getProductDistances(self: *Input) ![]u16 {
        var opts = ArrayList([]const u8).init(self.allocator);
        defer opts.deinit();

        var it = self.cities.keyIterator();
        while (it.next()) |key| _ = try opts.append(key.*);

        var product = try cartesianProduct(self.allocator, opts);
        defer {
            for (product.items) |p| {
                p.deinit();
            }
            product.deinit();
        }

        var distances = ArrayList(u16).init(self.allocator);
        defer distances.deinit();
        for (product.items) |p| {
            var sum: u16 = 0;
            for (0..p.items.len - 1) |i| {
                const dests = self.cities.get(p.items[i]).?;
                for (dests.items) |dest| {
                    if (mem.eql(u8, dest.name, p.items[i + 1])) {
                        sum += dest.distance;
                        break;
                    }
                }
            }
            _ = try distances.append(sum);
        }
        return distances.toOwnedSlice();
    }
};

// parses slice of bytes into a map of cities and their distance to each other
fn parse(allocator: Allocator, data: []const u8) !Input {
    var input = mem.split(u8, data, "\n");
    var cities = std.StringHashMap(ArrayList(Destination)).init(allocator);

    while (input.next()) |line| {
        if (line.len == 0) continue;

        var args_iter = mem.split(u8, line, " ");

        const from = args_iter.next().?;
        _ = args_iter.next();
        const to = args_iter.next().?;
        _ = args_iter.next();
        const dist = try std.fmt.parseInt(u16, args_iter.next().?, 10);

        var dests = if (cities.get(from)) |v| v else ArrayList(Destination).init(allocator);
        var dests2 = if (cities.get(to)) |v| v else ArrayList(Destination).init(allocator);

        _ = try dests.append(Destination{ .name = to, .distance = dist });
        _ = try dests2.append(Destination{ .name = from, .distance = dist });
        _ = try cities.put(from, dests);
        _ = try cities.put(to, dests2);
    }

    return Input{ .allocator = allocator, .cities = cities };
}

// cartesian product
fn cartesianProduct(allocator: Allocator, opts: ArrayList([]const u8)) !ArrayList(ArrayList([]const u8)) {
    var head = ArrayList([]const u8).init(allocator);
    defer head.deinit();
    return try cartesianProductRecursive(allocator, head, opts);
}

// cartesian product
fn cartesianProductRecursive(
    allocator: Allocator,
    head: ArrayList([]const u8),
    opts: ArrayList([]const u8),
) !ArrayList(ArrayList([]const u8)) {
    if (opts.items.len <= 1) {
        var sub_result = ArrayList([]const u8).init(allocator);
        _ = try sub_result.appendSlice(head.items);
        _ = try sub_result.appendSlice(opts.items);

        var result = ArrayList(ArrayList([]const u8)).init(allocator);
        _ = try result.append(sub_result);

        return result;
    }

    var result = ArrayList(ArrayList([]const u8)).init(allocator);
    for (opts.items, 0..) |opt, i| {
        var new_head = ArrayList([]const u8).init(allocator);
        _ = try new_head.appendSlice(head.items);
        _ = try new_head.append(opt);

        var new_options = try opts.clone();
        _ = new_options.orderedRemove(i);

        const sub_result = try cartesianProductRecursive(allocator, new_head, new_options);
        new_options.deinit();
        new_head.deinit();

        _ = try result.appendSlice(sub_result.items);
        sub_result.deinit();
    }

    return result;
}

test "part 1 no memory leaks" {
    var allocator = std.testing.allocator;
    const given = "London to Dublin = 464\n" ++
        "London to Belfast = 518\n" ++
        "Dublin to Belfast = 141";
    const result = try part1(&allocator, given);
    allocator.free(result);
}

test "part 2 no memory leaks" {
    var allocator = std.testing.allocator;
    const given = "London to Dublin = 464\n" ++
        "London to Belfast = 518\n" ++
        "Dublin to Belfast = 141";
    const result = try part1(&allocator, given);
    allocator.free(result);
}
