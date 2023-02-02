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

MODULE MG_BUFINIT_MOD

   ! Purpose
   ! =======
   ! Driver for selecting buffer requirements based on communication 
   ! strategy and other choices.
   ! Called from DRIVER.

   USE MG_CONSTANTS_MOD
   USE MG_UTILS_MOD

   IMPLICIT NONE

CONTAINS
   
   SUBROUTINE MG_BUFINIT ( MG, IERR )
   
      USE MG_CONSTANTS_MOD

      ! ----------------------------------------------------------------
      ! Pack boundary data into send buffer for subsequent transmission.
      ! ----------------------------------------------------------------

      ! ---------------------
      ! Argument Declarations
      ! ---------------------

      TYPE(MG_GLOBALS), INTENT(INOUT) :: MG

      INTEGER, INTENT(OUT) :: &
         IERR           ! Return status

      ! ------------------
      ! Local Declarations
      ! ------------------

      INTEGER :: &
         I                      ! Counter

      REAL :: &
         NUM,               &  ! Tmp random number.
         PERCENT_SUM_REAL      ! Requested percentage of GRIDS_TO_SUM
   
      ! ---------------------
      ! Executable Statements
      ! ---------------------

      IERR = 0

      ! ---------------------------
      ! Reduction sum across GRIDs.
      ! ---------------------------

      ALLOCATE ( MG%GRIDS_TO_SUM(NVARS), STAT=IERR )
      CALL MG_ASSERT ( IERR, 'MG_BUFINFO: ALLOCATE(GRIDS_TO_SUM)', NVARS )

      IF ( DEBUG_GRID == 1 ) THEN
         PERCENT_SUM = 100 ! If we're checking, we're checking them all.
      END IF

      IF ( PERCENT_SUM == 100 ) THEN

         MG%GRIDS_TO_SUM = .TRUE.    ! Every GRID is summed.
         MG%NUM_SUM_GRID = NVARS

      ELSE IF ( PERCENT_SUM == 0 ) THEN

         MG%GRIDS_TO_SUM = .FALSE.   ! No GRIDs are summed.
         MG%NUM_SUM_GRID = 0

      ELSE

         PERCENT_SUM_REAL = REAL(PERCENT_SUM) / 100.0
         MG%NUM_SUM_GRID = 0

         CALL MG_RANDOM_SEED ( IERR )

         DO I = 1, NVARS
            CALL RANDOM_NUMBER ( NUM )
            IF ( NUM < PERCENT_SUM ) THEN
               MG%GRIDS_TO_SUM(I) = .TRUE.
               MG%NUM_SUM_GRID = MG%NUM_SUM_GRID + 1
            ELSE
               MG%GRIDS_TO_SUM(I) = .FALSE.
            END IF
         END DO

      END IF

      ALLOCATE ( MG%FLUX_OUT(NVARS), STAT=IERR )
      CALL MG_ASSERT ( IERR, 'MG_BUFINFO: ALLOCATE(FLUX_OUT)', NVARS )
      MG%FLUX_OUT = 0.0

      IF ( NUMPES == 1 ) &
         RETURN

#if defined _MG_MPI

      SELECT CASE ( COMM_METHOD )

         CASE ( COMM_METHOD_BSPMA )

            CALL MG_BUF_BSPMA ( MG, IERR )

         CASE ( COMM_METHOD_SVAF )

            CALL MG_BUF_SVAF ( MG, IERR )

         CASE DEFAULT

            CALL MG_ASSERT ( -1, 'MG_BUFINIT: Unknown COMM_METHOD', COMM_METHOD )

      END SELECT

      ! -----------------
      ! Set message tags.
      ! -----------------

      ALLOCATE ( MG%MSG_TAGS(MAX_NUM_NEIGHBORS), STAT = IERR )
      CALL MG_ASSERT ( IERR, 'MG_BUFINFO: ALLOCATE(MSG_TAGS)', MAX_NUM_NEIGHBORS )

      MG%MSG_TAGS(NORTH) = 1000
      MG%MSG_TAGS(SOUTH) = 2000
      MG%MSG_TAGS(EAST)  = 3000
      MG%MSG_TAGS(WEST)  = 4000
      MG%MSG_TAGS(BACK)  = 5000
      MG%MSG_TAGS(FRONT) = 6000

      ! -----------------------------
      ! Set msg request handle space.
      ! -----------------------------

      ALLOCATE ( MG%MSG_REQS(MG%MAX_NUM_SENDS+MG%MAX_NUM_RECVS), STAT = IERR )
      CALL MG_ASSERT ( IERR, 'MG_BUFINFO: ALLOCATE(MSG_REQS)', &
                         MG%MAX_NUM_SENDS+MG%MAX_NUM_RECVS )

      MG%MSG_REQS(1:MG%MAX_NUM_SENDS+MG%MAX_NUM_RECVS) = MPI_REQUEST_NULL

#endif

      RETURN

   END SUBROUTINE MG_BUFINIT

!  ========================================================================================
   
   SUBROUTINE MG_BUF_BSPMA ( MG, IERR )
   
      ! -------------------------------
      ! Buffer space specific to BSPMA.
      ! -------------------------------

      ! ---------------------
      ! Argument Declarations
      ! ---------------------

      TYPE(MG_GLOBALS), INTENT(INOUT) :: MG

      INTEGER(KIND=MG_INT), INTENT(OUT) :: &
         IERR           ! Return status

      ! ------------------
      ! Local Declarations
      ! ------------------

      ! ---------------------
      ! Executable Statements
      ! ---------------------

      IERR = 0

      IF ( NUMPES == 1 ) &
         RETURN

      IF ( MG%NEIGHBORS(BACK) /= -1 ) THEN

         MG%SEND_BUFFER_BACK_SIZE = NVARS * (NX+2)*(NY+2)
         ALLOCATE ( MG%SEND_BUFFER_BACK( MG%SEND_BUFFER_BACK_SIZE ), STAT = IERR )
         CALL MG_ASSERT ( IERR, 'MG_BUF_BSPMA: SEND_BUFFER_BACK', MG%SEND_BUFFER_BACK_SIZE )

         MG%RECV_BUFFER_BACK_SIZE = NVARS * (NX+2)*(NY+2)
         ALLOCATE ( MG%RECV_BUFFER_BACK( MG%RECV_BUFFER_BACK_SIZE ), STAT = IERR )
         CALL MG_ASSERT ( IERR, 'MG_BUF_BSPMA: RECV_BUFFER_BACK', MG%RECV_BUFFER_BACK_SIZE )

      END IF

      IF ( MG%NEIGHBORS(FRONT) /= -1 ) THEN

         MG%SEND_BUFFER_FRONT_SIZE = NVARS * (NX+2)*(NY+2)
         ALLOCATE ( MG%SEND_BUFFER_FRONT( MG%SEND_BUFFER_FRONT_SIZE ), STAT = IERR )
         CALL MG_ASSERT ( IERR, 'MG_BUF_BSPMA: SEND_BUFFER_FRONT', MG%SEND_BUFFER_FRONT_SIZE )

         MG%RECV_BUFFER_FRONT_SIZE = NVARS * (NX+2)*(NY+2)
         ALLOCATE ( MG%RECV_BUFFER_FRONT( MG%RECV_BUFFER_FRONT_SIZE ), STAT = IERR )
         CALL MG_ASSERT ( IERR, 'MG_BUF_BSPMA: RECV_BUFFER_FRONT', MG%RECV_BUFFER_FRONT_SIZE )

      END IF

      IF ( MG%NEIGHBORS(EAST) /= -1 ) THEN

         MG%SEND_BUFFER_EAST_SIZE = NVARS * (NY+2)*(NZ+2)
         ALLOCATE ( MG%SEND_BUFFER_EAST( MG%SEND_BUFFER_EAST_SIZE ), STAT = IERR )
         CALL MG_ASSERT ( IERR, 'MG_BUF_BSPMA: SEND_BUFFER_EAST', MG%SEND_BUFFER_EAST_SIZE )

         MG%RECV_BUFFER_EAST_SIZE = NVARS * (NY+2)*(NZ+2)
         ALLOCATE ( MG%RECV_BUFFER_EAST( MG%RECV_BUFFER_EAST_SIZE ), STAT = IERR )
         CALL MG_ASSERT ( IERR, 'MG_BUF_BSPMA: RECV_BUFFER_EAST', MG%RECV_BUFFER_EAST_SIZE )

      END IF

      IF ( MG%NEIGHBORS(WEST) /= -1 ) THEN

         MG%SEND_BUFFER_WEST_SIZE = NVARS * (NY+2)*(NZ+2)
         ALLOCATE ( MG%SEND_BUFFER_WEST( MG%SEND_BUFFER_WEST_SIZE ), STAT = IERR )
         CALL MG_ASSERT ( IERR, 'MG_BUF_BSPMA: SEND_BUFFER_WEST', MG%SEND_BUFFER_WEST_SIZE )

         MG%RECV_BUFFER_WEST_SIZE = NVARS * (NY+2)*(NZ+2)
         ALLOCATE ( MG%RECV_BUFFER_WEST( MG%RECV_BUFFER_WEST_SIZE ), STAT = IERR )
         CALL MG_ASSERT ( IERR, 'MG_BUF_BSPMA: RECV_BUFFER_WEST', MG%RECV_BUFFER_WEST_SIZE )

      END IF

      IF ( MG%NEIGHBORS(NORTH) /= -1 ) THEN

         MG%SEND_BUFFER_NORTH_SIZE = NVARS * (NX+2)*(NZ+2)
         ALLOCATE ( MG%SEND_BUFFER_NORTH( MG%SEND_BUFFER_NORTH_SIZE ), STAT = IERR )
         CALL MG_ASSERT ( IERR, 'MG_BUF_BSPMA: SEND_BUFFER_NORTH', MG%SEND_BUFFER_NORTH_SIZE )

         MG%RECV_BUFFER_NORTH_SIZE = NVARS * (NX+2)*(NZ+2)
         ALLOCATE ( MG%RECV_BUFFER_NORTH( MG%RECV_BUFFER_NORTH_SIZE ), STAT = IERR )
         CALL MG_ASSERT ( IERR, 'MG_BUF_BSPMA: RECV_BUFFER_NORTH', MG%RECV_BUFFER_NORTH_SIZE )

      END IF

      IF ( MG%NEIGHBORS(SOUTH) /= -1 ) THEN

         MG%SEND_BUFFER_SOUTH_SIZE = NVARS * (NX+2)*(NZ+2)
         ALLOCATE ( MG%SEND_BUFFER_SOUTH( MG%SEND_BUFFER_SOUTH_SIZE ), STAT = IERR )
         CALL MG_ASSERT ( IERR, 'MG_BUF_BSPMA: SEND_BUFFER_SOUTH', MG%SEND_BUFFER_SOUTH_SIZE )

         MG%RECV_BUFFER_SOUTH_SIZE = NVARS * (NX+2)*(NZ+2)
         ALLOCATE ( MG%RECV_BUFFER_SOUTH( MG%RECV_BUFFER_SOUTH_SIZE ), STAT = IERR )
         CALL MG_ASSERT ( IERR, 'MG_BUF_BSPMA: RECV_BUFFER_SOUTH', MG%RECV_BUFFER_SOUTH_SIZE )

      END IF

      MG%MAX_NUM_SENDS = MAX_NUM_NEIGHBORS
      MG%MAX_NUM_RECVS = MAX_NUM_NEIGHBORS

      RETURN

   END SUBROUTINE MG_BUF_BSPMA

!  ========================================================================================
   
   SUBROUTINE MG_BUF_SVAF ( MG, IERR )
   
      ! -------------------------------
      ! Buffer space specific to BSPMA.
      ! -------------------------------

      ! ---------------------
      ! Argument Declarations
      ! ---------------------

      TYPE(MG_GLOBALS), INTENT(INOUT) :: MG

      INTEGER(KIND=MG_INT), INTENT(OUT) :: &
         IERR           ! Return status

      ! ------------------
      ! Local Declarations
      ! ------------------

      ! ---------------------
      ! Executable Statements
      ! ---------------------

      IERR = 0

      IF ( NUMPES == 1 ) &
         RETURN

      IF ( MG%NEIGHBORS(BACK) /= -1 ) THEN

         MG%SEND_BUFFER_BACK_SIZE = (NX+2)*(NY+2)
         ALLOCATE ( MG%SEND_BUFFER_BACK( MG%SEND_BUFFER_BACK_SIZE ), STAT = IERR )
         CALL MG_ASSERT ( IERR, 'MG_BUF_SVAF: SEND_BUFFER_BACK', MG%SEND_BUFFER_BACK_SIZE )

         MG%RECV_BUFFER_BACK_SIZE = (NX+2)*(NY+2)
         ALLOCATE ( MG%RECV_BUFFER_BACK( MG%RECV_BUFFER_BACK_SIZE ), STAT = IERR )
         CALL MG_ASSERT ( IERR, 'MG_BUF_SVAF: RECV_BUFFER_BACK', MG%RECV_BUFFER_BACK_SIZE )

      END IF

      IF ( MG%NEIGHBORS(FRONT) /= -1 ) THEN

         MG%SEND_BUFFER_FRONT_SIZE = (NX+2)*(NY+2)
         ALLOCATE ( MG%SEND_BUFFER_FRONT( MG%SEND_BUFFER_FRONT_SIZE ), STAT = IERR )
         CALL MG_ASSERT ( IERR, 'MG_BUF_SVAF: SEND_BUFFER_FRONT', MG%SEND_BUFFER_FRONT_SIZE )

         MG%RECV_BUFFER_FRONT_SIZE = (NX+2)*(NY+2)
         ALLOCATE ( MG%RECV_BUFFER_FRONT( MG%RECV_BUFFER_FRONT_SIZE ), STAT = IERR )
         CALL MG_ASSERT ( IERR, 'MG_BUF_SVAF: RECV_BUFFER_FRONT', MG%RECV_BUFFER_FRONT_SIZE )

      END IF

      IF ( MG%NEIGHBORS(EAST) /= -1 ) THEN

         MG%SEND_BUFFER_EAST_SIZE =  (NY+2)*(NZ+2)
         ALLOCATE ( MG%SEND_BUFFER_EAST( MG%SEND_BUFFER_EAST_SIZE ), STAT = IERR )
         CALL MG_ASSERT ( IERR, 'MG_BUF_SVAF: SEND_BUFFER_EAST', MG%SEND_BUFFER_EAST_SIZE )

         MG%RECV_BUFFER_EAST_SIZE =  (NY+2)*(NZ+2)
         ALLOCATE ( MG%RECV_BUFFER_EAST( MG%RECV_BUFFER_EAST_SIZE ), STAT = IERR )
         CALL MG_ASSERT ( IERR, 'MG_BUF_SVAF: RECV_BUFFER_EAST', MG%RECV_BUFFER_EAST_SIZE )

      END IF

      IF ( MG%NEIGHBORS(WEST) /= -1 ) THEN

         MG%SEND_BUFFER_WEST_SIZE =  (NY+2)*(NZ+2)
         ALLOCATE ( MG%SEND_BUFFER_WEST( MG%SEND_BUFFER_WEST_SIZE ), STAT = IERR )
         CALL MG_ASSERT ( IERR, 'MG_BUF_SVAF: SEND_BUFFER_WEST', MG%SEND_BUFFER_WEST_SIZE )

         MG%RECV_BUFFER_WEST_SIZE =  (NY+2)*(NZ+2)
         ALLOCATE ( MG%RECV_BUFFER_WEST( MG%RECV_BUFFER_WEST_SIZE ), STAT = IERR )
         CALL MG_ASSERT ( IERR, 'MG_BUF_SVAF: RECV_BUFFER_WEST', MG%RECV_BUFFER_WEST_SIZE )

      END IF

      IF ( MG%NEIGHBORS(NORTH) /= -1 ) THEN

         MG%SEND_BUFFER_NORTH_SIZE = (NX+2)*(NZ+2)
         ALLOCATE ( MG%SEND_BUFFER_NORTH( MG%SEND_BUFFER_NORTH_SIZE ), STAT = IERR )
         CALL MG_ASSERT ( IERR, 'MG_BUF_SVAF: SEND_BUFFER_NORTH', MG%SEND_BUFFER_NORTH_SIZE )

         MG%RECV_BUFFER_NORTH_SIZE = (NX+2)*(NZ+2)
         ALLOCATE ( MG%RECV_BUFFER_NORTH( MG%RECV_BUFFER_NORTH_SIZE ), STAT = IERR )
         CALL MG_ASSERT ( IERR, 'MG_BUF_SVAF: RECV_BUFFER_NORTH', MG%RECV_BUFFER_NORTH_SIZE )

      END IF

      IF ( MG%NEIGHBORS(SOUTH) /= -1 ) THEN

         MG%SEND_BUFFER_SOUTH_SIZE = (NX+2)*(NZ+2)
         ALLOCATE ( MG%SEND_BUFFER_SOUTH( MG%SEND_BUFFER_SOUTH_SIZE ), STAT = IERR )
         CALL MG_ASSERT ( IERR, 'MG_BUF_SVAF: SEND_BUFFER_SOUTH', MG%SEND_BUFFER_SOUTH_SIZE )

         MG%RECV_BUFFER_SOUTH_SIZE = (NX+2)*(NZ+2)
         ALLOCATE ( MG%RECV_BUFFER_SOUTH( MG%RECV_BUFFER_SOUTH_SIZE ), STAT = IERR )
         CALL MG_ASSERT ( IERR, 'MG_BUF_SVAF: RECV_BUFFER_SOUTH', MG%RECV_BUFFER_SOUTH_SIZE )

      END IF

      MG%MAX_NUM_SENDS = MAX_NUM_NEIGHBORS
      MG%MAX_NUM_RECVS = MAX_NUM_NEIGHBORS

      RETURN

   END SUBROUTINE MG_BUF_SVAF

!  ========================================================================================

END MODULE MG_BUFINIT_MOD

