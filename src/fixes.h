/*
 * Helper macros to safely access packed structure members
 * This avoids alignment warnings while maintaining functionality
 */

#ifndef _FIXES_H
#define _FIXES_H

#include <string.h>

/* Safe copy macros for packed structures */
#define SAFE_COPY(dst, src, type) \
    do { \
        type temp; \
        memcpy(&temp, src, sizeof(type)); \
        dst = temp; \
    } while(0)

#define SAFE_COPY_PTR(dst, src, type) \
    do { \
        memcpy(dst, src, sizeof(type)); \
    } while(0)

#endif /* _FIXES_H */
