#ifndef GF_ACCEL_H
#define GF_ACCEL_H

/**
 * @file gf_accel.h
 * @brief Header file for gf_accel.c
 */

#include <stdint.h>
#include "config_helpers.h"


#define GF_ACCEL_BASE           0x80004000

#define GF_A_LOW                (*(volatile uint32_t*)(GF_ACCEL_BASE + 0x00))
#define GF_A_HIGH               (*(volatile uint32_t*)(GF_ACCEL_BASE + 0x04))
#define GF_B                    (*(volatile uint32_t*)(GF_ACCEL_BASE + 0x08))
#define GF_MODE                 (*(volatile uint32_t*)(GF_ACCEL_BASE + 0x0C))
#define GF_CTRL                 (*(volatile uint32_t*)(GF_ACCEL_BASE + 0x10))
#define GF_RESULT               (*(volatile uint32_t*)(GF_ACCEL_BASE + 0x14))

#define GF_MODE_MUL_REDUCE      0
#define GF_MODE_SQUARE_REDUCE   1
#define GF_MODE_REDUCE_ONLY     2
#define GF_MODE_INVERSE         3


uint16_t gf_mul_hw(uint16_t a, uint16_t b);
uint16_t gf_square_hw(uint16_t a);
uint16_t gf_inverse_hw(uint16_t a);
uint16_t gf_reduce_hw(uint64_t x);

#endif