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

//*****************************************************************************
// int rdpsnd_create(struct rdpsnd_t** rdpsnd);
export fn rdpsnd_create(rdpsnd: ?**c.rdpsnd_t) c_int
{
    // check if rdpsnd is nil
    if (rdpsnd) |ardpsnd|
    {
        const priv = rdpsnd_priv.create(&g_allocator) catch
                return c.LIBRDPSND_ERROR_MEMORY;
        ardpsnd.* = @ptrCast(priv);
        return c.LIBRDPSND_ERROR_NONE;
    }
    return c.LIBRDPSND_ERROR_MEMORY;
}

//*****************************************************************************
// int rdpsnd_delete(struct rdpsnd_t* rdpsnd);
export fn rdpsnd_delete(rdpsnd: ?*c.rdpsnd_t) c_int
{
    // check if rdpsnd is nil
    if (rdpsnd) |ardpsnd|
    {
        // cast c.svc_channels_t to svc_channels_priv.rdpc_priv_t
        const priv: *rdpsnd_priv.rdpsnd_priv_t = @ptrCast(ardpsnd);
        priv.delete();
    }
    return c.LIBRDPSND_ERROR_NONE;
}

//*****************************************************************************
// int rdpsnd_process_data(struct rdpsnd_t* rdpsnd, uint16_t channel_id,
//                         void* data, uint32_t bytes);
export fn rdpsnd_process_data(rdpsnd: ?*c.rdpsnd_t, channel_id: u16,
        data: ?*anyopaque, bytes: u32) c_int
{
    // check if cliprdr is nil
    if (rdpsnd) |ardpsnd|
    {
        // cast c.svc_channels_t to svc_channels_priv.rdpc_priv_t
        const priv: *rdpsnd_priv.rdpsnd_priv_t = @ptrCast(ardpsnd);
        if (data) |adata|
        {
            var slice: []u8 = undefined;
            slice.ptr = @ptrCast(adata);
            slice.len = bytes;
            return priv.process_slice(channel_id, slice) catch
                    c.LIBRDPSND_ERROR_PROCESS_DATA;
        }
    }
    return c.LIBRDPSND_ERROR_PROCESS_DATA;
}

//*****************************************************************************
// int rdpsnd_send_confirm(struct rdpsnd_t* rdpsnd, uint16_t channel_id,
//                         uint16_t timestamp, uint8_t block_no);
export fn rdpsnd_send_confirm(rdpsnd: ?*c.rdpsnd_t, channel_id: u16,
        timestamp: u16, block_no: u8) c_int
{
    // check if cliprdr is nil
    if (rdpsnd) |ardpsnd|
    {
        // cast c.svc_channels_t to svc_channels_priv.rdpc_priv_t
        const priv: *rdpsnd_priv.rdpsnd_priv_t = @ptrCast(ardpsnd);
        return priv.send_confirm(channel_id, timestamp, block_no) catch
                c.LIBRDPSND_ERROR_SEND_CONFIRM;
    }
    return c.LIBRDPSND_ERROR_SEND_CONFIRM;

}