#pragma once

#include "sdl.hpp"

#include "font.hpp"
#include "gui.hpp"
#include "lua_gui.hpp"
#include "sushi_renderer.hpp"
#include "shaders.hpp"
#include "utility.hpp"
#include "resource_cache.hpp"
#include "json_lua.hpp"

#include <sushi/sushi.hpp>

#include <sol.hpp>

#include <sol.hpp>

#include <iostream>
#include <stdexcept>
#include <string>
#include <cstddef>
#include <cmath>
#include <functional>
#include <memory>
#include <random>

class version_selector {
public:
    version_selector(SDL_Window* g_window, SDL_GLContext glcontext, std::function<void()> init_jam_version, std::function<void()> init_new_version);

    auto handle_game_input(const SDL_Event& event) -> bool;

    auto handle_gui_input(SDL_Event& e) -> bool;

    void tick();

private:
    using clock = std::chrono::steady_clock;

    sol::state lua;
    nlohmann::json config;
    int display_width;
    int display_height;
    float aspect_ratio;
    SDL_Window* g_window;
    SDL_GLContext glcontext;
    basic_shader_program program_basic;
    msdf_shader_program program_msdf;
    resource_cache<sushi::texture_2d, std::string> texture_cache;
    resource_cache<msdf_font, std::string> font_cache;
    sushi_renderer renderer;
    std::shared_ptr<gui::widget> root_widget;
    std::weak_ptr<gui::widget> focused_widget;
    clock::time_point prev_time;
    sol::table gui_state;
    sol::protected_function update_gui_state;
    clock::duration next_tick;
    clock::duration next_renderer_gc;
};