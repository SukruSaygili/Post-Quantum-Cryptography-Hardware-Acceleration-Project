#include "trng.h"

/**
 * @file trng.c
 * @brief Implementation of true random number generator
 */

/**
 * @brief Initialize and start the True Random Number Generator
 */
void trng_init(void) {
    // Set the enable bit to 1
    TRNG_CTRL |= TRNG_ENABLE_BIT;
}

/**
 * @brief Stop the TRNG to save power/reduce noise
 */
void trng_stop(void) {
    // Clear the enable bit
    TRNG_CTRL &= ~TRNG_ENABLE_BIT;
}

/**
 * @brief Get a single random byte (blocking)
 * @return 8-bit random value
 */
uint8_t trng_get_byte(void) {
    // Poll the VALID bit (bit 1) until it becomes 1
    while ((TRNG_CTRL & TRNG_VALID_BIT) == 0);
    // Read the data register. 
    // Doing this hardware-clears the VALID bit for the next byte.
    return (uint8_t)(TRNG_DATA & 0xFF);
}

/**
 * @brief Fill an array with random bytes (blocking)
 * @param buffer Pointer to the array to fill
 * @param len Number of bytes to read
 */
void trng_get_bytes(uint8_t *buffer, size_t len) {
    for (size_t i = 0; i < len; i++) {
        buffer[i] = trng_get_byte();
    }
}