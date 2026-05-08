#ifndef BASE_MUL_ACCEL
#define BASE_MUL_ACCEL

/**
 * @file base_mul_accel.h
 * @brief Header file for base_mul_accel.c
 */

#include <stdint.h>
#include "config_helpers.h"


#define MUL_ACCEL_BASE          0x80003000

#define MUL_A_LOW               (*(volatile uint32_t*)(MUL_ACCEL_BASE + 0x00))
#define MUL_A_HIGH              (*(volatile uint32_t*)(MUL_ACCEL_BASE + 0x04))
#define MUL_B_LOW               (*(volatile uint32_t*)(MUL_ACCEL_BASE + 0x08))
#define MUL_B_HIGH              (*(volatile uint32_t*)(MUL_ACCEL_BASE + 0x0C))

#define MUL_RESULT_LOW          (*(volatile uint32_t*)(MUL_ACCEL_BASE + 0x10))
#define MUL_RESULT_MID_LOW      (*(volatile uint32_t*)(MUL_ACCEL_BASE + 0x14))

#define MUL_RESULT_MID_HIGH     (*(volatile uint32_t*)(MUL_ACCEL_BASE + 0x18))
#define MUL_RESULT_HIGH         (*(volatile uint32_t*)(MUL_ACCEL_BASE + 0x1C))

#ifdef USE_BASE_MUL_ACCEL
    #define base_mul base_mul_hw
#endif


void base_mul_hw(uint64_t *c, uint64_t a, uint64_t b);

#endif