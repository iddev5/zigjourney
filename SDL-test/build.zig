const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const exe = b.addExecutable("test", "src/main.zig");
    exe.setBuildMode(b.standardReleaseOptions());
    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("SDL2");
    exe.install();

    const run = exe.run();
    run.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run.step);
}
