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

        var header: [0x24]u8 = undefined;
        _ = try reader.read(&header);
        if (!std.mem.eql(u8, header[0..0x21], "SNES-SPC700 Sound File Data v0.30") or header[0x21] != 0x1a or header[0x22] != 0x1a) {
            return LoadError.NotAnSpcFile;
        }

        return Smp{ .ram = undefined };
    }
};

pub fn main() !void {
    const veryCool = "spc/ChronoTrigger/304 Corridors of Time.spc";
    const smp = try Smp.load(veryCool);

    _ = smp;
}
