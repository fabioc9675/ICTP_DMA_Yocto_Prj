#define _POSIX_C_SOURCE 200809L
#include "axi_mmap.h"
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdint.h>

uint32_t axi_read_reg(uintptr_t base_addr, uint32_t offset) {
    int mem_fd;
    void *mapped_base;
    uint32_t value = 0xFFFFFFFFU;

    long page_size = sysconf(_SC_PAGESIZE);
    if (page_size <= 0) {
        perror("sysconf(_SC_PAGESIZE)");
        return value;
    }

    mem_fd = open("/dev/mem", O_RDONLY | O_SYNC);
    if (mem_fd < 0) {
        perror("open(/dev/mem)");
        return value;
    }

    uintptr_t page_addr = (base_addr + offset) & ~(page_size - 1);
    uintptr_t page_offset = (base_addr + offset) - page_addr;

    mapped_base = mmap(NULL, page_size, PROT_READ, MAP_SHARED, mem_fd, page_addr);
    if (mapped_base == MAP_FAILED) {
        perror("mmap");
        close(mem_fd);
        return value;
    }

    volatile uint32_t* reg_ptr = (volatile uint32_t*)((uint8_t*)mapped_base + page_offset);
    value = *reg_ptr;

    munmap(mapped_base, page_size);
    close(mem_fd);

    return value;
}

void axi_write_reg(uintptr_t base_addr, uint32_t offset, uint32_t value) {
    int mem_fd;
    void *mapped_base;

    long page_size = sysconf(_SC_PAGESIZE);
    if (page_size <= 0) {
        perror("sysconf(_SC_PAGESIZE)");
        return;
    }

    mem_fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (mem_fd < 0) {
        perror("open(/dev/mem)");
        return;
    }

    uintptr_t page_addr = (base_addr + offset) & ~(page_size - 1);
    uintptr_t page_offset = (base_addr + offset) - page_addr;

    mapped_base = mmap(NULL, page_size, PROT_READ | PROT_WRITE, MAP_SHARED, mem_fd, page_addr);
    if (mapped_base == MAP_FAILED) {
        perror("mmap");
        close(mem_fd);
        return;
    }

    volatile uint32_t* reg_ptr = (volatile uint32_t*)((uint8_t*)mapped_base + page_offset);
    *reg_ptr = value;
    __sync_synchronize();

    munmap(mapped_base, page_size);
    close(mem_fd);
}
