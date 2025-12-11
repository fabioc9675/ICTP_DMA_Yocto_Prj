CC = gcc
CFLAGS = -O2 -fPIC -Wall -Wextra
LDFLAGS = -shared
TARGET = libuio_dma.so

all: $(TARGET)

$(TARGET): uio_dma.c uio_dma.h
	$(CC) $(CFLAGS) uio_dma.c -o $(TARGET) $(LDFLAGS)

clean:
	rm -f $(TARGET) *.o
	