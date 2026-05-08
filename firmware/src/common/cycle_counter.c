#include "cycle_counter.h"

/**
 * @file cycle_counter.c
 * @brief Implementation of cycle counter
 */

 #ifdef PC_TEST
    uint64_t read_cycles() {
        return 0;
    }

    void reset_cycle_counter() {}
#else
    uint64_t read_cycles() {
        uint32_t hi1, lo, hi2;

        do {
            hi1 = COUNTER_HIGH;
            lo  = COUNTER_LOW;
            hi2 = COUNTER_HIGH;
        } while (hi1 != hi2);

        return ((uint64_t)hi1 << 32) | lo;
    }

    void reset_cycle_counter() {
        COUNTER_LOW = 0;
    }
#endif