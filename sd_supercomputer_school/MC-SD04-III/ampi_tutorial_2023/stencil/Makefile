CHARMDIR=/home/meneses/charm-v7.0.0/bin
CHARMC=$(CHARMDIR)/ampicxx $(OPTS)

all: stencil

# Notice that we link in the module of the load balancer we want to use, GreedyLB
# We could add additional load balancers by adding more -module LBName flags to the link line,
# or link with -module EveryLB to make all load balancers available.
#
# This is also where we specify the use of isomalloc to migrate the heap, so we don't need to write
# PUP functions.
stencil: stencil.cc
	$(CHARMC) -c stencil.cc
	$(CHARMC) -o stencil stencil.o -language ampi -module GreedyLB -memory isomalloc

# At runtime, we can choose from any load balancer that was linked in using +balancer LBName
# Note that on Turing, you should use rjq instead of calling charmrun directly.
test: stencil 
	./charmrun stencil +p4 +vp32 +balancer GreedyLB
	-./charmrun stencil +p4 +vp32

clean:
	rm -f *.o stencil charmrun 
