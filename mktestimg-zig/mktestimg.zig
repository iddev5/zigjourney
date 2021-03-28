usingnamespace @cImport({
    @cInclude("stb_image_write.h");
});

pub fn main() void {
    const width = 10;
    const height = 10;
    const channels = 4;

    var i: u32 = 0;
    var data: [width * height * channels]u8 = undefined;
    
    while (i < width * height): (i += 1) {
        data[i * channels + 0] = 0;
        data[i * channels + 1] = 255;
        data[i * channels + 2] = 0;
        data[i * channels + 3] = 255;
    }

    _ = stbi_write_png("zigtest.png", width, height, channels, &data, width * channels);
}
