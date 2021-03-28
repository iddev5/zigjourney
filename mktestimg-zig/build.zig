const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});

    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("mktestimg", "mktestimg.zig");
    exe.addCSourceFile("stb_image_write_impl.c", &[_][]const u8{"-std=c99"});
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.addIncludeDir(".");
    exe.linkSystemLibrary("c");
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run");
    run_step.dependOn(&run_cmd.step);
}
