#include "pathfind.hpp"

#include <cmath>
#include <queue>
#include <optional>
#include <iostream>

enum class tile_type {
    VOID = 0,
    SW = 1,
    SE = 2,
    NW = 3,
    NE = 4,
    CROSS = 5,
    CAP = 6,
};

struct board_tile {
    tile_type type = tile_type::VOID;
    bool visited = false;
    std::optional<glm::ivec2> next;
};

struct path_step {
    glm::ivec2 xy;
    int cost = 0;
    int value = 0;
    std::optional<glm::ivec2> next;
};

bool operator<(const path_step& a, const path_step& b) {
    return a.value > b.value;
}

#if false
    #define LOG std::clog
#else
    struct fake_logger {
    };
    template <typename T>
    fake_logger& operator<<(fake_logger& f, T&&) { return f; }
    static fake_logger flog;
    #define LOG flog
#endif

std::vector<glm::vec2> pathfind(sol::table lua_board, sol::table lua_source, sol::table lua_dest, bool pass_caps) try {
    LOG << "Pathfinding..." << "\n";
    auto xmin = 1;
    auto xmax = 1;
    auto ymin = 1;
    auto ymax = 1;

    for (const auto& [xk,xv] : lua_board) {
        const auto row = xv.as<sol::table>();
        for (const auto& [yk,cell] : row) {
            const auto x = xk.as<int>();
            const auto y = yk.as<int>();

            xmin = std::min(xmin, x);
            xmax = std::max(xmax, x);
            ymin = std::min(ymin, y);
            ymax = std::max(ymax, y);
        }
    }

    const auto width = xmax - xmin + 1;
    const auto height = ymax - ymin + 1;

    LOG << "width = " << width << "\n";
    LOG << "height = " << height << "\n";

    auto board = std::vector<board_tile>(width * height);

    auto get_tile = [&](glm::ivec2 xy) -> board_tile* {
        if (xy.x < xmin || xy.x > xmax || xy.y < ymin || xy.y > ymax) {
            return nullptr;
        }

        const auto i = (xy.x - xmin) * height;
        const auto j = xy.y - ymin;

        return &board[i + j];
    };

    auto get_tile_type = [&](glm::ivec2 xy) -> tile_type {
        if (auto tile = get_tile(xy)) {
            return tile->type;
        } else {
            return tile_type::VOID;
        }
    };

    for (const auto& [xk,xv] : lua_board) {
        const auto row = xv.as<sol::table>();
        for (const auto& [yk,cell] : row) {
            const auto x = xk.as<int>();
            const auto y = yk.as<int>();

            get_tile({x, y})->type = cell.as<sol::table>()["type"];
        }
    }

    const auto source = glm::ivec2{lua_source["x"], lua_source["y"]};
    const auto dest = glm::ivec2{lua_dest["x"], lua_dest["y"]};

    const auto get_H = [&](glm::ivec2 where) {
        return std::abs(source.x - where.x) + std::abs(source.y - where.y);
    };

    auto q = std::priority_queue<path_step>();

    q.push({ dest, 1, get_H(dest) + 1, std::nullopt });

    const auto mark_visited = [&](const path_step& cur) {
        LOG << "Visiting " << cur.xy.x << "," << cur.xy.y << " (cost = " << cur.cost << ", value = " << cur.value << ")" << "\n";
        auto& tile = *get_tile(cur.xy);
        tile.visited = true;
        tile.next = cur.next;
    };

    const auto push = [&](const path_step& next, glm::ivec2 xy) {
        if (auto tile = get_tile(xy)) {
            if (!tile->visited) {
                const auto cost = next.cost + 1;
                const auto value = cost + get_H(xy);
                LOG << "  Pushing " << xy.x << "," << xy.y << " " << cost << " " << value << "\n";
                q.push({ xy, cost, value, next.xy });
            }
        }
    };

    const auto omnidir = [&](tile_type t) {
        return t == tile_type::CROSS || pass_caps && t == tile_type::CAP;
    };

    while (!q.empty()) {
        const auto next = q.top();
        q.pop();

        mark_visited(next);

        if (next.xy == source) {
            LOG << "  Found end (cost = " << next.cost << ")" << "\n";
            auto result = std::vector<glm::vec2>();
            result.reserve(next.cost);
            auto cur = std::optional<glm::ivec2>(next.xy);
            while (cur) {
                LOG << "    " << cur->x << "," << cur->y << "\n";
                result.push_back({cur->x, cur->y});
                cur = get_tile(*cur)->next;
            }
            LOG << "  Checking (cost = " << next.cost << ", size = " << result.size() << ")" << "\n";
            if (result.size() != next.cost) {
                throw std::runtime_error("Bad path length!");
            }
            return result;
        }

        const auto type = get_tile_type(next.xy);

        const auto N = get_tile_type({next.xy.x, next.xy.y + 1});
        const auto S = get_tile_type({next.xy.x, next.xy.y - 1});
        const auto E = get_tile_type({next.xy.x + 1, next.xy.y});
        const auto W = get_tile_type({next.xy.x - 1, next.xy.y});

        switch (type) {
        case tile_type::SW: {
            if (S == tile_type::NE || S == tile_type::NW || omnidir(S)) {
                push(next, {next.xy.x, next.xy.y - 1});
            }
            if (W == tile_type::SE || W == tile_type::NE || omnidir(W)) {
                push(next, {next.xy.x - 1, next.xy.y});
            }
            break;
        }
        case tile_type::SE: {
            if (S == tile_type::NE || S == tile_type::NW || omnidir(S)) {
                push(next, {next.xy.x, next.xy.y - 1});
            }
            if (E == tile_type::SW || E == tile_type::NW || omnidir(E)) {
                push(next, {next.xy.x + 1, next.xy.y});
            }
            break;
        }
        case tile_type::NW: {
            if (N == tile_type::SE || N == tile_type::SW || omnidir(N)) {
                push(next, {next.xy.x, next.xy.y + 1});
            }
            if (W == tile_type::SE || W == tile_type::NE || omnidir(W)) {
                push(next, {next.xy.x - 1, next.xy.y});
            }
            break;
        }
        case tile_type::NE: {
            if (N == tile_type::SE || N == tile_type::SW || omnidir(N)) {
                push(next, {next.xy.x, next.xy.y + 1});
            }
            if (E == tile_type::SW || E == tile_type::NW || omnidir(E)) {
                push(next, {next.xy.x + 1, next.xy.y});
            }
            break;
        }
        case tile_type::CROSS:
        case tile_type::CAP: {
            if (N == tile_type::SE || N == tile_type::SW || omnidir(N)) {
                push(next, {next.xy.x, next.xy.y + 1});
            }
            if (S == tile_type::NE || S == tile_type::NW || omnidir(S)) {
                push(next, {next.xy.x, next.xy.y - 1});
            }
            if (E == tile_type::SW || E == tile_type::NW || omnidir(E)) {
                push(next, {next.xy.x + 1, next.xy.y});
            }
            if (W == tile_type::SE || W == tile_type::NE || omnidir(W)) {
                push(next, {next.xy.x - 1, next.xy.y});
            }
        }
        }
    }

    return {};
} catch (const std::exception& e) {
    std::cerr << "pathfind(): " << e.what() << "\n";
    throw;
}
