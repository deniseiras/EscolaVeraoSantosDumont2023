CC = icc
# original CFLAGS = -qopt-report=5 -no-vec -qopenmp -xHost -Wall -Wextra
#
# alteracoes prof:
CFLAGS = -qopt-report=5 -no-vec -qopenmp -xHost -Wall -Wextra -qopt-zmm-usage=high


# module load intel_psxe/2019

OBJSUM := $(patsubst %.c,%.o,$(wildcard src/*.c))
OBJSUMF := $(patsubst %.c,%.exec,$(wildcard src/*.c))

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

all: main.o dot
	@echo "Compiled!"
	mv src/*.exec .

%.exec: %.o
	$(CC) $(CFLAGS) -o $@ $< main.o

dot: $(OBJSUMF)

clean:
	rm -rf main.o $(SCRATCH)/*.exec *.optrpt src/*.optrpt $(OBJSUM) $(OBJSUMF)
