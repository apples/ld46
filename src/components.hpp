#pragma once

#include "entities.hpp"
#include "json_serializers.hpp"

#include <Meta.h>
#include <glm/glm.hpp>
#include <sushi/texture.hpp>
#include <sushi/mesh.hpp>
#include <sol_forward.hpp>

#include <functional>
#include <string>
#include <type_traits>
#include <vector>

#define REGISTER(NAME, ...)                                       \
    }                                                             \
    namespace meta {                                              \
    template <> constexpr auto registerName<component::NAME>() {  \
        return #NAME;                                             \
    }                                                             \
    template <> inline auto registerMembers<component::NAME>() {  \
        using comtype = component::NAME;                          \
        return members(__VA_ARGS__);                              \
    }                                                             \
    }                                                             \
    namespace component {
#define MEMBER(FIELD) member(#FIELD, &comtype::FIELD)

#define TAG(name) using name = ginseng::tag<struct name##_t>; REGISTER(name)

namespace component {

using json_serializers::basic::from_json;
using json_serializers::basic::to_json;

void register_all_components(sol::table& table);

TAG(tag_heart);
TAG(tag_block);
TAG(tag_cell);
TAG(tag_cell_white);
TAG(tag_virus);
TAG(tag_virus_a);
TAG(tag_virus_b);
TAG(tag_virus_c);

struct net_id {
    ember_database::net_id id;
};

REGISTER(net_id,
         MEMBER(id))

struct position {
    glm::vec2 pos = {0, 0};
    float z = 0;
};

REGISTER(position,
         MEMBER(pos),
         MEMBER(z))

struct velocity {
    glm::vec2 vel = {0, 0};
};

REGISTER(velocity,
         MEMBER(vel))

struct script {
    std::string name;
    int next_tick = 0;
    sol::table state;
};

REGISTER(script,
         MEMBER(name),
         MEMBER(next_tick),
         MEMBER(state))

struct sprite {
    struct rowcol {
        int r;
        int c;

        rowcol() = default;
        rowcol(int r, int c): r(r), c(c) {}
    };

    std::vector<rowcol> frames;
    int cur_frame = 0;
    float speed = 0;
    float timer = 0;
    int dir = 1;
    bool loop = false;
    bool bounce = false;
    bool flip = false;
};

REGISTER(sprite,
         MEMBER(frames),
         MEMBER(cur_frame),
         MEMBER(speed),
         MEMBER(timer),
         MEMBER(dir),
         MEMBER(loop),
         MEMBER(bounce),
         MEMBER(flip))

struct controller {
    sol::table data;
};

REGISTER(controller,
         MEMBER(data))

struct body {
    float width = 1;
    float height = 1;

    float gravity = 0;

    bool dynamic = true;
    bool solid = true;

    bool edge_left = true;
    bool edge_right = true;
    bool edge_bottom = true;
    bool edge_top = true;
};

REGISTER(body,
         MEMBER(width),
         MEMBER(height),
         MEMBER(gravity),
         MEMBER(dynamic),
         MEMBER(solid),
         MEMBER(edge_left),
         MEMBER(edge_right),
         MEMBER(edge_bottom),
         MEMBER(edge_top))

struct food {
    int amount = 1;
};

REGISTER(food,
         MEMBER(amount))

struct death_notifier {
    std::vector<ember_database::ent_id> ents;
};

REGISTER(death_notifier,
         MEMBER(ents))

} //namespace component

#undef TAG
#undef MEMBER
#undef REGISTER
