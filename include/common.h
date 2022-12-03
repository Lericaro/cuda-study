#ifndef __COMMON_H__
#define __COMMON_H__

#include <chrono>
#include <cstdlib>
#include <iostream>
#include <string_view>

#define DEBUG

#ifdef DEBUG
struct Profiler {
    std::string_view name;
    std::chrono::high_resolution_clock::time_point p;
    Profiler(std::string_view name)
        : name(name), p(std::chrono::high_resolution_clock::now()) {}
    ~Profiler() {
        using dur = std::chrono::microseconds;
        auto dd = std::chrono::high_resolution_clock::now() - p;
        std::cout << name << ": " << std::chrono::duration_cast<dur>(dd).count()
                  << " us \n";
    }
};

#define PROFILE_BLOCK(pb) Profiler __pfinstance(pb)

#endif

template <typename T> void fillData(T *x, int len) {
    for (int i = 0; i < len; i++)
        x[i] = rand() % 1007;
}

template <> inline void fillData(float *x, int len) {
    for (int i = 0; i < len; i++)
       // x[i] = rand() % 1007 + rand() % 1000000007 / 1000000007.0;
        x[i] = rand() % 7;
}

template <typename T> void printMatrix(T *x, int n, int m) {
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            std::cout << x[j + i * m] << ' ';
        }
        std::cout << '\n';
    }
    std::cout << '\n';
}
#endif