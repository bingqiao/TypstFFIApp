#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

uint8_t *compile_typst(const char *input, size_t *output_len);

void free_typst_buffer(uint8_t *ptr);
