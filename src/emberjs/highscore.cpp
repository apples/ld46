#include "websocket.hpp"

#ifndef __EMSCRIPTEN__
namespace emberjs {
namespace {
    double highscore;
}
extern "C" {
    double ember_get_highscore() { return highscore; }
    void ember_set_highscore(double newscore) { highscore = newscore; }
}
}
#endif
