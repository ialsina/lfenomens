C     IVAN ALSINA FERRER
      
      PROGRAM PROGRAM
      IMPLICIT NONE

      INTEGER*4 SEED, I, J, L, N
      PARAMETER(L=30)
      INTEGER*4 PBC(0:L+1)
      INTEGER*2 S(1:L,1:L)
      INTEGER*4 MCTOT, IMC
      INTEGER*2 SIMTAG
      REAL*8 GENRAND_REAL2, MAGN(2), MAGNE
      REAL*8 ENE(2),ENERG,ENEBIS
      REAL*8 TEMP
      REAL*8 W(-8:8)
      CHARACTER*32 NOM

      COMMON / VECS / W

      NOM = "SIM-L-030-TEMP-4500-MCTOT-10K-01"
      TEMP = 4.5D0
      MCTOT = 10000
      SEED = 234567
      SIMTAG = 1

      CALL INIT_GENRAND(SEED)

      N = L*L

      DO I=-8,8
            W(I) = DEXP(-DBLE(I)/TEMP)
      ENDDO

      DO I=1,L
            PBC(I) = I
      ENDDO
      PBC(0) = L
      PBC(L+1) = 1

      DO I=1,L
            DO J=1,L
                  IF (GENRAND_REAL2().LT.0.5D0) THEN
                        S(I,J) = 1
                  ELSE
                        S(I,J) = -1
                  ENDIF
            ENDDO
      ENDDO

      MAGN(1) = MAGNE(S,L)
      ENE(1) = ENERG(S,L,PBC)

      OPEN(UNIT=11,FILE=NOM//".evo")
      WRITE(11,*) "# L", L, "TEMP", TEMP, "MCTOT", MCTOT, "SEED", SEED
      WRITE(11,*) IMC, ENE(1), ENE(1), MAGN(1)

      IMC = 0
      DO I=1,MCTOT
            CALL PROPOSECHANGE(S,L,PBC,TEMP,I,11)
      ENDDO

      CLOSE(11)

      MAGN(2) = MAGNE(S,L)
      ENE(2) = ENERG(S,L,PBC)
      WRITE(*,*) "MAGNETITZACIONS", MAGN(1), MAGN(2)
      WRITE(*,*) "ENERGIES", ENE(1), ENE(2)
      WRITE(*,*) "ENERGIA MAXIMA", -2*N
      
      STOP
      END

      SUBROUTINE PROPOSECHANGE(S,L,PBC,TEMP,IMC,OU)
      IMPLICIT NONE
      INTEGER*4 L,I,J,IMC,PBC(0:L+1)
      INTEGER*2 S(1:L,1:L)
      INTEGER*4 OU
      REAL*8 GENRAND_REAL2, ENERG, MAGNE
      REAL*8 SUMA, DELTA, TEMP, ENE, DE, ENEBIS
      REAL*8 W(-8:8)

      COMMON / VECS / W

C     THIS CAN BE FURTHER OPTIMIZED WITH // AND MOD
      I = INT(GENRAND_REAL2()*L)+1
      J = INT(GENRAND_REAL2()*L)+1

      SUMA = S(I,PBC(J+1)) +S(I,PBC(J-1)) +S(PBC(I+1),J) +S(PBC(I-1),J)
      DE = 2*S(I,J)*SUMA

      ENE = ENERG(S,L,PBC)

      IF (DE.LE.0.D0) THEN
            S(I,J) = -S(I,J)
            ENE = ENE+DE
      ELSE
            DELTA = GENRAND_REAL2()
            IF (DELTA.LE.W(INT(DE))) THEN
                  S(I,J) = -S(I,J)
                  ENE = ENE+DE
            ENDIF
      ENDIF

      ENEBIS = ENERG(S,L,PBC)

      WRITE(OU,*) IMC, ENE, ENEBIS, MAGNE(S,L)

      RETURN
      END SUBROUTINE

      SUBROUTINE WRITECONFIG(S,L,FILENAME)
      IMPLICIT NONE
      INTEGER*4 L,I,J
      INTEGER*2 S(1:L,1:L)
      CHARACTER(LEN=*) :: FILENAME

      FILENAME = TRIM(FILENAME)
      IF (FILENAME.EQ."") THEN
            FILENAME = "Configuration"
      ENDIF

      OPEN(10,FILE=TRIM(FILENAME//".conf"))

      DO I=1,L
            DO J=1,L
                  IF (S(I,J).EQ.1) THEN
                        WRITE(10,101) I,J
                  ENDIF
            ENDDO
      ENDDO
 101  FORMAT(I5,1X,I5)
      END SUBROUTINE


      FUNCTION MAGNE(S,L)
      IMPLICIT NONE
      REAL*8 MAGNE
      INTEGER*4 L,I,J
      INTEGER*2 S(1:L,1:L)
      MAGNE = 0.D0
      DO I=1,L
            DO J=1,L
                  MAGNE = MAGNE+S(I,J)
            ENDDO
      ENDDO
      RETURN
      END FUNCTION


      FUNCTION ENERG(S,L,PBC)
      IMPLICIT NONE
      REAL*8 ENERG, ENE
      INTEGER*4 L,I,J
      INTEGER*2 S(1:L,1:L)
      INTEGER*4 PBC(0:L+1)
      ENE = 0.D0
      DO I=1,L
            DO J=1,L
                  ENE = ENE-S(I,J)*S(PBC(I+1),J)-S(I,J)*S(I,PBC(J+1))
            ENDDO
      ENDDO
      ENERG = ENE
      RETURN
      END FUNCTION





c##############################################################################################
c GIVEN SUBROUTINES
c##############################################################################################
c  A C-program for MT19937, with initialization improved 2002/1/26.
c  Coded by Takuji Nishimura and Makoto Matsumoto.
c
c  Before using, initialize the state by using init_genrand(seed)  
c  or init_by_array(init_key, key_length).
c
c  Copyright (C) 1997 - 2002, Makoto Matsumoto and Takuji Nishimura,
c  All rights reserved.                          
c  Copyright (C) 2005, Mutsuo Saito,
c  All rights reserved.                          
c
c  Redistribution and use in source and binary forms, with or without
c  modification, are permitted provided that the following conditions
c  are met:
c
c    1. Redistributions of source code must retain the above copyright
c       notice, this list of conditions and the following disclaimer.
c
c    2. Redistributions in binary form must reproduce the above copyright
c       notice, this list of conditions and the following disclaimer in the
c       documentation and/or other materials provided with the distribution.
c
c    3. The names of its contributors may not be used to endorse or promote 
c       products derived from this software without specific prior written 
c       permission.
c
c  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
c  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
c  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
c  A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
c  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
c  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
c  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
c  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
c  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
c  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
c  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
c
c
c  Any feedback is very welcome.
c  http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/emt.html
c  email: m-mat @ math.sci.hiroshima-u.ac.jp (remove space)
c
c-----------------------------------------------------------------------
c  FORTRAN77 translation by Tsuyoshi TADA. (2005/12/19)
c
c     ---------- initialize routines ----------
c  subroutine init_genrand(seed): initialize with a seed
c  subroutine init_by_array(init_key,key_length): initialize by an array
c
c     ---------- generate functions ----------
c  integer function genrand_int32(): signed 32-bit integer
c  integer function genrand_int31(): unsigned 31-bit integer
c  double precision function genrand_real1(): [0,1] with 32-bit resolution
c  double precision function genrand_real2(): [0,1) with 32-bit resolution
c  double precision function genrand_real3(): (0,1) with 32-bit resolution
c  double precision function genrand_res53(): (0,1) with 53-bit resolution
c
c  This program uses the following non-standard intrinsics.
c    ishft(i,n): If n>0, shifts bits in i by n positions to left.
c                If n<0, shifts bits in i by n positions to right.
c    iand (i,j): Performs logical AND on corresponding bits of i and j.
c    ior  (i,j): Performs inclusive OR on corresponding bits of i and j.
c    ieor (i,j): Performs exclusive OR on corresponding bits of i and j.
c
c-----------------------------------------------------------------------
c     initialize mt(0:N-1) with a seed
c-----------------------------------------------------------------------
      subroutine init_genrand(s)
      integer s
      integer N
      integer DONE
      integer ALLBIT_MASK
      parameter (N=624)
      parameter (DONE=123456789)
      integer mti,initialized
      integer mt(0:N-1)
      common /mt_state1/ mti,initialized
      common /mt_state2/ mt
      common /mt_mask1/ ALLBIT_MASK
c
      call mt_initln
      mt(0)=iand(s,ALLBIT_MASK)
      do 100 mti=1,N-1
        mt(mti)=1812433253*
     &          ieor(mt(mti-1),ishft(mt(mti-1),-30))+mti
        mt(mti)=iand(mt(mti),ALLBIT_MASK)
  100 continue
      initialized=DONE
c
      return
      end
c-----------------------------------------------------------------------
c     initialize by an array with array-length
c     init_key is the array for initializing keys
c     key_length is its length
c-----------------------------------------------------------------------
      subroutine init_by_array(init_key,key_length)
      integer init_key(0:*)
      integer key_length
      integer N
      integer ALLBIT_MASK
      integer TOPBIT_MASK
      parameter (N=624)
      integer i,j,k
      integer mt(0:N-1)
      common /mt_state2/ mt
      common /mt_mask1/ ALLBIT_MASK
      common /mt_mask2/ TOPBIT_MASK
c
      call init_genrand(19650218)
      i=1
      j=0
      do 100 k=max(N,key_length),1,-1
        mt(i)=ieor(mt(i),ieor(mt(i-1),ishft(mt(i-1),-30))*1664525)
     &           +init_key(j)+j
        mt(i)=iand(mt(i),ALLBIT_MASK)
        i=i+1
        j=j+1
        if(i.ge.N)then
          mt(0)=mt(N-1)
          i=1
        endif
        if(j.ge.key_length)then
          j=0
        endif
  100 continue
      do 200 k=N-1,1,-1
        mt(i)=ieor(mt(i),ieor(mt(i-1),ishft(mt(i-1),-30))*1566083941)-i
        mt(i)=iand(mt(i),ALLBIT_MASK)
        i=i+1
        if(i.ge.N)then
          mt(0)=mt(N-1)
          i=1
        endif
  200 continue
      mt(0)=TOPBIT_MASK
c
      return
      end
c-----------------------------------------------------------------------
c     generates a random number on [0,0xffffffff]-interval
c-----------------------------------------------------------------------
      function genrand_int32()
      integer genrand_int32
      integer N,M
      integer DONE
      integer UPPER_MASK,LOWER_MASK,MATRIX_A
      integer T1_MASK,T2_MASK
      parameter (N=624)
      parameter (M=397)
      parameter (DONE=123456789)
      integer mti,initialized
      integer mt(0:N-1)
      integer y,kk
      integer mag01(0:1)
      common /mt_state1/ mti,initialized
      common /mt_state2/ mt
      common /mt_mask3/ UPPER_MASK,LOWER_MASK,MATRIX_A,T1_MASK,T2_MASK
      common /mt_mag01/ mag01
c
      if(initialized.ne.DONE)then
        call init_genrand(21641)
      endif
c
      if(mti.ge.N)then
        do 100 kk=0,N-M-1
          y=ior(iand(mt(kk),UPPER_MASK),iand(mt(kk+1),LOWER_MASK))
          mt(kk)=ieor(ieor(mt(kk+M),ishft(y,-1)),mag01(iand(y,1)))
  100   continue
        do 200 kk=N-M,N-1-1
          y=ior(iand(mt(kk),UPPER_MASK),iand(mt(kk+1),LOWER_MASK))
          mt(kk)=ieor(ieor(mt(kk+(M-N)),ishft(y,-1)),mag01(iand(y,1)))
  200   continue
        y=ior(iand(mt(N-1),UPPER_MASK),iand(mt(0),LOWER_MASK))
        mt(kk)=ieor(ieor(mt(M-1),ishft(y,-1)),mag01(iand(y,1)))
        mti=0
      endif
c
      y=mt(mti)
      mti=mti+1
c
      y=ieor(y,ishft(y,-11))
      y=ieor(y,iand(ishft(y,7),T1_MASK))
      y=ieor(y,iand(ishft(y,15),T2_MASK))
      y=ieor(y,ishft(y,-18))
c
      genrand_int32=y
      return
      end
c-----------------------------------------------------------------------
c     generates a random number on [0,0x7fffffff]-interval
c-----------------------------------------------------------------------
      function genrand_int31()
      integer genrand_int31
      integer genrand_int32
      genrand_int31=int(ishft(genrand_int32(),-1))
      return
      end
c-----------------------------------------------------------------------
c     generates a random number on [0,1]-real-interval
c-----------------------------------------------------------------------
      function genrand_real1()
      double precision genrand_real1,r
      integer genrand_int32
      r=dble(genrand_int32())
      if(r.lt.0.d0)r=r+2.d0**32
      genrand_real1=r/4294967295.d0
      return
      end
c-----------------------------------------------------------------------
c     generates a random number on [0,1)-real-interval
c-----------------------------------------------------------------------
      function genrand_real2()
      double precision genrand_real2,r
      integer genrand_int32
      r=dble(genrand_int32())
      if(r.lt.0.d0)r=r+2.d0**32
      genrand_real2=r/4294967296.d0
      return
      end
c-----------------------------------------------------------------------
c     generates a random number on (0,1)-real-interval
c-----------------------------------------------------------------------
      function genrand_real3()
      double precision genrand_real3,r
      integer genrand_int32
      r=dble(genrand_int32())
      if(r.lt.0.d0)r=r+2.d0**32
      genrand_real3=(r+0.5d0)/4294967296.d0
      return
      end
c-----------------------------------------------------------------------
c     generates a random number on [0,1) with 53-bit resolution
c-----------------------------------------------------------------------
      function genrand_res53()
      double precision genrand_res53
      integer genrand_int32
      double precision a,b
      a=dble(ishft(genrand_int32(),-5))
      b=dble(ishft(genrand_int32(),-6))
      if(a.lt.0.d0)a=a+2.d0**32
      if(b.lt.0.d0)b=b+2.d0**32
      genrand_res53=(a*67108864.d0+b)/9007199254740992.d0
      return
      end
c-----------------------------------------------------------------------
c     initialize large number (over 32-bit constant number)
c-----------------------------------------------------------------------
      subroutine mt_initln
      integer ALLBIT_MASK
      integer TOPBIT_MASK
      integer UPPER_MASK,LOWER_MASK,MATRIX_A,T1_MASK,T2_MASK
      integer mag01(0:1)
      common /mt_mask1/ ALLBIT_MASK
      common /mt_mask2/ TOPBIT_MASK
      common /mt_mask3/ UPPER_MASK,LOWER_MASK,MATRIX_A,T1_MASK,T2_MASK
      common /mt_mag01/ mag01
CC    TOPBIT_MASK = Z'80000000'
CC    ALLBIT_MASK = Z'ffffffff'
CC    UPPER_MASK  = Z'80000000'
CC    LOWER_MASK  = Z'7fffffff'
CC    MATRIX_A    = Z'9908b0df'
CC    T1_MASK     = Z'9d2c5680'
CC    T2_MASK     = Z'efc60000'
      TOPBIT_MASK=1073741824
      TOPBIT_MASK=ishft(TOPBIT_MASK,1)
      ALLBIT_MASK=2147483647
      ALLBIT_MASK=ior(ALLBIT_MASK,TOPBIT_MASK)
      UPPER_MASK=TOPBIT_MASK
      LOWER_MASK=2147483647
      MATRIX_A=419999967
      MATRIX_A=ior(MATRIX_A,TOPBIT_MASK)
      T1_MASK=489444992
      T1_MASK=ior(T1_MASK,TOPBIT_MASK)
      T2_MASK=1875247104
      T2_MASK=ior(T2_MASK,TOPBIT_MASK)
      mag01(0)=0
      mag01(1)=MATRIX_A
      return
      end