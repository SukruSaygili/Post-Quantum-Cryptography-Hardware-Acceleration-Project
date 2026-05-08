#ifndef CONFIG_HELPERS_H
#define CONFIG_HELPERS_H

/**
 * @file config_helpers.h
 * @brief Helper functions for stack usage measurement and seed initialization
 */

#include <stdint.h>
#include <stddef.h>
    

// Override PQClean functions with hardware-accelerated versions
#define USE_BASE_MUL_ACCEL
#define USE_GF_ACCEL

// Uncomment for deterministic baseline testing
#define DETERMINISTIC

/*DO NOT DEFINE THIS HERE, IT GETS DEFINED IN THE Makefile */
//#define PC_TEST

#ifdef PC_TEST
    #include <stdio.h>
    #undef USE_BASE_MUL_ACCEL
    #undef USE_GF_ACCEL

    #define STACK_BOTTOM ((uintptr_t)&fake_bss_end)
    #define STACK_TOP    ((uintptr_t)&fake_stack_top)

    extern uint32_t fake_bss_end;
    extern uint32_t fake_stack_top;

    void print_hex_pc_test(const char *label, const uint8_t *data, size_t len);

#else
    extern uint8_t __bss_end;  // end of bss (from linker)
    extern uint8_t __stack_top; // top of stack (from linker)

    #define STACK_BOTTOM ((uintptr_t)&__bss_end)
    #define STACK_TOP    ((uintptr_t)&__stack_top)
#endif

void stack_paint(void);
size_t get_stack_usage_bytes(void);

void init_seed(uint8_t *seed, size_t seed_len);


#endif