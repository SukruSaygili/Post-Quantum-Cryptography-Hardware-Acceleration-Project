#include "config_helpers.h"
#include "trng.h"

/**
 * @file config_helpers.c
 * @brief Implementation of configuration helper functions
 */


#ifdef PC_TEST
    #include <sys/random.h>
    uint32_t fake_bss_end = 0;
    uint32_t fake_stack_top = 0;
    
    /**
     * print_hex_pc_test - Print hex-encoded data with a label
     * @label: descriptive label for the data being printed
     * @data:  pointer to byte array to be printed in hexadecimal format
     * @len:   number of bytes to print
     *
     * Prints the provided data as hexadecimal values preceded by a label.
     * This function is only available when PC_TEST is defined and is intended
     * for debugging and testing on a host computer.
     *
     * Example output: "label: 0a1b2c3d"
     */
    void print_hex_pc_test(const char *label, const uint8_t *data, size_t len) {
        printf("%s: ", label);
        for (size_t i = 0; i < len; ++i)
            printf("%02x", data[i]);
        printf("\n");
    }

    void stack_paint(void) {}
    size_t get_stack_usage_bytes(void) { return 0; }

#else
    /**
     * stack_paint - Initialize stack memory with sentinel value for tracking
     *
     * Fills the entire stack region (from STACK_BOTTOM to STACK_TOP) with
     * the sentinel value 0xFFFFFFFF. This allows get_stack_usage_bytes() to determine
     * the maximum stack depth used by finding where this pattern is first
     * overwritten by actual stack data.
     */
    void stack_paint(void) {
        uint32_t *p = (uint32_t*)STACK_BOTTOM;
        while (p < (uint32_t*)STACK_TOP) {
            *p++ = 0xFFFFFFFF;
        }
    }

    /**
     * get_stack_usage_bytes - Calculate maximum stack usage in bytes
     *
     * Returns the number of bytes that have been used on the stack by
     * counting from STACK_BOTTOM until the first byte that is not the
     * sentinel value 0xFFFFFFFF. This gives a measure of the peak stack
     * depth used. stack_paint() must be called first to initialize
     * the stack region with the sentinel pattern.
     *
     * Return: Number of bytes of stack that have been used/overwritten
     */
    size_t get_stack_usage_bytes(void) {
        uint32_t *p = (uint32_t*)STACK_BOTTOM;

        while (p < (uint32_t*)STACK_TOP && *p == 0xFFFFFFFF) {
            p++;
        }

    return (size_t)((uintptr_t)STACK_TOP - (uintptr_t)p);
    }
#endif

/**
 * init_seed - Initialize a seed buffer with deterministic or placeholder values
 * @seed:     pointer to buffer to be filled with seed data
 * @seed_len: length of the seed buffer in bytes
 *
 * Initializes the provided seed buffer with either deterministic values
 * (when DETERMINISTIC is defined) or placeholder zeros. When DETERMINISTIC
 * is defined, each byte is set to its index value for reproducibility in
 * testing. Otherwise, a placeholder implementation for a random number generator is used.
 * 
 *
 * Note: For production use, replace the placeholder implementation with
 *       actual hardware random number generation.
 */
void init_seed(uint8_t *seed, size_t seed_len) {
    #ifdef DETERMINISTIC
        // Fixed seed for reproducibility
        for (size_t i = 0; i < seed_len; i++) seed[i] = (unsigned char)i;
    #else
        #ifndef PC_TEST
            trng_init();
        
            trng_get_bytes(seed, seed_len);

            trng_stop();
        #else
            ssize_t ret = getrandom(seed, seed_len, 0);
            if (ret != (ssize_t)seed_len) {
                // fallback of error handling
            }
        #endif
    #endif
}