#ifndef UART_PRINT_H
#define UART_PRINT_H

/**
 * @file uart_print.h
 * @brief Header file for uart_print.c
 */

#include <stdint.h>
#include <stddef.h>


#define UART_BASE      0x80000000

#define UART_TXDATA    (*(volatile uint32_t*)(UART_BASE + 0x00))
#define UART_STATUS    (*(volatile uint32_t*)(UART_BASE + 0x04))
#define UART_RXDATA    (*(volatile uint32_t*)(UART_BASE + 0x08))

// Status register masks
#define UART_STATUS_TX_BUSY      0x1
#define UART_STATUS_RX_BUSY      0x2
#define UART_STATUS_RX_ERROR     0x4
#define UART_STATUS_RX_VALID     0x8


void uart_putc(char c);
char uart_getc(void);
void uart_puts(const char *s);
void uart_putint(int val);
void uart_puthex(uint32_t val);
void uart_puthex_array(const char *label, const uint8_t *data, size_t len);


#endif