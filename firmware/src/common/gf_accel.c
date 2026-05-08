#include "gf_accel.h"

/**
 * @brief Write the lower 32 bits of operand A to the hardware accelerator.
 *
 * @param a Lower 32-bit value of operand A.
 */
static inline void gf_write_a_low(uint32_t a) {
    GF_A_LOW = a;
}

/**
 * @brief Write the upper 32 bits of operand A to the hardware accelerator.
 *
 * @param a Upper 32-bit value of operand A.
 */
static inline void gf_write_a_high(uint32_t a) {
    GF_A_HIGH = a;
}

/**
 * @brief Write operand B to the hardware accelerator.
 *
 * @param b 32-bit value of operand B.
 */
static inline void gf_write_b(uint32_t b) {
    GF_B = b;
}

/**
 * @brief Set the operation mode of the GF hardware accelerator.
 *
 * @param mode Operation mode (e.g., GF_MODE_MUL_REDUCE, GF_MODE_SQUARE_REDUCE).
 */
static inline void gf_set_mode(uint32_t mode) {
    GF_MODE = mode;
}

/**
 * @brief Start the hardware accelerator computation.
 *
 * Writing 1 to GF_CTRL starts the operation. The hardware clears
 * this bit when the computation is complete.
 */
static inline void gf_start() {
    GF_CTRL = 1; // hardware zet vervolgens deze op nul wanneer berekening klaar is
}

/**
 * @brief Wait until the hardware accelerator finishes computation.
 *
 * Busy-waits until the GF_CTRL register indicates completion.
 */
static inline void gf_wait() {
    while((GF_CTRL & 1) == 1);
}

/**
 * @brief Read the result from the hardware accelerator.
 *
 * @return Lower 16 bits of the GF_RESULT register.
 */
static inline uint16_t gf_read_result() {
    return (uint16_t)(GF_RESULT & 0xFFFF);
}

/**
 * @brief Perform Galois Field multiplication using hardware acceleration.
 *
 * Multiplies two 16-bit field elements and reduces the result.
 *
 * @param a First operand.
 * @param b Second operand.
 * @return Result of a * b in GF.
 */
uint16_t gf_mul_hw(uint16_t a, uint16_t b) {
    gf_set_mode(GF_MODE_MUL_REDUCE);
    gf_write_a_low(a);
    gf_write_b(b);
    
    gf_start();
    gf_wait();
    
    return gf_read_result();
}

/**
 * @brief Perform Galois Field squaring using hardware acceleration.
 *
 * Squares a 16-bit field element and reduces the result.
 *
 * @param a Operand to square.
 * @return Result of a^2 in GF.
 */
uint16_t gf_square_hw(uint16_t a) {
    gf_set_mode(GF_MODE_SQUARE_REDUCE);

    gf_write_a_low(a);
    
    gf_start();
    gf_wait();
    
    return gf_read_result();
}

/**
 * @brief Reduce a 64-bit value in the Galois Field using hardware acceleration.
 *
 * Splits the 64-bit input across A_LOW and A_HIGH registers and performs
 * field reduction.
 *
 * @param x 64-bit value to reduce.
 * @return Reduced 16-bit field element.
 */
uint16_t gf_reduce_hw(uint64_t x) {
    gf_set_mode(GF_MODE_REDUCE_ONLY);

    gf_write_a_low((uint32_t)(x & 0xFFFFFFFF));
    gf_write_a_high((uint32_t)(x >> 32));
    
    gf_start();
    gf_wait();
    
    return gf_read_result();
}

/**
 * @brief Compute multiplicative inverse in the Galois Field using hardware acceleration.
 *
 * @param a Input field element.
 * @return Multiplicative inverse of a in GF.
 */
uint16_t gf_inverse_hw(uint16_t a) {
    gf_set_mode(GF_MODE_INVERSE);
    gf_write_a_low(a);

    gf_start();
    gf_wait();

    return gf_read_result();
}

/* * --- Replacements (wrappers) for the original library (gf.h/gf.c) ---
 * By implementing the original function names here in the .c file,
 * the linker (ld) will resolve calls to the original API to these
 * hardware-accelerated implementations when USE_GF_ACCEL is defined.
 */
#ifdef USE_GF_ACCEL
uint16_t PQCLEAN_HQC128_CLEAN_gf_mul(uint16_t a, uint16_t b) {
    return gf_mul_hw(a, b);
}

uint16_t PQCLEAN_HQC128_CLEAN_gf_square(uint16_t a) {
    return gf_square_hw(a);
}

uint16_t PQCLEAN_HQC128_CLEAN_gf_inverse(uint16_t a) {
    return gf_inverse_hw(a);
}

uint16_t PQCLEAN_HQC192_CLEAN_gf_mul(uint16_t a, uint16_t b) {
    return gf_mul_hw(a, b);
}

uint16_t PQCLEAN_HQC192_CLEAN_gf_square(uint16_t a) {
    return gf_square_hw(a);
}

uint16_t PQCLEAN_HQC192_CLEAN_gf_inverse(uint16_t a) {
    return gf_inverse_hw(a);
}

uint16_t PQCLEAN_HQC256_CLEAN_gf_mul(uint16_t a, uint16_t b) {
    return gf_mul_hw(a, b);
}

uint16_t PQCLEAN_HQC256_CLEAN_gf_square(uint16_t a) {
    return gf_square_hw(a);
}

uint16_t PQCLEAN_HQC256_CLEAN_gf_inverse(uint16_t a) {
    return gf_inverse_hw(a);
}
#endif