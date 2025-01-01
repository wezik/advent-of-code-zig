const std = @import("std");

pub const Day = struct {
    day: []const u8,
    year: []const u8,
    part1: *const fn (allocator: *std.mem.Allocator, data: []const u8) anyerror![]const u8,
    part2: *const fn (allocator: *std.mem.Allocator, data: []const u8) anyerror![]const u8,
};
