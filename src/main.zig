const std = @import("std");
const State = @import("State.zig");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.arena.allocator();

    _ = std.debug.lockStderr(&.{});
    std.debug.unlockStderr();

    var state: State = try .init(allocator, io);
    defer state.deinit(allocator);
    state.run(io);
}