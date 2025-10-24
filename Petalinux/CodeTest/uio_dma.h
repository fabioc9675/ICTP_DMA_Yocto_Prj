#ifndef DMA_DRIVER_H
#define DMA_DRIVER_H

#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>

// Offsets / flags
#define S2MM_CONTROL_REGISTER      0x30
#define S2MM_STATUS_REGISTER       0x34
#define S2MM_DST_ADDRESS_REGISTER  0x48
#define S2MM_BUFF_LENGTH_REGISTER  0x58

#define IOC_IRQ_FLAG (1U << 12)
#define IDLE_FLAG    (1U << 1)

#define RESET_DMA   0x00000004U
#define HALT_DMA    0x00000000U
#define RUN_DMA     0x00000001U
#define ENABLE_ALL_IRQ 0x00007000U

// Handle struct
typedef struct {
    int fd;
    volatile uint8_t *dma_regs;
    size_t dma_map_size;
    volatile uint8_t *dst_mem;
    size_t dst_map_size;
    off_t dma_regs_phys;
    off_t dst_phys_addr;
} dma_handle_t;

#ifdef __cplusplus
extern "C" {
#endif

dma_handle_t* dma_open_mem(off_t dma_regs_phys, size_t dma_map_size,
                           off_t dst_phys_addr, size_t dst_map_size);

int dma_start_and_wait(dma_handle_t* h, uint32_t length, int timeout_ms);
// returns 0 on success, 1 on timeout, -1 on error

uint32_t dma_read_reg(dma_handle_t* h, uint32_t offset);
uintptr_t dma_get_buffer_ptr(dma_handle_t* h);
void dma_close(dma_handle_t* h);

#ifdef __cplusplus
}
#endif

#endif // DMA_DRIVER_H
