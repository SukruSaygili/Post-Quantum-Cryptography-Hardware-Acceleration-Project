#ifndef RANDOMBYTES_H
#define RANDOMBYTES_H

/**
 * @file randombytes.h
 * @brief Header file for randombytes.c
 */
#include <stddef.h>
#include <stdint.h>


void init_randombytes(uint8_t *seed, size_t seed_len);
int randombytes(uint8_t *output, size_t n);


#endif