
#include "engine.hpp"
#include "version_selector.hpp"
#include "sdl.hpp"

#include "emberjs/config.hpp"

#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#include <emscripten/html5.h>
#else
#include <boost/asio.hpp>
#endif

extern "C" void EMSCRIPTEN_KEEPALIVE what_to_stderr(intptr_t pointer) {
    auto error = reinterpret_cast<const std::exception *>(pointer);
    std::cerr << error->what() << std::endl;
}

std::function<void()> loop;
void main_loop() try {
    loop();
} catch (const std::exception& e) {
    std::cerr << "Fatal exception: " << e.what() << std::endl;
    std::terminate();
}

int main(int argc, char* argv[]) try {
    std::cout << "Init..." << std::endl;

    if (SDL_Init(SDL_INIT_VIDEO) != 0) {
        throw std::runtime_error(SDL_GetError());
    }

    auto config = emberjs::get_config();

    auto display_width = config["display"]["width"].get<int>();
    auto display_height = config["display"]["height"].get<int>();

    auto g_window = SDL_CreateWindow(
        "LD46",
        SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED,
        display_width,
        display_height,
        SDL_WINDOW_OPENGL|SDL_WINDOW_RESIZABLE);

    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
    SDL_GL_SetAttribute(SDL_GL_STENCIL_SIZE, 8);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);
    auto glcontext = SDL_GL_CreateContext(g_window);

    SDL_StartTextInput();

    std::cout << "Success." << std::endl;

    #ifdef __EMSCRIPTEN__
    auto init_jam_version = [g_window, glcontext]{};

    auto init_new_version = [g_window, glcontext]{
        auto fix_loop = [g_window, glcontext, old_loop = std::move(loop)]() mutable {
            old_loop = {};
            auto e = std::make_shared<engine>(g_window, glcontext);
            loop = [e = std::move(e)]{ e->tick(); };
        };
        loop = fix_loop;
    };

    auto e = std::make_shared<version_selector>(g_window, glcontext, init_jam_version, init_new_version);

    loop = [e = std::move(e)]{ e->tick(); };

    emscripten_set_main_loop(main_loop, 0, 1);
    #else
    auto io_service = boost::asio::io_service{};
    auto timer = boost::asio::deadline_timer{io_service};
    auto tickrate = boost::posix_time::microseconds{16667};

    auto timer_tick = [&](const boost::system::error_code &ec) {
        if (ec == boost::asio::error::operation_aborted) {
            std::clog << "Main loop aborted." << std::endl;
            return;
        }
        loop();
    };

    timer.expires_at(timer.expires_at() + tickrate);
    timer.async_wait(timer_tick);

    auto init_jam_version = [g_window, glcontext]{};

    auto init_new_version = [g_window, glcontext]{
        loop = {};
        auto e = std::make_shared<engine>();
        loop = [e = std::move(e)] {
            e->tick();
            timer.expires_at(timer.expires_at() + tickrate);
            timer.async_wait(timer_tick);
        };
    };

    auto e = std::make_shared<version_selector>(std::move(init_jam_version), std::move(init_new_version));

    loop = [e = std::move(e)] {
        e->tick();
        timer.expires_at(timer.expires_at() + tickrate);
        timer.async_wait(timer_tick);
    };

    io_service.run();
    #endif

    SDL_Quit();

    return EXIT_SUCCESS;
} catch (const std::exception& e) {
    std::cerr << "Fatal exception: " << e.what() << std::endl;
    return EXIT_FAILURE;
}
