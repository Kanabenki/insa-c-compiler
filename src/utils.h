#include <stdint.h>

#define LOWB(x) x & 0xFF
#define HIGHB(x) (x >> 8) & 0xFF

typedef uint8_t u8;
typedef uint16_t u16;