#include "uart_print.h"


#ifdef PC_TEST
    #include <stdio.h>

    void uart_putc(char c) {
        putchar(c);
    }

    char uart_getc(void) {
        return getchar();
    }

    void uart_puts(const char *str) {
        fputs(str, stdout);
    }

    void uart_putint(int val) {
        printf("%d", val);
    }

    void uart_puthex(uint32_t val) {
        printf("0x%08X", val);
    }

    void uart_puthex_array(const char *label, const uint8_t *data, size_t len) {
        printf("%s: ", label);
        for (size_t i = 0; i < len; i++) {
            printf("%02x", data[i]);
        }
        printf("\n");
    }

#else   // Bare-metal embedded implementations
    /**
     * @brief Checks if the UART transmitter is busy.
     * @return 1 if busy, otherwise 0.
     */
    static inline int uart_tx_is_busy(void) {
        return (UART_STATUS & UART_STATUS_TX_BUSY);
    }

    /**
     * @brief Checks if the UART receiver is busy.
     * @return 1 if busy, otherwise 0.
     */
    static inline int uart_rx_is_busy(void) {
        return (UART_STATUS & UART_STATUS_RX_BUSY);
    }

    /**
     * @brief Checks if an error occurred during UART receive.
     * @return 1 if error occurred (start, stop, parity bit error), otherwise 0.
     */
    static inline int uart_rx_error(void) {
        return (UART_STATUS & UART_STATUS_RX_ERROR);
    }

    /**
     * @brief Checks if received data is valid and available.
     * @return 1 if received data is valid/available, otherwise 0.
     */
    static inline int uart_rx_data_is_valid(void) {
        return (UART_STATUS & UART_STATUS_RX_VALID);
    }

    /**
     * @brief Sends a single character over UART.
     * @param c The character to send.
     */
    void uart_putc(char c) {
        while (uart_tx_is_busy());
        UART_TXDATA = (uint32_t)c;
    }

    /**
     * @brief Receives a single character from UART.
     * @return The received character.
     */
    char uart_getc(void) {
        while (!uart_rx_data_is_valid());
        return (char)(UART_RXDATA & 0xFF);
    }

    /**
     * @brief Sends a null-terminated string over UART.
     * @param str The string to send.
     */
    void uart_puts(const char *str) {
        while (*str) {
            if (*str == '\n')
                uart_putc('\r');   // automatic begin at column 0 after newline in terminal

            uart_putc(*str++);
        }
    }

    /**
     * @brief Sends a 32-bit unsigned integer in hexadecimal format over UART.
     * @param val The value to send.
     */
    void uart_puthex(uint32_t val) {
        uart_puts("0x");

        for (int i = 7; i >= 0; i--) {
            uint8_t nibble = (val >> (i * 4)) & 0xF;

            if (nibble < 10) {
                uart_putc('0' + nibble);
            } else {
                uart_putc('A' + (nibble - 10));
            }
        }
    }

    /**
     * @brief Sends a label followed by an array of bytes in hexadecimal format over UART.
     * @param label The label to print before the data.
     * @param data Pointer to the array of bytes.
     * @param len The length of the data array.
     */
    void uart_puthex_array(const char *label, const uint8_t *data, size_t len) {
        uart_puts(label);
        uart_puts(": ");

        for (size_t i = 0; i < len; i++) {
            uint8_t byte = data[i];

            // high nibble
            uint8_t high = (byte >> 4) & 0xF;
            uart_putc(high < 10 ? ('0' + high) : ('a' + high - 10));

            // low nibble
            uint8_t low = byte & 0xF;
            uart_putc(low < 10 ? ('0' + low) : ('a' + low - 10));
        }

        uart_putc('\n');
    }

    /**
     * @brief Sends a signed integer in decimal format over UART.
     * @param val The integer value to send.
     */
    void uart_putint(int val) {
        char buffer[12];
        int i = 0;
        uint32_t uval;

        if (val == 0) {
            uart_putc('0');
            return;
        }

        if (val < 0) {
            uart_putc('-');
            uval = (uint32_t)(-(val + 1)) + 1;
        } else {
            uval = (uint32_t)val;
        }

        while (uval > 0) {
            buffer[i++] = '0' + (uval % 10);
            uval /= 10;
        }

        while (i > 0) {
            uart_putc(buffer[--i]);
        }
    }
    
#endif