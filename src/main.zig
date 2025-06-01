const std = @import("std");

fn readNumber(comptime T: type, data: []const u8) T {
    var out: T = 0;
    var multiplicator: T = 1;

    for (data) |byte| {
        out += @as(T, byte) * multiplicator;
        multiplicator <<= 8;
    }

    return out;
}

const Smp = struct {
    const ramSize = 0x10000;

    accumulator: u8 = 0,
    xRegister: u8 = 0,
    yRegister: u8 = 0,
    status: u8 = 0,
    stackPointer: u8 = 0,
    programCounter: u16 = 0,
    yaRegister: u16 = 0,

    ram: [ramSize]u8,

    const LoadError = error{
        CouldntOpenFile,
        NotAnSpcFile,
    };

    pub fn load(path: []const u8) !Smp {
        const file = std.fs.cwd().openFile(path, .{}) catch {
            return LoadError.CouldntOpenFile;
        };
        defer file.close();
        const reader = file.reader();

        var header: [0x100]u8 = undefined;
        _ = try reader.read(&header);
        if (!std.mem.eql(u8, header[0..0x23], "SNES-SPC700 Sound File Data v0.30" ++ .{ 0x1a, 0x1a })) {
            return LoadError.NotAnSpcFile;
        }

        switch (header[0x23]) {
            26 => std.log.info("-- ID666 info inbound", .{}),
            27 => std.log.info("-- No ID666 info inbound", .{}),
            else => return LoadError.NotAnSpcFile,
        }

        if (header[0x24] != 30) {
            return LoadError.NotAnSpcFile;
        }

        const pc = readNumber(u16, header[0x25..0x27]);
        const a = header[0x27];
        const x = header[0x28];
        const y = header[0x29];
        const status = header[0x2a];
        const sp: u16 = header[0x2b];

        std.log.info("Registers:", .{});
        std.log.info("pc = {x:04}", .{pc});
        std.log.info("a = {x:02}", .{a});
        std.log.info("x = {x:02}", .{x});
        std.log.info("y = {x:02}", .{y});
        std.log.info("p = {b:08}", .{status});
        std.log.info("sp = {x:02}", .{sp});
        std.log.info("", .{});

        const songTitle = header[0x2e..0x4e];
        const gameTitle = header[0x4e..0x6e];
        const dumperName = header[0x6e..0x7e];
        const comment = header[0x7e..0x9e];
        const dumpDate = header[0x9e..0xa9];

        const secsBeforeFadeOut = readNumber(u32, header[0xa9..0xac]);
        const msFadeOut = readNumber(u64, header[0xac..0xb1]);

        std.log.info("song name: {s}", .{songTitle});
        std.log.info("game title: {s}", .{gameTitle});
        std.log.info("", .{});
        std.log.info("secs before fadeout: {}", .{secsBeforeFadeOut});
        std.log.info("ms of fadein: {}", .{msFadeOut});
        std.log.info("", .{});
        std.log.info("dumped by: {s} ({s})", .{ dumperName, dumpDate });
        std.log.info("comments: {s}", .{comment});

        return Smp{ .ram = undefined };
    }
};

pub fn main() !void {
    const veryCool = "spc/ChronoTrigger/304 Corridors of Time.spc";
    const smp = try Smp.load(veryCool);

    _ = smp;
}
