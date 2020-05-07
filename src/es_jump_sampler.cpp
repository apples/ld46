#include "es_jump_sampler.hpp"

void es_jump_sampler::register_type(sol::table& table) { //static
    table.new_usertype<es_jump_sampler>("es_jump_sampler", sol::constructors<es_jump_sampler(int)>{},
        "add", &es_jump_sampler::add,
        "get_results", &es_jump_sampler::get_results);
}
