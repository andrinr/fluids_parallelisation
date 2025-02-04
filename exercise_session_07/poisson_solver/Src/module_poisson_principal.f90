!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! -*- Mode: F90 -*- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! module_poisson_principal.f90 --- 
!!!!
!! subroutine init_poisson
!! subroutine jacobi_step
!! subroutine init_f
!! subroutine init_exact
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

module poisson_principal

contains

subroutine init_poisson
    use poisson_commons
    use poisson_parameters
    use poisson_utils

    implicit none

    ! Local variables
    imin=1
    imax=nx
    jmin=1
    jmax=ny

    dx = 1.0D+00 / real ( nx - 1, kind=prec_real)
    dy = 1.0D+00 / real ( ny - 1, kind=prec_real)

    ! initiliaze f, uexact, uold, unew
    allocate(f(imin:imax,jmin:jmax))
    call init_f

    allocate(uexact(imin:imax,jmin:jmax))
    call init_exact

    allocate(uold(imin:imax,jmin:jmax))
    allocate(unew(imin:imax,jmin:jmax))
    allocate(udiff(imin:imax,jmin:jmax))

    uold(imin:imax,jmin:jmax) = f(imin:imax,jmin:jmax)
    unew(imin:imax,jmin:jmax) = uold(imin:imax,jmin:jmax)
end subroutine init_poisson

subroutine jacobi_step
    use poisson_commons
    use poisson_parameters
    use poisson_utils
    !$ use OMP_LIB


    ! Save the current estimate. 
    uold = unew

    ! Compute a new estimate.
    !$OMP PARALLEL
    !$OMP DO

    do j = jmin, jmax
        do i = imin, imax
            if ( i == 1 .or. i == nx .or. j == 1 .or. j == ny ) then
                unew(i,j) = f(i,j)
            else
                unew(i,j) = 0.25 * ( uold(i-1,j) + uold(i,j+1) + uold(i,j-1) + uold(i+1,j) - f(i,j) * dx * dy )
            end if

        end do
    end do
    !$OMP END DO
    !$OMP END PARALLEL

    ! compute difference and errors
    udiff = unew - uold
    diff = mat_norm(udiff)
    udiff = unew - uexact
    error = mat_norm(udiff)

end subroutine jacobi_step

subroutine init_f
    use poisson_commons
    use poisson_parameters
    use poisson_utils
    !
    !  The "boundary" entries of f will store the boundary values of the solution.
    !
    !  The "interior" entries of f store the source term 
    !  of the Poisson equation.
    !

    do j = jmin, jmax
        y = real ( j - 1,kind=prec_real) / real ( ny - 1,kind=prec_real)
        do i = imin, imax
            x = real ( i - 1,kind=prec_real) / real ( nx - 1,kind=prec_real)
            if ( i == 1 .or. i == nx .or. j == 1 .or. j == ny ) then
                f(i,j) = boundary(x,y)
            else
                f(i,j) = source_term ( x, y )
            endif
        end do
    end do
end subroutine init_f

subroutine init_exact
    use poisson_commons
    use poisson_parameters
    use poisson_utils

    ! initialize exact solution (given the source function)
    do j = 1, jmax
        y = real ( j - 1,kind=prec_real) / real ( ny - 1,kind=prec_real)
        do i = 1, imax
            x = real ( i - 1,kind=prec_real) / real ( nx - 1,kind=prec_real)
            uexact(i,j) = exact_solution ( x, y )
        end do
    end do
end subroutine init_exact

end module poisson_principal
