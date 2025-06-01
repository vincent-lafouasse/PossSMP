const std = @import("std");

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

        var header: [0x23]u8 = undefined;
        _ = try reader.read(&header);
        if (!std.mem.eql(u8, header[0..0x23], "SNES-SPC700 Sound File Data v0.30" ++ .{ 0x1a, 0x1a })) {
            return LoadError.NotAnSpcFile;
        }

        const byte23 = try reader.readByte();
        if (byte23 == 26) {
            std.log.info("-- ID666 info inbound", .{});
        } else if (byte23 == 27) {
            std.log.info("-- No ID666 info inbound", .{});
        } else {
            return LoadError.NotAnSpcFile;
        }

        const byte25 = try reader.readByte();
        if (byte25 != 30) {
            return LoadError.NotAnSpcFile;
        }

        const pcl: u16 = try reader.readByte();
        const pch: u16 = try reader.readByte();
        const pc = pcl + 256 * pch;
        const a = try reader.readByte();
        const x = try reader.readByte();
        const y = try reader.readByte();
        const status = try reader.readByte();
        const sp: u16 = try reader.readByte();

        std.log.info("Registers:", .{});
        std.log.info("pc = {x:04}", .{pc});
        std.log.info("a = {x:02}", .{a});
        std.log.info("x = {x:02}", .{x});
        std.log.info("y = {x:02}", .{y});
        std.log.info("p = {b:08}", .{status});
        std.log.info("sp = {x:02}", .{sp});

        {
            var unused: [2]u8 = undefined;
            _ = try reader.read(&unused);
        }

        return Smp{ .ram = undefined };
    }
};

pub fn main() !void {
    const veryCool = "spc/ChronoTrigger/304 Corridors of Time.spc";
    const smp = try Smp.load(veryCool);

    _ = smp;
}
