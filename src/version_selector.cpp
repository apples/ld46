#include "version_selector.hpp"

#include "emberjs/config.hpp"

#define TRACE(N)

using namespace std::literals;

version_selector::version_selector(
    SDL_Window* g_window,
    SDL_GLContext glcontext,
    std::function<void()> init_jam_version,
    std::function<void()> init_new_version)
    : g_window(g_window), glcontext(glcontext) {

    config = emberjs::get_config();

    lua.open_libraries(
        sol::lib::base,
        sol::lib::math,
        sol::lib::string,
        sol::lib::table,
        sol::lib::debug,
        sol::lib::package);

    lua["package"]["path"] = "data/scripts/?.lua;data/scripts/?/init.lua";
    lua["package"]["cpath"] = "";

    lua_gui::register_types(lua.globals());

    display_width = config["display"]["width"];
    display_height = config["display"]["height"];
    aspect_ratio = float(display_width) / float(display_height);

    glEnable(GL_DEPTH_TEST);

    program_basic = basic_shader_program("data/shaders/basic.vert", "data/shaders/basic.frag");
    program_msdf = msdf_shader_program("data/shaders/msdf.vert", "data/shaders/msdf.frag");

    program_basic.bind();
    program_basic.set_s_texture(0);
    glBindAttribLocation(program_basic.get_program().get(), sushi::attrib_location::POSITION, "position");
    glBindAttribLocation(program_basic.get_program().get(), sushi::attrib_location::TEXCOORD, "texcoord");
    glBindAttribLocation(program_basic.get_program().get(), sushi::attrib_location::NORMAL, "normal");

    program_msdf.bind();
    glBindAttribLocation(program_msdf.get_program().get(), sushi::attrib_location::POSITION, "position");
    glBindAttribLocation(program_msdf.get_program().get(), sushi::attrib_location::TEXCOORD, "texcoord");
    glBindAttribLocation(program_msdf.get_program().get(), sushi::attrib_location::NORMAL, "normal");
    glBindAttribLocation(program_msdf.get_program().get(), 3, "texSize");

    texture_cache = [](const std::string& name) {
        if (name == ":white") {
            unsigned char white[4] = { 0xff, 0xff, 0xff, 0xff };
            auto tex = sushi::create_uninitialized_texture_2d(1, 1, sushi::TexType::COLORA);
            glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, white);
            return tex;
        } else {
            return sushi::load_texture_2d("data/textures/" + name + ".png", false, false, false, false);
        }
    };

    font_cache = [](const std::string& fontname) {
        return msdf_font("data/fonts/"+fontname+".ttf");
    };

    renderer = sushi_renderer(
        {display_width, display_height},
        program_basic,
        program_msdf,
        font_cache,
        texture_cache);

    root_widget = std::make_shared<gui::widget>(renderer);
    root_widget->set_attribute("width", std::to_string(display_width));
    root_widget->set_attribute("height", std::to_string(display_height));

    lua["root_widget"] = root_widget;
    lua["focus_widget"] = [this](gui::widget* widget) {
        focused_widget = widget->weak_from_this();
    };

    std::cout << "initting version_selector state" << std::endl;

    auto init_result = lua.do_file("data/scripts/version_selector.lua");
    if (!init_result.valid()) {
        sol::error err = init_result;
        std::cerr << err.what() << std::endl;
        throw std::runtime_error("Init error: "s + err.what());
    }

    prev_time = clock::now();

    gui_state = lua.create_table();
    gui_state["load_jam_version"] = init_jam_version;
    gui_state["load_new_version"] = init_new_version;
    update_gui_state = lua["update_gui_state"];

    next_tick = std::chrono::duration_cast<clock::duration>(std::chrono::duration<std::int64_t, std::ratio<1, 30>>(1));
    next_renderer_gc = clock::duration{0};
}

auto version_selector::handle_game_input(const SDL_Event& event) -> bool {
    switch (event.type) {
        case SDL_QUIT:
            std::cout << "Goodbye!" << std::endl;
            return true;
    }

    return false;
}

auto version_selector::handle_gui_input(SDL_Event& e) -> bool {
    switch (e.type) {
        case SDL_TEXTINPUT: {
            if (auto widget = focused_widget.lock()) {
                if (widget->on_textinput) {
                    widget->on_textinput(widget, e.text.text);
                    return true;
                }
            }
            break;
        }
        case SDL_KEYDOWN: {
            if (auto widget = focused_widget.lock()) {
                if (widget->on_keydown) {
                    return widget->on_keydown(widget, SDL_GetKeyName(e.key.keysym.sym));
                }
            }
        }
        case SDL_MOUSEBUTTONDOWN: {
            switch (e.button.button) {
                case SDL_BUTTON_LEFT: {
                    auto abs_click_pos = glm::vec2{e.button.x, display_height - e.button.y + 1};
                    auto widget_stack = get_descendent_stack(*root_widget, abs_click_pos);
                    while (!widget_stack.empty()) {
                        auto cur_widget = widget_stack.back();
                        auto widget_pos = cur_widget->get_layout().position;
                        auto rel_click_pos = abs_click_pos - widget_pos;
                        if (cur_widget->on_click) {
                            cur_widget->on_click(cur_widget->shared_from_this(), rel_click_pos);
                            return true;
                        } else if (cur_widget->pointer_opaque()) {
                            return true;
                        } else {
                            widget_stack.pop_back();
                        }
                    }
                    break;
                }
            }
            break;
        }
    }
    return false;
}

void version_selector::tick() {

    auto now = clock::now();
    auto delta_time = now - prev_time;
    prev_time = now;

    SDL_Event event;
    while (SDL_PollEvent(&event))
    {
        if (handle_gui_input(event)) break;
    }

    TRACE("GUI UPDATE") {
        auto result = update_gui_state(gui_state);
        if (!result.valid()) {
            sol::error err = result;
            std::cerr << err.what() << std::endl;
            throw std::runtime_error("Gui update error: "s + err.what());
        }
    }

    TRACE("GUI LAYOUT") {
        gui::calculate_all_layouts(*root_widget);
    }

    TRACE("GUI RENDER") {
        renderer.begin();
        gui::draw_all(*root_widget);
        renderer.end();
    }

    TRACE("GUI GC") {
        next_renderer_gc -= delta_time;
        if (next_renderer_gc <= clock::duration{0}) {
            renderer.collect_garbage();
            next_renderer_gc = std::chrono::seconds{1};
        }
    }

    TRACE("LUA GC") {
        lua.collect_garbage();
    }

    SDL_GL_SwapWindow(g_window);
}
