const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Could not initialize SDL: %s\n", c.SDL_GetError());
        return error.SDLInitFailed;
    }
    defer c.SDL_Quit();

    const window = c.SDL_CreateWindow("Test", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, 800, 600, 0) orelse {
        c.SDL_Log("Could not create window: %s\n", c.SDL_GetError());
        return error.SDLInitFailed;
    };
    defer c.SDL_DestroyWindow(window);

    const renderer = c.SDL_CreateRenderer(window, -1, 0) orelse {
        c.SDL_Log("Could not create renderer: %s\n", c.SDL_GetError());
        return error.SDLInitFailed;
    };
    defer c.SDL_DestroyRenderer(renderer);

    var pos_x: i32 = 10;
    var pos_y: i32 = 10;

    var is_running: bool = true;
    var event: c.SDL_Event = undefined;
    while (is_running) {
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => { is_running = false; },
                c.SDL_KEYDOWN => {
                    switch (event.key.keysym.sym) {
                        c.SDLK_w => { pos_y -= 5; },
                        c.SDLK_s => { pos_y += 5; },
                        c.SDLK_a => { pos_x -= 5; },
                        c.SDLK_d => { pos_x += 5; },
                        else => { },
                    }
                },
                else => { },
            }
        }

        _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        _ = c.SDL_RenderClear(renderer);
        _ = c.SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);
        _ = c.SDL_RenderFillRect(renderer, &c.SDL_Rect{.x=pos_x, .y=pos_y, .w=100, .h=100});

        c.SDL_RenderPresent(renderer);
    }
}
