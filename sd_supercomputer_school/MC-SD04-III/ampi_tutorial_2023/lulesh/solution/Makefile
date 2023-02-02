.SUFFIXES: .cc .o

LULESH_EXEC = lulesh
LULESH_EXEC_SER = $(LULESH_EXEC)_ser
#LULESH_EXEC_MPI = $(LULESH_EXEC)_mpi
LULESH_EXEC_AMPI = $(LULESH_EXEC)_ampi

# TODO: change this to point to your Charm++/AMPI build:
CHARM_DIR = /Users/emeneses/Desktop/charm-6.9.0
ifeq (,$(wildcard $(CHARM_DIR)))
  CHARM_DIR = ~/tutorial/charm
endif
ifeq (,$(wildcard $(CHARM_DIR)))
  CHARM_DIR = ~/charm
endif
CHARMBASE = $(CHARM_DIR)/bin

# For load balancing:
AMPI_LB = -module CommonLBs -memory isomalloc

# For Projections tracing:
#AMPI_PROJ = -tracemode projections
AMPI_PROJ =

SERCXX = c++ -DUSE_MPI=0 -g -O2
#MPICXX = mpicxx -g -O2 -DUSE_MPI=1 -D_OPENMP=0
#MPICXX = CC -g -O2 -DUSE_MPI=1 -D_OPENMP=0 # For Cray systems
AMPICXX = ${CHARMBASE}/ampicxx -g -O2 -DUSE_MPI=1 -D_OPENMP=0 ${AMPI_LB} ${AMPI_PROJ}

SOURCES = $(wildcard *.cc)
HEADERS = $(wildcard *.h)

OBJECTS_SER = $(SOURCES:.cc=_ser.o)
#OBJECTS_MPI = $(SOURCES:.cc=_mpi.o)
OBJECTS_AMPI = $(SOURCES:.cc=_ampi.o)

%_ser.o: %.cc $(HEADERS)
	$(SERCXX) -c $(CXXFLAGS) -o $@  $<

#%_mpi.o: %.cc $(HEADERS)
#	$(MPICXX) -c $(CXXFLAGS) -o $@  $<

%_ampi.o: %.cc $(HEADERS)
	$(AMPICXX) -c $(CXXFLAGS) -o $@  $<

#all: $(LULESH_EXEC_SER) $(LULESH_EXEC_MPI) $(LULESH_EXEC_AMPI)
all: $(LULESH_EXEC_SER) $(LULESH_EXEC_AMPI)

$(LULESH_EXEC_SER): $(OBJECTS_SER)
	$(SERCXX) $(OBJECTS_SER) $(LDFLAGS) -lm -o $@

#$(LULESH_EXEC_MPI): $(OBJECTS_MPI)
#	$(MPICXX) $(OBJECTS_MPI) $(LDFLAGS) -lm -o $@

$(LULESH_EXEC_AMPI): $(OBJECTS_AMPI)
	$(AMPICXX) $(OBJECTS_AMPI) $(LDFLAGS) -lm -o $@

clean:
	rm -rf *.o *~ $(LULESH_EXEC_SER) $(LULESH_EXEC_MPI) $(LULESH_EXEC_AMPI) *.dSYM charmrun

test: all
	./charmrun ++local ./$(LULESH_EXEC_AMPI) +p2 +vp8 -s 5 -p -b 3 -c 50 +balancer RotateLB +LBDebug 1 +isomalloc_sync
