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

MODULE MG_BSPMA_DIAGS_MOD

   ! BSPMA boundary exchange for 9- and 27-point stencils:    
   !    pack, send, receive, unpack.
   ! Coordinated exchange capturing diagonal elements in usual exchange.
   ! Called from DRIVER_BSPMA.

   USE MG_CONSTANTS_MOD
   USE MG_UTILS_MOD
   USE MG_IRECV_MOD
   USE MG_PACK_MOD
   USE MG_SEND_BSPMA_MOD
   USE MG_UNPACK_BSPMA_MOD

   IMPLICIT NONE

CONTAINS
   
   SUBROUTINE MG_BSPMA_DIAGS ( MG, GRID, IERR )
   
      ! ---------------------
      ! Argument Declarations
      ! ---------------------

      TYPE(MG_GLOBALS), INTENT(INOUT) :: MG

      INTEGER, INTENT(OUT) :: &
         IERR           ! Return status

      REAL(KIND=MG_REAL), DIMENSION(0:NX+1, 0:NY+1, 0:NZ+1, 1:NVARS), INTENT(INOUT) :: &
         GRID

      ! ------------------
      ! Local Declarations
      ! ------------------

      INTEGER :: &
         I, IVAR,     & ! Counters
         DIR(3)         ! Boundary exchange directions
   
      ! ---------------------
      ! Executable Statements
      ! ---------------------

      IERR = 0

      MG%COUNT_SEND_NORTH = 0
      MG%COUNT_SEND_SOUTH = 0
      MG%COUNT_SEND_EAST  = 0
      MG%COUNT_SEND_WEST  = 0
      MG%COUNT_SEND_BACK  = 0
      MG%COUNT_SEND_FRONT = 0

      DIR(1) = DIR_NORTH_SOUTH
      DIR(2) = DIR_EAST_WEST
      DIR(3) = DIR_BACK_FRONT

      DO I = 1, 3

         ! Set only those neighbors participating in this iterative loop.
         MG%NEIGHBORS = -1
         SELECT CASE ( DIR(I) )
            CASE ( DIR_NORTH_SOUTH )
               MG%NEIGHBORS(NORTH) = MG%NEIGHBORS_ORIG(NORTH)
               MG%NEIGHBORS(SOUTH) = MG%NEIGHBORS_ORIG(SOUTH)
            CASE ( DIR_EAST_WEST )
               MG%NEIGHBORS(EAST) = MG%NEIGHBORS_ORIG(EAST)
               MG%NEIGHBORS(WEST) = MG%NEIGHBORS_ORIG(WEST)
            CASE ( DIR_BACK_FRONT )
               MG%NEIGHBORS(BACK)  = MG%NEIGHBORS_ORIG(BACK)
               MG%NEIGHBORS(FRONT) = MG%NEIGHBORS_ORIG(FRONT)
         END SELECT

         CALL MG_IRECV ( MG, IERR )

         DO IVAR = 1, NVARS
            CALL MG_PACK ( MG, GRID(0,0,0,IVAR),  IERR )
         END DO
 
         CALL MG_SEND_BSPMA ( MG, IERR )
   
         CALL MG_UNPACK_BSPMA ( MG, GRID, IERR )

      END DO ! Loop over DIR

      MG%NEIGHBORS(NORTH) = MG%NEIGHBORS_ORIG(NORTH)
      MG%NEIGHBORS(SOUTH) = MG%NEIGHBORS_ORIG(SOUTH)
      MG%NEIGHBORS(EAST)  = MG%NEIGHBORS_ORIG(EAST)
      MG%NEIGHBORS(WEST)  = MG%NEIGHBORS_ORIG(WEST)
      MG%NEIGHBORS(FRONT) = MG%NEIGHBORS_ORIG(FRONT)
      MG%NEIGHBORS(BACK)  = MG%NEIGHBORS_ORIG(BACK)

   END SUBROUTINE MG_BSPMA_DIAGS
      
END MODULE MG_BSPMA_DIAGS_MOD
