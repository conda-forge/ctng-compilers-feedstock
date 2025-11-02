program maths
  use, intrinsic :: ieee_arithmetic
  use omp_lib
  implicit none

  real(8) :: x = 2.0_8
  complex :: z = (1.0, 2.0)
  integer, parameter :: n = 4567
  integer :: i
  real :: f(n)

  ! Check that large reals and libquadmath work
  integer, parameter :: k1 = &
    max(selected_real_kind(precision(0.d0) + 1), kind(0.))
  integer, parameter :: k2 = &
    max(selected_real_kind(precision(0._k1) + 1), kind(0.d0))
  real(kind=k1) :: x1
  real(kind=k2) :: x2

  ! Test intrinsic modules also
  x1 = ieee_value(x1, ieee_positive_inf)
  print *, "infinite is:", sqrt(x1)
  x2 = ieee_value(x2, ieee_positive_inf)
  print *, "infinite is:", sqrt(x2)

  x = sqrt(x)
  z = sqrt(z)

  do i = 1, n
    f(i) = i
  enddo

  !$OMP PARALLEL SHARED(f) PRIVATE(i)

  !$omp master
  print *, "number of threads:",  omp_get_num_threads()
  !$omp end master

  !$OMP DO
  do i = 1, n
    f(i) = sqrt(f(i))
  enddo
  !$OMP END DO NOWAIT
  !$OMP END PARALLEL

  print *, "sqrt(2):", f(2)
end program maths
