! ************************************************************************
!
!               miniGhost: stencil computations with boundary exchange.
!                 Copyright (2012) Sandia Corporation
!
! Under terms of Contract DE-AC04-94AL85000, there is a non-exclusive
! license for use of this work by or on behalf of the U.S. Government.
!
! This library is free software; you can redistribute it and/or modify
! it under the terms of the GNU Lesser General Public License as
! published by the Free Software Foundation; either version 2.1 of the
! License, or (at your option) any later version.
!
! This library is distributed in the hope that it will be useful, but
! WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
! Lesser General Public License for more details.
!
! You should have received a copy of the GNU Lesser General Public
! License along with this library; if not, write to the Free Software
! Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
! USA
! Questions? Contact Richard F. Barrett (rfbarre@sandia.gov) or
!                    Michael A. Heroux (maherou@sandia.gov)
!
! ************************************************************************

MODULE MG_IRECV_MOD

   ! Purpose
   ! =======
   ! Receiving of neighbor boundary data using MPI non-blocking functionality.

   USE MG_CONSTANTS_MOD
   USE MG_UTILS_MOD
   USE MG_PROFILING_MOD

   IMPLICIT NONE

CONTAINS
   
   SUBROUTINE MG_IRECV ( MG, IERR )
   
      ! ---------------------
      ! Argument Declarations
      ! ---------------------

      TYPE(MG_GLOBALS), INTENT(INOUT) :: MG

      INTEGER, INTENT(OUT) :: &
         IERR           ! Return status

      ! ------------------
      ! Local Declarations
      ! ------------------

      REAL(KIND=MG_REAL8) ::      &
         TIME_START,              &
         TIME_START_DIR

      ! ---------------------
      ! Executable Statements
      ! ---------------------
   
      IERR = 0

      IF ( NUMPES == 1 ) &
         RETURN

#if defined _MG_MPI

      TIME_START = MG_TIMER()

      ! --------------
      ! Post receives:
      ! --------------

      MG%NUM_RECVS = 0

      MG%COUNT_RECV_NORTH = MG%RECV_BUFFER_NORTH_SIZE
      MG%COUNT_RECV_SOUTH = MG%RECV_BUFFER_SOUTH_SIZE
      MG%COUNT_RECV_EAST  = MG%RECV_BUFFER_EAST_SIZE
      MG%COUNT_RECV_WEST  = MG%RECV_BUFFER_WEST_SIZE
      MG%COUNT_RECV_BACK  = MG%RECV_BUFFER_BACK_SIZE
      MG%COUNT_RECV_FRONT = MG%RECV_BUFFER_FRONT_SIZE

      ! Back boundary
   
      IF ( MG%NEIGHBORS(BACK) /= -1 ) THEN

         TIME_START_DIR = MG_TIMER ()
         MG%NUM_RECVS = MG%NUM_RECVS + 1
         CALL MPI_IRECV ( MG%RECV_BUFFER_BACK, MG%COUNT_RECV_BACK, MG_MPI_REAL, &
                          MG%NEIGHBORS(BACK), MG%MSG_TAGS(FRONT),              &
                          MPI_COMM_MG, MG%MSG_REQS(BACK), IERR )
         MG_PERF%TIME_RECV_Z_PE = MG_PERF%TIME_RECV_Z_PE + MG_TIMER () - &
                                  TIME_START_DIR

         MG_PERF%RECV_COUNT  = MG_PERF%RECV_COUNT + MG%COUNT_RECV_BACK
         IF ( MG%COUNT_RECV_BACK > MG_PERF%RECV_COUNT_MAX ) THEN
            MG_PERF%RECV_COUNT_MAX = MG%COUNT_RECV_BACK
         END IF
         IF ( MG%COUNT_RECV_BACK < MG_PERF%RECV_COUNT_MIN ) THEN
            MG_PERF%RECV_COUNT_MIN = MG%COUNT_RECV_BACK
         END IF

      END IF
   
      ! Front boundary
   
      IF ( MG%NEIGHBORS(FRONT) /= -1 ) THEN

         TIME_START_DIR = MG_TIMER ()
         MG%NUM_RECVS = MG%NUM_RECVS + 1
         CALL MPI_IRECV ( MG%RECV_BUFFER_FRONT, MG%COUNT_RECV_FRONT, MG_MPI_REAL,   &
                          MG%NEIGHBORS(FRONT), MG%MSG_TAGS(BACK),                &
                          MPI_COMM_MG, MG%MSG_REQS(FRONT), IERR )
         MG_PERF%TIME_RECV_Z_PE = MG_PERF%TIME_RECV_Z_PE + MG_TIMER () - &
                                  TIME_START_DIR

         MG_PERF%RECV_COUNT  = MG_PERF%RECV_COUNT + MG%COUNT_RECV_FRONT
         IF ( MG%COUNT_RECV_FRONT > MG_PERF%RECV_COUNT_MAX ) THEN
            MG_PERF%RECV_COUNT_MAX = MG%COUNT_RECV_FRONT
         END IF
         IF ( MG%COUNT_RECV_FRONT < MG_PERF%RECV_COUNT_MIN ) THEN
            MG_PERF%RECV_COUNT_MIN = MG%COUNT_RECV_FRONT
         END IF

      END IF
   
      ! East boundary
   
      IF ( MG%NEIGHBORS(EAST) /= -1 ) THEN

         TIME_START_DIR = MG_TIMER ()
         MG%NUM_RECVS = MG%NUM_RECVS + 1
         CALL MPI_IRECV ( MG%RECV_BUFFER_EAST, MG%COUNT_RECV_EAST, MG_MPI_REAL, &
                          MG%NEIGHBORS(EAST), MG%MSG_TAGS(WEST),              &
                          MPI_COMM_MG, MG%MSG_REQS(EAST), IERR )
         MG_PERF%TIME_RECV_X_PE = MG_PERF%TIME_RECV_X_PE + MG_TIMER () - &
                                  TIME_START_DIR

         MG_PERF%RECV_COUNT  = MG_PERF%RECV_COUNT + MG%COUNT_RECV_EAST
         IF ( MG%COUNT_RECV_EAST > MG_PERF%RECV_COUNT_MAX ) THEN
            MG_PERF%RECV_COUNT_MAX = MG%COUNT_RECV_EAST
         END IF
         IF ( MG%COUNT_RECV_EAST < MG_PERF%RECV_COUNT_MIN ) THEN
            MG_PERF%RECV_COUNT_MIN = MG%COUNT_RECV_EAST
         END IF

      END IF
   
      ! West boundary
   
      IF ( MG%NEIGHBORS(WEST) /= -1 ) THEN

         TIME_START_DIR = MG_TIMER ()
         MG%NUM_RECVS = MG%NUM_RECVS + 1
         CALL MPI_IRECV ( MG%RECV_BUFFER_WEST, MG%COUNT_RECV_WEST, MG_MPI_REAL, &
                          MG%NEIGHBORS(WEST), MG%MSG_TAGS(EAST),                &
                          MPI_COMM_MG, MG%MSG_REQS(WEST), IERR )
         MG_PERF%TIME_RECV_X_PE = MG_PERF%TIME_RECV_X_PE + MG_TIMER () - &
                                  TIME_START_DIR

         MG_PERF%RECV_COUNT  = MG_PERF%RECV_COUNT + MG%COUNT_RECV_WEST
         IF ( MG%COUNT_RECV_WEST > MG_PERF%RECV_COUNT_MAX ) THEN
            MG_PERF%RECV_COUNT_MAX = MG%COUNT_RECV_WEST
         END IF
         IF ( MG%COUNT_RECV_WEST < MG_PERF%RECV_COUNT_MIN ) THEN
            MG_PERF%RECV_COUNT_MIN = MG%COUNT_RECV_WEST
         END IF

      END IF
   
      ! North boundary
   
      IF ( MG%NEIGHBORS(NORTH) /= -1 ) THEN

         TIME_START_DIR = MG_TIMER ()
         MG%NUM_RECVS = MG%NUM_RECVS + 1
         CALL MPI_IRECV ( MG%RECV_BUFFER_NORTH, MG%COUNT_RECV_NORTH, MG_MPI_REAL,   &
                          MG%NEIGHBORS(NORTH), MG%MSG_TAGS(SOUTH),                &
                          MPI_COMM_MG, MG%MSG_REQS(NORTH), IERR )
         MG_PERF%TIME_RECV_Y_PE = MG_PERF%TIME_RECV_Y_PE + MG_TIMER () - &
                                  TIME_START_DIR

         MG_PERF%RECV_COUNT  = MG_PERF%RECV_COUNT + MG%COUNT_RECV_NORTH
         IF ( MG%COUNT_RECV_NORTH > MG_PERF%RECV_COUNT_MAX ) THEN
            MG_PERF%RECV_COUNT_MAX = MG%COUNT_RECV_NORTH
         END IF
         IF ( MG%COUNT_RECV_NORTH < MG_PERF%RECV_COUNT_MIN ) THEN
            MG_PERF%RECV_COUNT_MIN = MG%COUNT_RECV_NORTH
         END IF

      END IF
   
      ! South boundary
   
      IF ( MG%NEIGHBORS(SOUTH) /= -1 ) THEN

         TIME_START_DIR = MG_TIMER ()
         MG%NUM_RECVS = MG%NUM_RECVS + 1
         CALL MPI_IRECV ( MG%RECV_BUFFER_SOUTH, MG%COUNT_RECV_SOUTH, MG_MPI_REAL, &
                          MG%NEIGHBORS(SOUTH), MG%MSG_TAGS(NORTH),                &
                          MPI_COMM_MG, MG%MSG_REQS(SOUTH), IERR )
         MG_PERF%TIME_RECV_Y_PE = MG_PERF%TIME_RECV_Y_PE + MG_TIMER () - &
                                  TIME_START_DIR

         MG_PERF%RECV_COUNT  = MG_PERF%RECV_COUNT + MG%COUNT_RECV_SOUTH
         IF ( MG%COUNT_RECV_SOUTH > MG_PERF%RECV_COUNT_MAX ) THEN
            MG_PERF%RECV_COUNT_MAX = MG%COUNT_RECV_SOUTH
         END IF
         IF ( MG%COUNT_RECV_SOUTH < MG_PERF%RECV_COUNT_MIN ) THEN
            MG_PERF%RECV_COUNT_MIN = MG%COUNT_RECV_SOUTH
         END IF

      END IF

      MG_PERF%TIME_RECV_PE = MG_PERF%TIME_RECV_PE + MG_TIMER() - TIME_START

      MG_PERF%NUM_RECVS = MG_PERF%NUM_RECVS + MG%NUM_RECVS

#endif

      RETURN

   END SUBROUTINE MG_IRECV
   
END MODULE MG_IRECV_MOD
