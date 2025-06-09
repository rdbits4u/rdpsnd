const std = @import("std");
const parse = @import("parse");
const c = @cImport(
{
    @cInclude("librdpsnd.h");
});

const g_devel = false;

const SNDC_CLOSE        = 0x01;     // Close PDU
const SNDC_WAVE         = 0x02;     // WaveInfo PDU
const SNDC_SETVOLUME    = 0x03;     // Volume PDU
const SNDC_SETPITCH     = 0x04;     // Pitch PDU
const SNDC_WAVECONFIRM  = 0x05;     // Wave Confirm PDU
const SNDC_TRAINING     = 0x06;     // Training PDU or Training Confirm PDU
const SNDC_FORMATS      = 0x07;     // Server Audio Formats and Version PDU or Client Audio Formats and Version PDU
const SNDC_CRYPTKEY     = 0x08;     // Crypt Key PDU
const SNDC_WAVEENCRYPT  = 0x09;     // Wave Encrypt PDU
const SNDC_UDPWAVE      = 0x0A;     // UDP Wave PDU
const SNDC_UDPWAVELAST  = 0x0B;     // UDP Wave Last PDU
const SNDC_QUALITYMODE  = 0x0C;     // Quality Mode PDU
const SNDC_WAVE2        = 0x0D;     // Wave2 PDU

// c abi struct
pub const rdpsnd_priv_t = extern struct
{
    rdpsnd: c.struct_rdpsnd_t = .{},
    allocator: *const std.mem.Allocator,
    time_stamp: u16 = 0,
    format_no: u16 = 0,
    block_no: u8 = 0,
    data: [4]u8 = .{0, 0, 0, 0},

    //*************************************************************************
    pub fn delete(self: *rdpsnd_priv_t) void
    {
        self.allocator.destroy(self);
    }

    //*************************************************************************
    pub fn logln(self: *rdpsnd_priv_t, src: std.builtin.SourceLocation,
            comptime fmt: []const u8, args: anytype) !void
    {
        // check if function is assigned
        if (self.rdpsnd.log_msg) |alog_msg|
        {
            const alloc_buf = try std.fmt.allocPrint(self.allocator.*,
                    fmt, args);
            defer self.allocator.free(alloc_buf);
            const alloc1_buf = try std.fmt.allocPrintZ(self.allocator.*,
                    "rdpsnd:{s}:{s}", .{src.fn_name, alloc_buf});
            defer self.allocator.free(alloc1_buf);
            _ = alog_msg(&self.rdpsnd, alloc1_buf.ptr);
        }
    }

    //*************************************************************************
    pub fn logln_devel(self: *rdpsnd_priv_t, src: std.builtin.SourceLocation,
            comptime fmt: []const u8, args: anytype) !void
    {
        if (g_devel)
        {
            return self.logln(src, fmt, args);
        }
    }

    //*************************************************************************
    fn process_zero(self: *rdpsnd_priv_t, channel_id: u16,
            s: *parse.parse_t) !c_int
    {
        try self.logln(@src(), "", .{});
        try s.reset(0);
        try s.check_rem(4);
        s.out_u8_slice(&self.data);
        try s.reset(0);
        if (self.rdpsnd.wave) |awave|
        {
            const rem = s.get_rem();
            try s.check_rem(rem);
            const slice = s.in_u8_slice(rem);
            return awave(&self.rdpsnd, channel_id, self.time_stamp,
                    self.format_no, self.block_no,
                    slice.ptr, @truncate(slice.len));
        }
        return c.LIBRDPSND_ERROR_NONE;
    }

    //*************************************************************************
    fn process_close(self: *rdpsnd_priv_t, channel_id: u16) !c_int
    {
        try self.logln(@src(), "", .{});
        if (self.rdpsnd.close) |aclose|
        {
            return aclose(&self.rdpsnd, channel_id);
        }
        return c.LIBRDPSND_ERROR_NONE;
    }

    //*************************************************************************
    fn process_wave(self: *rdpsnd_priv_t, s: *parse.parse_t) !c_int
    {
        try self.logln(@src(), "", .{});
        try s.check_rem(12);
        self.time_stamp = s.in_u16_le();
        self.format_no = s.in_u16_le();
        self.block_no = s.in_u8();
        s.in_u8_skip(3); // bPad
        std.mem.copyForwards(u8, &self.data, s.in_u8_slice(4));
        return c.LIBRDPSND_ERROR_NONE;
    }

    //*************************************************************************
    fn process_setvolume(self: *rdpsnd_priv_t, channel_id: u16,
            s: *parse.parse_t) !c_int
    {
        try self.logln(@src(), "", .{});
        try s.check_rem(4);
        const volume = s.in_u32_le();
        if (self.rdpsnd.volume) |avolume|
        {
            return avolume(&self.rdpsnd, channel_id, volume);
        }
        return c.LIBRDPSND_ERROR_NONE;
    }

    //*************************************************************************
    fn process_setpitch(self: *rdpsnd_priv_t, channel_id: u16,
            s: *parse.parse_t) !c_int
    {
        try self.logln(@src(), "", .{});
        try s.check_rem(4);
        const pitch = s.in_u32_le();
        if (self.rdpsnd.pitch) |apitch|
        {
            return apitch(&self.rdpsnd, channel_id, pitch);
        }
        return c.LIBRDPSND_ERROR_NONE;
    }

    //*************************************************************************
    fn process_waveconfirm(self: *rdpsnd_priv_t, s: *parse.parse_t) !c_int
    {
        try self.logln(@src(), "", .{});
        _ = s;
        return c.LIBRDPSND_ERROR_NONE;
    }

    //*************************************************************************
    fn process_training(self: *rdpsnd_priv_t, s: *parse.parse_t) !c_int
    {
        try self.logln(@src(), "", .{});
        _ = s;
        return c.LIBRDPSND_ERROR_NONE;
    }

    //*************************************************************************
    fn process_formats(self: *rdpsnd_priv_t, channel_id: u16,
            s: *parse.parse_t) !c_int
    {
        try s.check_rem(20);
        s.in_u8_skip(14); // dwFlags, dwVolume, dwPitch, wDGramPort
        const num_formats = s.in_u16_le();
        const block_no = s.in_u8();
        const version = s.in_u16_le();
        s.in_u8_skip(1); // bPad
        var formats = std.ArrayList(c.format_t).init(self.allocator.*);
        defer formats.deinit();
        try self.logln(@src(), "num_formats {} block_no {}",
                .{num_formats, block_no});
        for (0..num_formats) |_|
        {
            var format: c.format_t = .{};
            try s.check_rem(18);
            format.wFormatTag = s.in_u16_le();
            format.nChannels = s.in_u16_le();
            format.nSamplesPerSec = s.in_u32_le();
            format.nAvgBytesPerSec = s.in_u32_le();
            format.nBlockAlign = s.in_u16_le();
            format.wBitsPerSample = s.in_u16_le();
            format.cbSize = s.in_u16_le();
            if (format.cbSize > 0)
            {
                try s.check_rem(format.cbSize);
                format.data = &s.data[s.offset];
                s.in_u8_skip(format.cbSize);
            }
            try formats.append(format);
        }
        if (self.rdpsnd.formats) |aformats|
        {
            return aformats(&self.rdpsnd, channel_id, version, block_no,
                    num_formats, formats.items.ptr);
        }
        return c.LIBRDPSND_ERROR_NONE;
    }

    //*************************************************************************
    fn process_cryptkey(self: *rdpsnd_priv_t, s: *parse.parse_t) !c_int
    {
        try self.logln(@src(), "", .{});
        _ = s;
        return c.LIBRDPSND_ERROR_NONE;
    }

    //*************************************************************************
    fn process_waveencrypt(self: *rdpsnd_priv_t, s: *parse.parse_t) !c_int
    {
        try self.logln(@src(), "", .{});
        _ = s;
        return c.LIBRDPSND_ERROR_NONE;
    }

    //*************************************************************************
    fn process_udpwave(self: *rdpsnd_priv_t, s: *parse.parse_t) !c_int
    {
        try self.logln(@src(), "", .{});
        _ = s;
        return c.LIBRDPSND_ERROR_NONE;
    }

    //*************************************************************************
    fn process_udpwavelast(self: *rdpsnd_priv_t, s: *parse.parse_t) !c_int
    {
        try self.logln(@src(), "", .{});
        _ = s;
        return c.LIBRDPSND_ERROR_NONE;
    }

    //*************************************************************************
    fn process_qualitymode(self: *rdpsnd_priv_t, s: *parse.parse_t) !c_int
    {
        try self.logln(@src(), "", .{});
        _ = s;
        return c.LIBRDPSND_ERROR_NONE;
    }

    //*************************************************************************
    fn process_wave2(self: *rdpsnd_priv_t, s: *parse.parse_t) !c_int
    {
        try self.logln(@src(), "", .{});
        _ = s;
        return c.LIBRDPSND_ERROR_NONE;
    }

    //*************************************************************************
    pub fn process_slice(self: *rdpsnd_priv_t, channel_id: u16,
            slice: []u8) !c_int
    {
        const s = try parse.create_from_slice(self.allocator, slice);
        defer s.delete();
        try s.check_rem(4);
        const msg_type = s.in_u8();
        s.in_u8_skip(1); // bPad
        const body_size = s.in_u16_le();
        try s.check_rem(body_size);
        try self.logln(@src(),
                "channel_id 0x{X} msg_type {} body_size {}",
                .{channel_id, msg_type, body_size});
        return switch (msg_type)
        {
            0 => self.process_zero(channel_id, s),
            SNDC_CLOSE => self.process_close(channel_id),
            SNDC_WAVE => self.process_wave(s),
            SNDC_SETVOLUME => self.process_setvolume(channel_id, s),
            SNDC_SETPITCH => self.process_setpitch(channel_id, s),
            SNDC_WAVECONFIRM => self.process_waveconfirm(s),
            SNDC_TRAINING => self.process_training(s),
            SNDC_FORMATS => self.process_formats(channel_id, s),
            SNDC_CRYPTKEY => self.process_cryptkey(s),
            SNDC_WAVEENCRYPT => self.process_waveencrypt(s),
            SNDC_UDPWAVE => self.process_udpwave(s),
            SNDC_UDPWAVELAST => self.process_udpwavelast(s),
            SNDC_QUALITYMODE => self.process_qualitymode(s),
            SNDC_WAVE2 => self.process_wave2(s),
            else => c.LIBRDPSND_ERROR_NONE,
        };
    }

    //*************************************************************************
    pub fn send_confirm(self: *rdpsnd_priv_t, channel_id: u16,
            timestamp: u16, block_no: u8) !c_int
    {
        try self.logln(@src(),
                "channel_id 0x{X} timestamp {} block_no 0x{X}",
                .{channel_id, timestamp, block_no});
        const s = try parse.create(self.allocator, 64);
        defer s.delete();
        try s.check_rem(8);
        s.out_u8(SNDC_WAVECONFIRM); // msgType
        s.out_u8_skip(1);           // bPad
        s.out_u16_le(4);            // BodySize
        s.out_u16_le(timestamp);
        s.out_u8(block_no);
        s.out_u8_skip(1);
        const slice = s.get_out_slice();
        if (self.rdpsnd.send_data) |asend_data|
        {
            return asend_data(&self.rdpsnd, channel_id,
                    slice.ptr, @truncate(slice.len));
        }
        return c.LIBRDPSND_ERROR_NONE;
    }

};

//*****************************************************************************
pub fn create(allocator: *const std.mem.Allocator) !*rdpsnd_priv_t
{
    const priv: *rdpsnd_priv_t = try allocator.create(rdpsnd_priv_t);
    errdefer allocator.destroy(priv);
    priv.* = .{.allocator = allocator};
    return priv;
}
