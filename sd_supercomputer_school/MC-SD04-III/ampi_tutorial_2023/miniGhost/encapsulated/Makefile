#@header
# ************************************************************************
#
#      miniGhost: stencil computations with boundary exchange.
#              Copyright (2012) sandia corporation
#
# Under terms of Contract DE-AC04-94AL85000, there is a non-exclusive
# license for use of this work by or on behalf of the U.S. Government.
#
# This library is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 2.1 of the
# License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
# USA
# Questions? Contact Richard F. Barrett (rfbarre@sandia.gov) or
#                    Michael A. Heroux (maherou@sandia.gov)
#
# ************************************************************************
#@header

# Simple hand-tuned makefile, configured for the gnu compiler and MPICH.
# Modify as necessary for your environment.

#-----------------------------------------------------------------------

# Option: -D_MG_SERIAL
PROTOCOL = -D_MG_MPI

# Option: Select a compiler - pgi, gnu, intel, cray
COMPILER_SUITE=gnu

# Option: Select checkpoint methods to include
### Compile to include MPI-IO checkpointing capability.
ENABLE_CHECKPT_MPIIO=FALSE
### Compile to include the H5Part checkpointing capability.
### This feature requires the HDF5 library with parallel features enabled (hdf5-parallel module).
### This feature requires the H5Part library with parallel features enabled.
ENABLE_CHECKPT_H5PART=FALSE
### This is the root of the H5Part library installation.
H5PART_PATH=/home/thkorde/projects/mantevo/install/$(COMPILER_SUITE)

# Compilers
#FC=mpif90
FC=ftn
#CC=mpicc
CC=cc

CFLAGS = $(PROTOCOL)
# C main calling Fortran subroutine:
CFLAGS += -Df2c_

FFLAGS = $(PROTOCOL)
F_INCLUDE=

# Variable precision: -D_INT8 and/or -D_REAL8.
FFLAGS += -D_MG_INT4 -D_MG_REAL8

################################################################################
## Setup Checkpoint Features
################################################################################
ifeq ($(ENABLE_CHECKPT_MPIIO),TRUE)
FFLAGS += -D_MG_CHECKPT_MPIIO
endif

ifeq ($(ENABLE_CHECKPT_H5PART),TRUE)
FFLAGS += -D_MG_CHECKPT_H5PART
H5PART_INCLUDES += -I$(H5PART_PATH)/include
H5PART_LIBS += -L$(H5PART_PATH)/lib -lH5PartF -lhdf5 -ldl -lz -lm
endif
################################################################################

################################################################################
## Setup option specific to the PGI compiler
################################################################################
ifeq ($(COMPILER_SUITE),pgi)

# Optimization
OPT_F = -fast -fastsse
#OPT_F = -g

FFLAGS += $(OPT_F)
# Free-form Fortran source code:
FFLAGS += -Mfree
# Array bounds checking: (expensive!)
#FFLAGS += -Mbounds

endif
################################################################################

################################################################################
## Setup option specific to the GNU compiler
################################################################################
ifeq ($(COMPILER_SUITE),gnu)

# Optimization
OPT_F = -O3

FFLAGS += $(OPT_F)
# Free-form Fortran source code:
FFLAGS += -ffree-form -ffree-line-length-none
# Array bounds checking: (expensive!)
#FFLAGS += -fbounds-check

endif
################################################################################

################################################################################
## Setup option specific to the Intel compiler
################################################################################
ifeq ($(COMPILER_SUITE),intel)

# Optimization
OPT_F = -O3
#OPT_F = -g

FFLAGS += $(OPT_F)
# Free-form Fortran source code:
FFLAGS += -free
# Array bounds checking: (expensive!)
#FFLAGS += -check bounds

endif
################################################################################

################################################################################
## Setup option specific to the Cray compiler
################################################################################
ifeq ($(COMPILER_SUITE),cray)

# Optimization
OPT_F = -O3
#OPT_F = -g

FFLAGS += $(OPT_F)
# Free-form Fortran source code:
FFLAGS += -ffree
# Array bounds checking: (expensive!)
#FFLAGS += -Mbounds

# The Cray Fortran compiler processes modules differently than the rest.
# The compiler searches .a files for module definitions, so the lib directory
# is also an include directory.  Add the modules library to the list of libs.
H5PART_INCLUDES+=-I$(H5PART_PATH)/lib
H5PART_LIBS+=-L$(H5PART_PATH)/lib -lH5PartModules

endif
################################################################################

F_INCLUDE=$(H5PART_INCLUDES)

LD=$(CC)
LDFLAGS=$(CFLAGS)
LIBS=$(H5PART_LIBS)

include make_targets

# End makefile
