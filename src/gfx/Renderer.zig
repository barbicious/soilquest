const Renderer = @This();

const sdl = @import("sdl");

const PixelBuffer = @import("PixelBuffer.zig");
const Palette = @import("Palette.zig");
const Texture = @import("Texture.zig");
const math = @import("../math.zig");

screen: *sdl.SDL_Texture,
renderer: *sdl.SDL_Renderer,
pixel_buffer: PixelBuffer,
palette: Palette,

pub fn init(window: *sdl.SDL_Window) !Renderer {
    const renderer = sdl.SDL_CreateRenderer(window, null) orelse return error.FailedToCreateRenderer;

    const screen = sdl.SDL_CreateTexture(renderer, sdl.SDL_PIXELFORMAT_ARGB8888, sdl.SDL_TEXTUREACCESS_STREAMING, PixelBuffer.width, PixelBuffer.height) orelse return error.FailedToCreateScreenTexture;
    _ = sdl.SDL_SetTextureScaleMode(screen, sdl.SDL_SCALEMODE_NEAREST);

    return .{
        .renderer = renderer,
        .screen = screen,
        .palette = .init(),
        .pixel_buffer = .init(),
    };
}

pub fn deinit(self: *const Renderer) void {
    sdl.SDL_DestroyTexture(self.screen);
    sdl.SDL_DestroyRenderer(self.renderer);
}

pub fn flush(self: *Renderer) void {
    _ = sdl.SDL_RenderClear(self.renderer);

    @memset(&self.pixel_buffer.pixels, 0);
}

pub fn splat(self: *Renderer) void {
    var buffer: ?*anyopaque = null;
    var pitch: i32 = undefined;
    _ = sdl.SDL_LockTexture(self.screen, null, &buffer, &pitch);

    @memcpy(@as([*]u32, @ptrCast(@alignCast(buffer))), &self.pixel_buffer.pixels);

    sdl.SDL_UnlockTexture(self.screen);

    _ = sdl.SDL_RenderTexture(self.renderer, self.screen, null, null);

    _ = sdl.SDL_RenderPresent(self.renderer);
}

pub fn blitTexture(self: *Renderer, texture_id: usize, src: math.Rect(u32), dst: math.Point(i32), colors: [Texture.channels]usize) void {
    const texture = Texture.registry.textures.items[texture_id];

    for (0..src.h) |y| {
        const py = y + @as(usize, @intCast(dst.y));
        if (py < 0 or py >= PixelBuffer.height) {
            continue;
        }

        for (0..src.w) |x| {
            const px = x + @as(usize, @intCast(dst.x));
            if (px < 0 or px >= PixelBuffer.width) {
                continue;
            }

            const pixel = texture.pixelAt(x + @as(usize, @intCast(src.x)), y + @as(usize, @intCast(src.y)));

            if (pixel == Texture.transparent_pixel) {
                continue;
            }

            self.pixel_buffer.setPixel(px, py, self.palette.shades[colors[pixel]]);
        }
    }
}
