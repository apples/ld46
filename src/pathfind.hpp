#pragma once

#include <sol.hpp>
#include <glm/glm.hpp>

std::vector<glm::vec2> pathfind(sol::table lua_board, sol::table lua_source, sol::table lua_dest);
