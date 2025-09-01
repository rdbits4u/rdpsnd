const std = @import("std");

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
    const librdpsnd = b.addStaticLibrary(.{
        .name = "rdpsnd",
        .root_source_file = b.path("src/librdpsnd.zig"),
        .target = target,
        .optimize = optimize,
        .strip = do_strip,
    });
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
