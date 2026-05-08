#include "custom_string.h"

#ifndef PC_TEST
    /**
     * @brief Copies n bytes from src to dest.
     * @param dest Pointer to the destination buffer.
     * @param src Pointer to the source buffer.
     * @param n Number of bytes to copy.
     * @return Pointer to dest.
     */
    void *memcpy(void *dest, const void *src, size_t n) {
        unsigned char *d = dest;
        const unsigned char *s = src;

        for(size_t i = 0; i < n; i++)
            d[i] = s[i];

        return dest;
    }

    /**
     * @brief Sets the first n bytes of s to the value c.
     * @param s Pointer to the buffer to fill.
     * @param c Value to set (converted to unsigned char).
     * @param n Number of bytes to set.
     * @return Pointer to s.
     */
    void *memset(void *s, int c, size_t n) {
        unsigned char *p = s;

        for(size_t i = 0; i < n; i++)
            p[i] = (unsigned char)c;

        return s;
    }

    /**
     * @brief Zeroizes (sets to zero) a buffer to prevent information leakage.
     * @param buf Pointer to the buffer to zeroize.
     * @param len Length of the buffer in bytes.
     */
    void memset_zero(void *buf, size_t len) { // VERANDERD naar void*
        volatile uint8_t *p = (volatile uint8_t *)buf; // Cast hier naar volatile voor security
        while (len--) *p++ = 0;
    }
    /**
     * @brief Compares the first n bytes of s1 and s2.
     * @param s1 Pointer to the first buffer.
     * @param s2 Pointer to the second buffer.
     * @param n Number of bytes to compare.
     * @return An integer less than, equal to, or greater than zero if s1 is found,
     *         respectively, to be less than, to match, or be greater than s2.
     */
    int memcmp(const void *s1, const void *s2, size_t n) {
        const unsigned char *a = s1;
        const unsigned char *b = s2;

        for(size_t i = 0; i < n; i++)
        {
            if(a[i] != b[i])
                return a[i] - b[i];
        }

        return 0;
    }
#endif