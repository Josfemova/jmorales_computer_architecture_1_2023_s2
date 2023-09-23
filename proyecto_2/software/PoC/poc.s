/* file descriptors */
.equ FD_STDIN, 0
.equ FD_STDOUT, 1
.equ FD_STDERR, 2

/* system calls */
.equ SYSCALL_READ, 63 /*a0 fd, a1 buf, a2 count*/
.equ SYSCALL_WRITE, 64 /*a0 fd, a1 buf, a2 count*/
.equ SYSCALL_EXIT, 93 /*a0 exit code*/

/*general constants*/
.equ COLS, 640
.equ ROWS, 480
.equ IMG_SIZE, COLS*ROWS
.equ OK, 0
.equ ERR, 1

.section .data
image_in: .fill IMG_SIZE,0x1,0x0
image_out: .fill IMG_SIZE,0x1,0x0
.global _start
_start:
    /* Read source image as a binary file via STDIN */
    li a0, FD_STDIN
    la a1, image_in
    la a2, IMG_SIZE
    li a7, SYSCALL_READ
    ecall

    /* Write resulting binary data to STDOUT */
    li a0, FD_STDOUT 
    la a1, image_out 
    la a2, IMG_SIZE
    li a7, SYSCALL_WRITE
    ecall
    j exit 

exit:
    li a0, 0 
    li a7, SYSCALL_EXIT
    ecall 

exit_err:
    li a0, 1 
    li a7, SYSCALL_EXIT
    ecall 