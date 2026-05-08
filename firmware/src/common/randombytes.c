#include "randombytes.h"
#include "../hqc_1_128/shake_prng.h"

/**
 * @file randombytes.c
 * @brief Implementation of random byte generator
 */


static seedexpander_state deterministic_prng;

void init_randombytes(uint8_t *seed, size_t seed_len) {
    PQCLEAN_HQC128_CLEAN_seedexpander_init(&deterministic_prng, seed, seed_len);
}

int randombytes(uint8_t *out, size_t outlen) {
    PQCLEAN_HQC128_CLEAN_seedexpander(&deterministic_prng, out, outlen);
    return 0;
}