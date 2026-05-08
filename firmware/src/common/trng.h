#ifndef TRNG_H
#define TRNG_H

/**
 * @file trng.h
 * @brief Header file for trng.c
 */

#include <stdint.h>
#include <stddef.h>


#define TRNG_BASE_ADDR 0x80005000

#define TRNG_CTRL (*(volatile uint32_t*)(TRNG_BASE_ADDR + 0x00))
#define TRNG_DATA (*(volatile uint32_t*)(TRNG_BASE_ADDR + 0x04))

// Control/status register bitmasks
#define TRNG_ENABLE_BIT 0x00000001
#define TRNG_VALID_BIT  0x00000002


void trng_init(void);
void trng_stop(void);
uint8_t trng_get_byte(void);
void trng_get_bytes(uint8_t *buffer, size_t len);


#endif