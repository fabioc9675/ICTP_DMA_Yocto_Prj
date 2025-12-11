#ifndef AXI_MMAP_H
#define AXI_MMAP_H

#include <stdint.h>

// function to read from memory-mapped AXI registers
uint32_t axi_read_reg(uintptr_t base_addr, uint32_t offset);

// function to write to memory-mapped AXI registers
void axi_write_reg(uintptr_t base_addr, uint32_t offset, uint32_t value);

#endif // AXI_MMAP_H