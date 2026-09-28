const Keyboard = @This();

pub var keyboard: Keyboard = undefined;

const c = @import("c");
const std = @import("std");

previous_keys: [c.SDL_SCANCODE_COUNT]bool,
current_keys: [c.SDL_SCANCODE_COUNT]bool,

pub fn init() void {
    const previous_keys: [c.SDL_SCANCODE_COUNT]bool = [_]bool{false} ** c.SDL_SCANCODE_COUNT;
    const current_keys: [c.SDL_SCANCODE_COUNT]bool = [_]bool{false} ** c.SDL_SCANCODE_COUNT;

    keyboard = .{
        .previous_keys = previous_keys,
        .current_keys = current_keys,
    };
}

pub fn tick(self: *Keyboard) void {
    self.previous_keys = self.current_keys;
    @memcpy(self.current_keys[0..], c.SDL_GetKeyboardState(0)[0..c.SDL_SCANCODE_COUNT]);
}

pub fn isKeyDown(self: *const Keyboard, key: i32) bool {
    return self.current_keys[@intCast(key)] and self.previous_keys[@intCast(key)];
}