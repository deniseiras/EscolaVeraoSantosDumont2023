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

MPI_LOC = $(HOME)/Desktop/HomeDir/PARALLEL/MPI/mpich-3.0.2/src/
MPI_INCLUDE = -I$(MPI_LOC)/include

# State precision: -D_REAL4 and/or -D_REAL8.
REAL_PRECISION = -D_MG_REAL8
# Integer precision: -D_INT4 and/or -D_INT8.
INT_PRECISION = -D_MG_INT4

# Compilers
FC=$(MPI_LOC)/env/mpif90
CC=$(MPI_LOC)/env/mpicc

CFLAGS = $(PROTOCOL) $(REAL_PRECISION) $(INT_PRECISION)
# C main calling Fortran subroutine:
CFLAGS += -Df2c_
CFLAGS += $(MPI_INCLUDE)

FFLAGS = $(PROTOCOL) $(REAL_PRECISION) $(INT_PRECISION)

# Optimization
OPT_F = -O3

FFLAGS += $(OPT_F)
FFLAGS += $(MPI_INCLUDE)
# Free-form Fortran source code:
FFLAGS += -ffree-form
# Array bounds checking: (expensive!)
#FFLAGS += -fbounds-check
# Compile to include checkpointing capability.
#FFLAGS += -D_MG_CHECKPT

LD=$(CC)
LDFLAGS=$(CFLAGS) $(FFLAGS)
LIBS=

include make_targets

# End makefile
