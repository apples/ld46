#pragma once

#include <sol.hpp>

#include <cmath>
#include <queue>
#include <random>
#include <vector>

/// implements Algorithm A-ExpJ from Efraimidis-Spirakis
class es_jump_sampler {
public:
    static void register_type(sol::table& table);

    es_jump_sampler(int result_size)
        : result_size(result_size),
          rng(),
          reservoir() {
              auto seed = std::array<int, 624>{};
              std::generate(begin(seed), end(seed), []{ return std::rand(); });
              auto seq = std::seed_seq(begin(seed), end(seed));
              rng.seed(seq);
          }

    void add(sol::object item, float weight) {
        auto random_dist = std::uniform_real_distribution{0.0f, 1.0f};

        if (reservoir.size() < result_size) {
            auto score = std::pow(random_dist(rng), 1.0f / float(weight));

            reservoir.push({ item, score });

            if (reservoir.size() == result_size) {
                skip_weight = std::log(random_dist(rng))/std::log(reservoir.top().score);
            }
        } else {
            skip_weight -= weight;

            if (skip_weight <= 0) {
                auto t = std::pow(reservoir.top().score, weight);
                auto adjusted_dist = std::uniform_real_distribution{t, 1.0f};
                auto adjusted_score = std::pow(adjusted_dist(rng), 1.0f / weight);

                reservoir.pop();
                reservoir.push({ item, adjusted_score });

                skip_weight = std::log(random_dist(rng)) / std::log(reservoir.top().score);
            }
        }
    }

    auto get_results() -> std::vector<sol::object> {
        auto results = std::vector<sol::object>{};
        results.reserve(reservoir.size());

        while (!reservoir.empty()) {
            results.push_back(reservoir.top().item);
            reservoir.pop();
        }

        return results;
    }

private:
    struct scored_item {
        sol::object item;
        float score;

        bool operator<(scored_item const& other) const {
            return score > other.score;
        }
    };

    int result_size;
    std::mt19937_64 rng;
    std::priority_queue<scored_item> reservoir;
    double skip_weight;
};
