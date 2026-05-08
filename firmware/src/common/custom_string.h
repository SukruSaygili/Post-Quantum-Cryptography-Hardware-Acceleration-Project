#ifndef CUSTOM_STRING_H
#define CUSTOM_STRING_H

/**
 * @file custom_string.h
 * @brief Header file for custom_string.c
 */

#include <stddef.h>
#include <stdint.h>


#ifdef PC_TEST
    #include <string.h>
    
    #define memset_zero(ptr, len) memset(ptr, 0, len)
#else
    void *memcpy(void *dest, const void *src, size_t n);
    void *memset(void *s, int c, size_t n);
    int memcmp(const void *s1, const void *s2, size_t n);
    void memset_zero(void *buf, size_t len);
#endif


#endif