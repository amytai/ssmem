SRC = src
INCLUDE = include
BENCH = benchmarks
PROF = prof

CC = x86_64-rumprun-netbsd-gcc

CFLAGS = -O3 -Wall -fPIC -L/home/amytai/bespin/target/x86_64-bespin-none/release/build/rumpkernel-63e370a9b18c8151/out/./rumprun/rumprun-x86_64/../../obj-amd64-bespin/lib/libunwind/ -I. -D_REENTRANT -DOS_NETBSD -DLEVELDB_PLATFORM_POSIX -O2 -DNDEBUG
LDFLAGS = -lm -lpthread -lssmem
#VER_FLAGS = -D_GNU_SOURCE

MEASUREMENTS = 0

ifeq ($(VERSION),DEBUG) 
CFLAGS = -O0 -ggdb -Wall -g -fno-inline
VER_FLAGS += -DDEBUG
endif

UNAME := $(shell uname -n)

all: libssmem.a ssmem_test

default: ssmem_test

ssmem.o: $(SRC)/ssmem.c 
	$(CC) $(VER_FLAGS) -c $(SRC)/ssmem.c $(CFLAGS) -I./$(INCLUDE)

ifeq ($(MEASUREMENTS),1)
VER_FLAGS += -DDO_TIMINGS
MEASUREMENTS_FILES += measurements.o
endif

libssmem.a: ssmem.o $(INCLUDE)/ssmem.h $(MEASUREMENTS_FILES)
	@echo Archive name = libssmem.a
	ar -r libssmem.a ssmem.o $(MEASUREMENTS_FILES)
	rm -f *.o	

ssmem_test.o: $(SRC)/ssmem_test.c libssmem.a
	$(CC) $(VER_FLAGS) -c $(SRC)/ssmem_test.c $(CFLAGS) -I./$(INCLUDE)

ssmem_test: libssmem.a ssmem_test.o
	$(CC) $(VER_FLAGS) -o ssmem_test ssmem_test.o $(CFLAGS) $(LDFLAGS) -I./$(INCLUDE) -L./ 


clean:
	rm -f *.o *.a ssmem_test
