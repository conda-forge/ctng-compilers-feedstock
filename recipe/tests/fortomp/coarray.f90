program coarray
  implicit none
  integer :: x[*]
  x = 10 * this_image()
  sync all
  if (this_image() == 1) then
    if (x[num_images()] /= 10 * num_images()) error stop 1
    print *, "coarray images:", num_images()
  end if
end program coarray
