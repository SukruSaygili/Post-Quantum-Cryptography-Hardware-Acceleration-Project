#ifndef CYCLE_COUNTER_H
#define CYCLE_COUNTER_H

/**
 * @file cycle_counter.h
 * @brief Header file for cycle_counter.c
 */

#include <stdint.h>


#define COUNTER_BASE      0x80002000

#define COUNTER_LOW  (*(volatile uint32_t*)(COUNTER_BASE + 0x00))
#define COUNTER_HIGH (*(volatile uint32_t*)(COUNTER_BASE + 0x04))


uint64_t read_cycles();
void reset_cycle_counter();

#endif