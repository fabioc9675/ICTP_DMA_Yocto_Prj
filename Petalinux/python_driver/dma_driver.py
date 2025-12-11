import os
import mmap
import struct
import numpy as np
import time
import matplotlib.pyplot as plt


# Definición de constantes
S2MM_CONTROL_REGISTER = 0x30
S2MM_STATUS_REGISTER = 0x34
S2MM_DST_ADDRESS_REGISTER = 0x48
S2MM_BUFF_LENGTH_REGISTER = 0x58

IOC_IRQ_FLAG = 1 << 12
IDLE_FLAG = 1 << 1

RESET_DMA = 0x00000004
HALT_DMA = 0x00000000
RUN_DMA = 0x00000001
ENABLE_ALL_IRQ = 0x00007000

DMA_BASE_ADDR = 0x80020000  # Dirección base del DMA AXI Lite
DMA_DIFF_ADDR = 0x80040000  # Dirección base del DMA AXI Lite
DMA_SINE_ADDR = 0x80010000  # Dirección base del DMA AXI Lite
DST_BASE_ADDR = 0x0f000000  # Dirección base destino de memoria
DST_SINE_ADDR = 0x0c000000  # Dirección base destino de memoria
DST_DIFF_ADDR = 0x0c000000  # Dirección base destino de memoria
DMA_MAP_SIZE = 65536
DST_MAP_SIZE = 8192 * 4


# Función para escribir en el DMA
def write_dma(mm, offset, value):
    mm[offset:offset+4] = struct.pack('<I', value)

# Función para leer desde el DMA
def read_dma(mm, offset):
    return struct.unpack('<I', mm[offset:offset+4])[0]

# Imprimir el estado del DMA
def dma_s2mm_status(mm):
    status = read_dma(mm, S2MM_STATUS_REGISTER)
    print(f"Stream to memory-mapped status (0x{status:08X}):")
    if status & 0x1:
        print("  Halted.")
    if status & IDLE_FLAG:
        print("  Idle.")
    if status & IOC_IRQ_FLAG:
        print("  IOC interrupt occurred.")
    print()
    
# Sincronización del DMA
def dma_s2mm_sync(mm):
    counter = 0
    while True:
        status = read_dma(mm, S2MM_STATUS_REGISTER)
        if (status == 0x5011): # (status & IOC_IRQ_FLAG) and (status & IDLE_FLAG):
            break
        dma_s2mm_status(mm)
        time.sleep(0.1)  # Agregar un pequeño retraso
        counter += 1
        if counter >= 5:  # Tiempo de espera máximo
            print("Timeout esperando sincronización del DMA.")
            break
            
            
# Imprimir datos en memoria
def print_mem(mm, byte_count):
    for i in range(byte_count):
        print(f"{mm[i]:02X}", end="")
        if i % 4 == 3:
            print(" ", end="")
    print()
    
    
def get_mem_data(mm, byte_count):
    num_elements = byte_count // 4  # El número de elementos de 4 bytes (32 bits)
    delay = 8
    data = np.zeros(num_elements-delay, dtype=np.uint32)  # Crear un array de ceros de tipo uint32
    for i in range(delay,num_elements):
        # Leer 4 bytes y almacenarlos como un entero de 32 bits (uint32)
        data[i-delay] = struct.unpack('<I', mm[i*4:i*4+4])[0]
    return data


def plot_mem_data(data):
    # Graficar los datos y su derivada
    derivative = np.diff(data)  # np.diff calcula la diferencia entre elementos consecutivos
    
    plt.figure(figsize=(10, 4))

    # Graficar los datos originales
    #plt.subplot(2, 1, 1)
    plt.plot(data, label="Datos Originales")
    plt.title("Señal Original")
    plt.xlabel("Índice")
    plt.ylabel("Valor de la Señal")
    plt.grid(True)
    plt.legend()
    plt.xlim([1000,3000])
    #plt.ylim([data[1000],data[7000]])
    #plt.show()
    
     # Graficar la derivada
    #plt.subplot(2, 1, 2)
    #plt.plot(derivative, label="Derivada", color='red')
    #plt.title("Derivada de la Señal")
    #plt.xlabel("Índice")
    #plt.ylabel("Valor de la Derivada")
    #plt.grid(True)
    #plt.legend()