const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

const Player = struct {
    x: i32,
    y: i32,
};

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Could not initialize SDL: %s\n", c.SDL_GetError());
        return error.SDLInitFailed;
    }
    defer c.SDL_Quit();

    const window = c.SDL_CreateWindow("Test", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, 800, 600, 0) orelse {
        c.SDL_Log("Could not create window: %s\n", c.SDL_GetError());
        return error.SDLWindowFailed;
    };
    defer c.SDL_DestroyWindow(window);

    const renderer = c.SDL_CreateRenderer(window, -1, 0) orelse {
        c.SDL_Log("Could not create renderer: %s\n", c.SDL_GetError());
        return error.SDLRendererFailed;
    };
    defer c.SDL_DestroyRenderer(renderer);

    var player: Player = .{ .x = 10, .y = 10, };

    var is_running: bool = true;
    var event: c.SDL_Event = undefined;
    while (is_running) {
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => { is_running = false; },
                c.SDL_KEYDOWN => {
                    switch (event.key.keysym.sym) {
                        c.SDLK_w => { player.y -= 5; },
                        c.SDLK_s => { player.y += 5; },
                        c.SDLK_a => { player.x -= 5; },
                        c.SDLK_d => { player.x += 5; },
                        c.SDLK_ESCAPE => { is_running = false; },
                        else => { },
                    }
                },
                else => { },
            }
        }

        _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        _ = c.SDL_RenderClear(renderer);
        _ = c.SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);
        _ = c.SDL_RenderFillRect(renderer, &c.SDL_Rect{.x=player.x, .y=player.y, .w=100, .h=100});

        c.SDL_RenderPresent(renderer);
    }
}
