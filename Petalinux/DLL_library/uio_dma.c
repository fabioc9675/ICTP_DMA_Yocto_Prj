#define _POSIX_C_SOURCE 200809L
#include "uio_dma.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <string.h>
#include <time.h>

static inline void udelay(unsigned int usec) {
    struct timespec ts;
    ts.tv_sec  = usec / 1000000;
    ts.tv_nsec = (usec % 1000000) * 1000;
    nanosleep(&ts, NULL);
}

dma_handle_t* dma_open_mem(off_t dma_regs_phys, size_t dma_map_size,
                           off_t dst_phys_addr, size_t dst_map_size) {
    dma_handle_t *h = calloc(1, sizeof(*h));
    if (!h) return NULL;

    h->fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (h->fd < 0) {
        perror("open(/dev/mem)");
        free(h);
        return NULL;
    }

    // map dma registers
    h->dma_regs = mmap(NULL, dma_map_size, PROT_READ | PROT_WRITE,
                       MAP_SHARED, h->fd, dma_regs_phys);
    if (h->dma_regs == MAP_FAILED) {
        perror("mmap dma_regs");
        close(h->fd);
        free(h);
        return NULL;
    }
    h->dma_map_size = dma_map_size;
    h->dma_regs_phys = dma_regs_phys;

    // map destination buffer
    h->dst_mem = mmap(NULL, dst_map_size, PROT_READ | PROT_WRITE,
                      MAP_SHARED, h->fd, dst_phys_addr);
    if (h->dst_mem == MAP_FAILED) {
        perror("mmap dst_mem");
        munmap((void*)h->dma_regs, h->dma_map_size);
        close(h->fd);
        free(h);
        return NULL;
    }
    h->dst_map_size = dst_map_size;
    h->dst_phys_addr = dst_phys_addr;

    return h;
}

static inline void write_reg(dma_handle_t* h, uint32_t offset, uint32_t value) {
    volatile uint32_t *p = (volatile uint32_t*)(h->dma_regs + offset);
    *p = value;
    __sync_synchronize();
}

static inline uint32_t read_reg(dma_handle_t* h, uint32_t offset) {
    volatile uint32_t *p = (volatile uint32_t*)(h->dma_regs + offset);
    uint32_t v = *p;
    __sync_synchronize();
    return v;
}

int dma_start_and_wait(dma_handle_t* h, uint32_t length, int timeout_ms) {
    if (!h) return -1;

    // 1) RESET
    write_reg(h, S2MM_CONTROL_REGISTER, RESET_DMA);
    // msleep(1);

    // 2) HALT
    write_reg(h, S2MM_CONTROL_REGISTER, HALT_DMA);
    // msleep(1);

    // 3) ENABLE ALL IRQ
    write_reg(h, S2MM_CONTROL_REGISTER, ENABLE_ALL_IRQ);
    // msleep(1);
    // fprintf(stderr, "DBG: CONTROL after ENABLE_ALL_IRQ = 0x%08X\n",
    //         read_reg(h, S2MM_CONTROL_REGISTER));

    // 4) write destination address
    write_reg(h, S2MM_DST_ADDRESS_REGISTER,
              (uint32_t)(h->dst_phys_addr & 0xFFFFFFFFU));
    // msleep(1);
    // fprintf(stderr, "DBG: DST addr reg = 0x%08X\n",
    //         read_reg(h, S2MM_DST_ADDRESS_REGISTER));

    // 5) RUN
    write_reg(h, S2MM_CONTROL_REGISTER, RUN_DMA);
    // msleep(1);
    // fprintf(stderr, "DBG: CONTROL after RUN = 0x%08X\n",
    //         read_reg(h, S2MM_CONTROL_REGISTER));

    // 6) write buff length
    write_reg(h, S2MM_BUFF_LENGTH_REGISTER, length);
    // msleep(1);
    // fprintf(stderr, "DBG: LENGTH reg = 0x%08X\n",
    //         read_reg(h, S2MM_BUFF_LENGTH_REGISTER));

    // 7) wait for completion
    int elapsed = 0;
    while (elapsed < timeout_ms * 1000) { // en us
        uint32_t status = read_reg(h, S2MM_STATUS_REGISTER);
        if (status == 0x5011U) return 0;
        if ((status & IOC_IRQ_FLAG) && (status & IDLE_FLAG)) return 0;
        udelay(1);   // espera 1 µs
        elapsed++;
    }
    return 1; // timeout
}

uint32_t dma_read_reg(dma_handle_t* h, uint32_t offset) {
    if (!h) return 0xFFFFFFFFU;
    return read_reg(h, offset);
}

uintptr_t dma_get_buffer_ptr(dma_handle_t* h) {
    if (!h) return 0;
    return (uintptr_t)h->dst_mem;
}

void dma_close(dma_handle_t* h) {
    if (!h) return;
    if (h->dst_mem && h->dst_mem != MAP_FAILED)
        munmap((void*)h->dst_mem, h->dst_map_size);
    if (h->dma_regs && h->dma_regs != MAP_FAILED)
        munmap((void*)h->dma_regs, h->dma_map_size);
    if (h->fd >= 0) close(h->fd);
    free(h);
}
