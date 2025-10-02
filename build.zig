const std = @import("std");
const builtin = @import("builtin");

//*****************************************************************************
pub fn build(b: *std.Build) void
{
    // build options
    const do_strip = b.option(
        bool,
        "strip",
        "Strip the executabes"
    ) orelse false;
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    // librdpsnd
    const librdpsnd = myAddStaticLibrary(b, "rdpsnd", target, optimize, do_strip);
    librdpsnd.root_module.root_source_file = b.path("src/librdpsnd.zig");
    librdpsnd.linkLibC();
    librdpsnd.addIncludePath(b.path("../common"));
    librdpsnd.addIncludePath(b.path("include"));
    librdpsnd.root_module.addImport("parse", b.createModule(.{
        .root_source_file = b.path("../common/parse.zig"),
    }));
    librdpsnd.root_module.addImport("hexdump", b.createModule(.{
        .root_source_file = b.path("../common/hexdump.zig"),
    }));
    librdpsnd.root_module.addImport("strings", b.createModule(.{
        .root_source_file = b.path("../common/strings.zig"),
    }));
    b.installArtifact(librdpsnd);
}

//*****************************************************************************
fn myAddStaticLibrary(b: *std.Build, name: []const u8,
        target: std.Build.ResolvedTarget,
        optimize: std.builtin.OptimizeMode,
        do_strip: bool) *std.Build.Step.Compile
{
    if ((builtin.zig_version.major == 0) and (builtin.zig_version.minor < 15))
    {
        return b.addStaticLibrary(.{
            .name = name,
            .target = target,
            .optimize = optimize,
            .strip = do_strip,
        });
    }
    return b.addLibrary(.{
        .name = name,
        .root_module = b.addModule(name, .{
            .target = target,
            .optimize = optimize,
            .strip = do_strip,
        }),
        .linkage = .static,
    });
}
