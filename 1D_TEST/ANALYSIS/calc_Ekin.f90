PROGRAM calc_Ekin
      implicit none
      integer :: ntraj,i,j,nsteps,k, ndim
      real*8 ::  time,delta_t
      character(len=500) :: tmp1, filename, timestep
      real*8, parameter :: pi=4.d0*datan(1.d0)
      real*8,allocatable :: Ekin(:,:),mass(:),R(:),P(:)

      write(*,*) "Number of trajectories"
      read(*,*) ntraj
      write(*,*) "Number of steps"
      read(*,*) nsteps
      write(*,*) "DT * DUMP"
      read(*,*) delta_t
      write(*,*) "Dimensions of the model"
      read(*,*) ndim
      allocate(Ekin(nsteps,ndim),R(ndim),P(ndim),mass(ndim))
      write(*,*) "Mass(es)"
      read(*,*) mass

      do j=1,nsteps
         k=j-1
         write(timestep,"(I4.4)") k
         filename="./trajectories/RPE."//TRIM(timestep)//".dat"
         OPEN(357,FILE=TRIM(filename),ACTION="read",STATUS="old", &
            FORM="formatted")
         read(357,*) tmp1
         do i=1,ntraj 
            read(357,*) R,P,tmp1,tmp1,tmp1,tmp1
            Ekin(j,:)=Ekin(j,:)+0.5*P(:)*P(:)/mass(:)
         enddo
         Ekin(j,:)=Ekin(j,:)/dble(ntraj)
         close(357)
      enddo
      open(358,file="./Ekin.dat",action="write")
      write(358,*) "# time, Ekin along each coordinate (in Ha, in eV, in kcal/mol)"
      do i=1,nsteps
         time=(i-1)*delta_t*0.0242
         write(358,*) time,Ekin(i,:),Ekin(i,:)*27.21d0,Ekin(i,:)*627.509474d0
      enddo
      close(358)

      deallocate(Ekin,R,P,mass)

END PROGRAM

