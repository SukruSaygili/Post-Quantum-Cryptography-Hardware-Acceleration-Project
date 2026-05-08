#include "base_mul_accel.h"

/**
 * @file base_mul_accel.c
 * @brief Implementation of base multiplication accelerator
 */

/**
 * @brief Write operand A to the hardware multiplier.
 *
 * Splits a 64-bit operand into two 32-bit words and writes them
 * to the corresponding hardware registers.
 *
 * @param a 64-bit input operand A.
 */
static inline void mul_write_a(uint64_t a) {
    MUL_A_LOW  = (uint32_t)(a);
    MUL_A_HIGH = (uint32_t)(a >> 32);
}

/**
 * @brief Write operand B to the hardware multiplier.
 *
 * Splits a 64-bit operand into two 32-bit words and writes them
 * to the corresponding hardware registers.
 *
 * @param b 64-bit input operand B.
 */
static inline void mul_write_b(uint64_t b) {
    MUL_B_LOW  = (uint32_t)(b);
    MUL_B_HIGH = (uint32_t)(b >> 32);
}

/**
 * @brief Read the 128-bit result from the hardware multiplier.
 *
 * Reads four 32-bit result registers and reconstructs the full
 * 128-bit product. The result is returned as two 64-bit words:
 *
 * - c[0]: lower 64 bits of the product
 * - c[1]: upper 64 bits of the product
 *
 * @param[out] c Pointer to an array of at least two uint64_t elements
 *               where the result will be stored.
 */
static inline void mul_read(uint64_t *c) {
    uint64_t r0 = MUL_RESULT_LOW;
    uint64_t r1 = MUL_RESULT_MID_LOW;
    uint64_t r2 = MUL_RESULT_MID_HIGH;
    uint64_t r3 = MUL_RESULT_HIGH;

    c[0] = r0 | (r1 << 32);
    c[1] = r2 | (r3 << 32);
}

/**
 * @brief Perform 64-bit hardware multiplication.
 *
 * Writes operands to the hardware multiplier and reads back
 * the resulting 128-bit product.
 *
 * This function assumes the hardware multiplier is purely
 * combinational or produces a result without requiring explicit
 * start/ready signaling.
 *
 * @param[out] c Pointer to an array of at least two uint64_t elements
 *               to store the 128-bit result:
 *               - c[0]: lower 64 bits
 *               - c[1]: upper 64 bits
 * @param a First 64-bit operand.
 * @param b Second 64-bit operand.
 */
void base_mul_hw(uint64_t *c, uint64_t a, uint64_t b) {
    mul_write_a(a);
    mul_write_b(b);

    mul_read(c);
}