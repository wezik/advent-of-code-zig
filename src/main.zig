const std = @import("std");
const writer = std.io.getStdOut().writer();
const Day = @import("domain.zig").Day;
const Day1 = @import("2015/day01.zig").init();
const Day2 = @import("2015/day02.zig").init();
const Day3 = @import("2015/day03.zig").init();
const Day4 = @import("2015/day04.zig").init();
const Day5 = @import("2015/day05.zig").init();

pub fn main() !void {
    var args = std.process.args();
    const bin = args.next() orelse return;
    const day = args.next() orelse return usage(bin);
    const day_int = std.fmt.parseInt(u8, day, 10) catch return usage(bin);
    const session_cookie = args.next() orelse return usage(bin);
    defer args.deinit();
    switch (day_int) {
        1 => try runDay(Day1, session_cookie),
        2 => try runDay(Day2, session_cookie),
        3 => try runDay(Day3, session_cookie),
        4 => try runDay(Day4, session_cookie),
        5 => try runDay(Day5, session_cookie),
        else => return error.DayNotImplemented,
    }
}

fn runDay(day: Day, session_cookie: []const u8) !void {
    var file_allocator = std.heap.page_allocator;
    const data = try readInput(&file_allocator, day, session_cookie);

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();
    _ = try writer.print("part 1: {s}\n", .{try day.part1(&allocator, data)});
    _ = arena.reset(.free_all);
    _ = try writer.print("part 2: {s}\n", .{try day.part2(&allocator, data)});
}

fn usage(bin: []const u8) !void {
    _ = try writer.print("Usage: {s} <day> <session cookie>\n", .{bin});
}

fn readInput(allocator: *std.mem.Allocator, day: Day, session_cookie: []const u8) ![]const u8 {
    const cwd = std.fs.cwd();

    const path = try std.fmt.allocPrint(allocator.*, "inputs/{s}", .{day.year});
    defer allocator.free(path);

    var dir = try cwd.makeOpenPath(path, .{});
    defer dir.close();

    const file_name = try std.fmt.allocPrint(allocator.*, "{s}.txt", .{day.day});
    defer allocator.free(file_name);
    var file = blk: {
        const file_result = dir.openFile(file_name, .{ .mode = .read_only }) catch |err| switch (err) {
            error.FileNotFound => {
                var file_result = try dir.createFile(file_name, .{ .read = true });
                var file_writer = file_result.writer();

                const day_int = std.fmt.parseInt(u8, day.day, 10) catch unreachable;
                const url = try std.fmt.allocPrint(allocator.*, "https://adventofcode.com/{s}/day/{d}/input", .{ day.year, day_int });

                defer allocator.free(url);
                const body = try fetchInput(allocator, url, session_cookie);
                _ = try file_writer.writeAll(body);
                defer allocator.free(body);
                file_result.close();
                break :blk try dir.openFile(file_name, .{ .mode = .read_only });
            },
            else => return err,
        };
        break :blk file_result;
    };
    defer file.close();

    return try file.readToEndAlloc(allocator.*, 1024 * 512);
}

fn fetchInput(allocator: *std.mem.Allocator, url: []const u8, session_cookie: []const u8) ![]const u8 {
    _ = try writer.print("fetching {s}...", .{url});
    const uri = try std.Uri.parse(url);

    var client = std.http.Client{ .allocator = allocator.* };
    defer client.deinit();

    const server_header_buffer = try allocator.alloc(u8, 1024);
    defer allocator.free(server_header_buffer);

    const session_cookie_value = try std.fmt.allocPrint(allocator.*, "session={s}", .{session_cookie});
    defer allocator.free(session_cookie_value);
    const cookie_header = std.http.Header{ .name = "Cookie", .value = session_cookie_value };
    var req = try client.open(.GET, uri, .{
        .extra_headers = &.{cookie_header},
        .server_header_buffer = server_header_buffer,
    });
    defer req.deinit();
    _ = try req.send();
    _ = try req.wait();
    _ = try writer.print(" {?s}\n", .{req.response.status.phrase()});

    return try req.reader().readAllAlloc(allocator.*, 1024 * 512);
}
