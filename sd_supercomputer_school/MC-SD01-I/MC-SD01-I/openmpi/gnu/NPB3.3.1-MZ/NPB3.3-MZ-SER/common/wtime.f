C
C  Note: currently (NPB2.3), this routine not called 
C
      subroutine wtime(tim)
      real*8 tim
      dimension tarray(2)
      call etime(tarray)
      tim = tarray(1)
      return
      end





