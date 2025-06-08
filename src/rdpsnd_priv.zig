const std = @import("std");
const parse = @import("parse");
const c = @cImport(
{
    @cInclude("librdpsnd.h");
});

const g_devel = false;

// c abi struct
pub const rdpsnd_priv_t = extern struct
{
    rdpsnd: c.struct_rdpsnd_t = .{},
    allocator: *const std.mem.Allocator,
};
