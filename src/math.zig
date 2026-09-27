pub fn Rect(comptime T: type) type {
    return struct {
        x: T,
        y: T,
        w: T,
        h: T,
    };
}

pub fn Point(comptime T: type) type {
    return struct {
        x: T,
        y: T,
    };
}
