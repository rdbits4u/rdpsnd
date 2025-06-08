const std = @import("std");
const rdpsnd_priv = @import("rdpsnd_priv.zig");
const c = @cImport(
{
    @cInclude("librdpsnd.h");
});

var g_allocator: std.mem.Allocator = std.heap.c_allocator;

//*****************************************************************************
// int rdpsnd_init(void);
export fn rdpsnd_init() c_int
{
    return c.LIBRDPSND_ERROR_NONE;
}

//*****************************************************************************
// int rdpsnd_deinit(void);
export fn rdpsnd_deinit() c_int
{
    return c.LIBRDPSND_ERROR_NONE;
}
