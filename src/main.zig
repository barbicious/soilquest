const std = @import("std");

const c = @import("c");

pub fn main() !void {
    if (!c.SDL_Init(c.SDL_INIT_VIDEO)) {
        return error.FailedToInitSDL;
    }

    defer c.SDL_Quit();

    const window = c.SDL_CreateWindow("Soilquest", 1280, 720, 0) orelse return error.FailedToCreateWindow;
    const renderer = c.SDL_CreateRenderer(window, null) orelse return error.FailedToCreateRenderer;
    const screen = c.SDL_CreateTexture(renderer, c.SDL_PIXELFORMAT_ARGB8888, c.SDL_TEXTUREACCESS_STREAMING, 320, 180);

    _ = c.SDL_SetTextureScaleMode(screen, c.SDL_SCALEMODE_NEAREST);

    var running = true;

    var event: c.SDL_Event = undefined;

    while (running) {
        while (c.SDL_PollEvent(&event)) {
            if (event.type == c.SDL_EVENT_QUIT) {
                running = false;
            }
        }

        _ = c.SDL_RenderClear(renderer);

        var buffer: ?*anyopaque = null;
        var pitch: i32 = undefined;
        _ = c.SDL_LockTexture(screen, null, &buffer, &pitch);

        var pixels: [*]u32 = @ptrCast(@alignCast(buffer));

        pixels[0] = 0xFF00FFFF;

        c.SDL_UnlockTexture(screen);

        _ = c.SDL_RenderTexture(renderer, screen, null, null);

        _ = c.SDL_RenderPresent(renderer);
    }
}