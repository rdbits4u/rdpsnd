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
        const priv = rdpsnd_priv.rdpsnd_priv_t.create(&g_allocator) catch
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
        // cast c.rdpsnd_t to rdpsnd_priv.rdpsnd_priv_t
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
    // check if rdpsnd is nil
    if (rdpsnd) |ardpsnd|
    {
        // cast c.rdpsnd_t to rdpsnd_priv.rdpsnd_priv_t
        const priv: *rdpsnd_priv.rdpsnd_priv_t = @ptrCast(ardpsnd);
        if (data) |adata|
        {
            var slice: []u8 = undefined;
            slice.ptr = @ptrCast(adata);
            slice.len = bytes;
            const rv = priv.process_slice(channel_id, slice);
            if (rv) |arv|
            {
                return arv;
            }
            else |err|
            {
                priv.logln(@src(), "err {}", .{err}) catch
                        return c.LIBRDPSND_ERROR_PROCESS_DATA;
            }
        }
    }
    return c.LIBRDPSND_ERROR_PROCESS_DATA;
}

//*****************************************************************************
// int rdpsnd_send_confirm(struct rdpsnd_t* rdpsnd, uint16_t channel_id,
//                         uint16_t timestamp, uint8_t block_no);
export fn rdpsnd_send_waveconfirm(rdpsnd: ?*c.rdpsnd_t, channel_id: u16,
        timestamp: u16, block_no: u8) c_int
{
    // check if rdpsnd is nil
    if (rdpsnd) |ardpsnd|
    {
        // cast c.rdpsnd_t to rdpsnd_priv.rdpsnd_priv_t
        const priv: *rdpsnd_priv.rdpsnd_priv_t = @ptrCast(ardpsnd);
        return priv.send_waveconfirm(channel_id, timestamp, block_no) catch
                c.LIBRDPSND_ERROR_SEND_WAVECONFIRM;
    }
    return c.LIBRDPSND_ERROR_SEND_WAVECONFIRM;

}

//*****************************************************************************
// int rdpsnd_send_training(struct rdpsnd_t* rdpsnd, uint16_t channel_id,
//                          uint16_t time_stamp, uint16_t pack_size,
//                          void* data, uint32_t bytes);
export fn rdpsnd_send_training(rdpsnd: ?*c.rdpsnd_t, channel_id: u16,
        time_stamp: u16, pack_size: u16, data: ?*anyopaque, bytes: u32) c_int
{
    // check if rdpsnd is nil
    if (rdpsnd) |ardpsnd|
    {
        // cast c.rdpsnd_t to rdpsnd_priv.rdpsnd_priv_t
        const priv: *rdpsnd_priv.rdpsnd_priv_t = @ptrCast(ardpsnd);
        return priv.send_training(channel_id, time_stamp, pack_size,
                data, bytes) catch c.LIBRDPSND_ERROR_SEND_TRAINING;
    }
    return c.LIBRDPSND_ERROR_SEND_TRAINING;
}

//*****************************************************************************
// int rdpsnd_send_formats(struct rdpsnd_t* rdpsnd, uint16_t channel_id,
//                         uint32_t flags, uint32_t volume,
//                         uint32_t pitch, uint16_t dgram_port,
//                         uint16_t version, uint8_t block_no,
//                         uint16_t num_formats, struct format_t* formats);
export fn rdpsnd_send_formats(rdpsnd: ?*c.rdpsnd_t, channel_id: u16,
        flags: u32, volume: u32, pitch: u32, dgram_port: u16,
        version: u16, block_no: u8,
        num_formats: u16, formats: ?[*]c.rdpsnd_format_t) c_int
{
    // check if rdpsnd is nil
    if (rdpsnd) |ardpsnd|
    {
        // check if formats is nil
        if (formats) |aformats|
        {
            // cast c.rdpsnd_t to rdpsnd_priv.rdpsnd_priv_t
            const priv: *rdpsnd_priv.rdpsnd_priv_t = @ptrCast(ardpsnd);
            return priv.send_formats(channel_id, flags, volume, pitch,
                    dgram_port, version, block_no,
                    num_formats, aformats) catch
                    c.LIBRDPSND_ERROR_SEND_FORMATS;
        }
    }
    return c.LIBRDPSND_ERROR_SEND_FORMATS;
}
