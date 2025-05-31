const std = @import("std");

const Smp = struct {
    const ramSize = 0x10000;

    accumulator: u8,
    xRegister: u8,
    yRegister: u8,
    status: u8,
    stackPointer: u8,
    programCounter: u16,
    yaRegister: u16,

    ram: [ramSize]u8,
};

pub fn main() !void {
    std.log.info("hi", .{});
}
