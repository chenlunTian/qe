program main

implicit none

call test_buff

contains

subroutine test_buff()
    use tester
    use tb_pin, ONLY : tb_pin_t
    implicit none
    !
    type(tb_pin_t) :: buf
    !
    ! The tester class
    type(tester_t) :: my_tester
    !
    integer, pointer :: a_v1(:)
    integer, pointer :: a_v2(:)
    integer, pointer :: a_v3(:)
    integer, pointer :: a_v4(:)
    integer, pointer :: a_m1(:,:)
    integer :: info
    
    
    CALL my_tester% init()

    ! Initialize buffers
    CALL buf%init(info, .true.)
    !
    CALL buf%lock_buffer(a_v1, 0, info)
    CALL buf%release_buffer(a_v1, info)
    CALL buf%lock_buffer(a_m1, (/2, 0/), info)
    CALL buf%release_buffer(a_m1, info)
    !
    ! 
    CALL buf%lock_buffer(a_v1, 10, info)
    !
    ! First time a buffer is allocated, it has exactly the requested size
    !CALL my_tester% assert_equal(SIZE(a_v1), 10)
    !CALL my_tester% assert_equal(info, 0)
    ! Set elements of a_v1 to 1
    a_v1 = 1
    
    ! The previous buffer is already allocated, we get a new one here
    CALL buf%lock_buffer(a_v2, 11, info)
    CALL my_tester% assert_equal(SIZE(a_v2), 11)
    CALL my_tester% assert_equal(info, 0)

    ! The last available slot
    CALL buf%lock_buffer(a_v3, 12, info)
    CALL my_tester% assert_equal(SIZE(a_v3), 12)
    CALL my_tester% assert_equal(info, 0)

    ! Largest request, 134 elements
    CALL buf%lock_buffer(a_v4, 134, info)
    CALL my_tester% assert_equal(SIZE(a_v4), 134)
    CALL my_tester% assert_equal(info, 0)

    ! Release buffer 4 which was allocated as a standard pointer
    CALL buf%release_buffer(a_v4, info)
    ! Re-request a buffer, but smaller. 
    CALL buf%lock_buffer(a_v4, 5, info)
    CALL my_tester% assert_equal(SIZE(a_v4), 5)
    CALL my_tester% assert_equal(info, 0)
    !
    ! Release buffer v4 and v3
    CALL buf%release_buffer(a_v4, info)
    CALL buf%release_buffer(a_v3, info)
    !
    ! Now request a buffer 5 items log. We should be given the previously allocated 12 elements array
    CALL buf%lock_buffer(a_v3, 5, info)
    CALL my_tester% assert_equal(SIZE(a_v3), 5)
    CALL my_tester% assert_equal(info, 0)


    !CALL my_tester% assert_equal(SUM(a_v1), 10)
    CALL buf%release_buffer(a_v1, info)
    CALL buf%release_buffer(a_v2, info)
    CALL buf%release_buffer(a_v3, info)
    
    
    CALL buf%lock_buffer(a_m1, (/3,3/), info)
    CALL buf%release_buffer(a_m1, info)
    !
    CALL buf%lock_buffer(a_m1, (/2,2/), info)
    CALL buf%release_buffer(a_m1, info)
    !
    CALL buf%lock_buffer(a_m1, (/3,2/), info)
    CALL buf%release_buffer(a_m1, info)
    !
    CALL buf%lock_buffer(a_m1, (/3,1/), info)
    CALL buf%release_buffer(a_m1, info)
    
    CALL my_tester% print()
    
end subroutine
end program