const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const translate_c = b.addTranslateC(.{
        .root_source_file = b.path("src/c.h"),
        .optimize = optimize,
        .target = target
    });

    const sdl_dep = b.dependency("sdl", .{
        .optimize = optimize,
        .target = target
    });

    const exe = b.addExecutable(.{
        .name = "soilquest",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .imports = &.{
                .{
                    .name = "sdl",
                    .module = sdl_dep.module("sdl3"),
                },
                .{
                    .name = "c",
                    .module = translate_c.createModule(),
                }
            },
        }),
    });

    exe.root_module.addCSourceFile(.{
        .file = b.path("vendor/stb/stb.c"),
    });

    exe.root_module.addIncludePath(b.path("vendor"));

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_exe_tests.step);
}
