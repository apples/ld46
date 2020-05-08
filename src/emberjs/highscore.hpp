#pragma once

#include <functional>
#include <string>
#include <utility>

namespace emberjs {
    extern "C" {
        extern double ember_get_highscore();
        extern void ember_set_highscore(double newscore);
    }
} //namespace emberjs
