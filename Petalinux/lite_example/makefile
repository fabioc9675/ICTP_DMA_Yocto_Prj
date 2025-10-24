CC = gcc
CFLAGS = -Wall -O2 -fPIC
LDFLAGS = -shared

TARGET = libaxi_mmap.so
SRCS = axi_mmap.c
OBJS = $(SRCS:.c=.o)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)