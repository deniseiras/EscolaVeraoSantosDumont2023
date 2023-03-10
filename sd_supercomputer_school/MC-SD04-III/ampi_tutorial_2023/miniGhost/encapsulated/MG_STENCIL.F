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

MODULE MG_STENCIL_MOD

   ! Purpose
   ! =======
   ! Selection of the appropriate stencil computation on the input variable.

   USE MG_UTILS_MOD
   USE MG_BOUNDARY_CONDITIONS_MOD
   USE MG_STENCIL_COMPS_MOD

   IMPLICIT NONE

CONTAINS
   
   SUBROUTINE MG_STENCIL ( MG, GRID, IVAR, IERR )

      ! ---------------------
      ! Argument Declarations
      ! ---------------------

      TYPE(MG_GLOBALS), INTENT(INOUT) :: MG

      INTEGER(KIND=MG_INT), INTENT(IN) :: &
         IVAR           ! Pointer to variable to be updated.

      REAL(KIND=MG_REAL), DIMENSION(0:NX+1, 0:NY+1, 0:NZ+1), INTENT(INOUT) :: &
         GRID

      INTEGER(KIND=MG_INT), INTENT(OUT) :: &
         IERR           ! Return status

      ! ------------------
      ! Local Declarations
      ! ------------------

      ! ---------------------
      ! Executable Statements
      ! ---------------------
   
      IERR = 0

      CALL MG_BOUNDARY_CONDITIONS ( MG, GRID(0,0,0), IVAR, IERR )

      SELECT CASE ( STENCIL )  

         CASE ( STENCIL_3D7PT )

            CALL MG_STENCIL_3D7PT ( MG, GRID(0,0,0), IERR )

         CASE ( STENCIL_3D27PT )

            CALL MG_STENCIL_3D27PT ( MG, GRID(0,0,0), IERR )

         CASE ( STENCIL_2D5PT )

            CALL MG_STENCIL_2D5PT ( MG, GRID(0,0,0), IERR )

         CASE ( STENCIL_2D9PT )

            CALL MG_STENCIL_2D9PT ( MG, GRID(0,0,0), IERR )

         CASE DEFAULT

            WRITE(*,*) ' ** Error ** MG_STENCIL: Unknown STENCIL = ', STENCIL
            IERR = -1

      END SELECT

   END SUBROUTINE MG_STENCIL

END MODULE MG_STENCIL_MOD
