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

/* Algorithm related constants */
.equ LX, 75
.equ LY, 75

.section .data
AX: .dword 0x0
AY: .dword 0x0
image_in: .fill IMG_SIZE,0x1,0x0
image_out: .fill IMG_SIZE,0x1,0x0

.section .text
.global _start
_start:
    ld a0, 0(sp) # argc
    /* argv[0] is not relevant */
    la t1, AX 
    la t2, AY  
    
    ld a0, 16(sp) # argv[1]
    call atoi 
    mv s1, a0 
    ld a0, 24(sp) # argv[2]
    call atoi 
    mv s2, a0 

    li a0, FD_STDIN
    la a1, image_in
    la a2, IMG_SIZE
    li a7, SYSCALL_READ
    ecall

    li a0, FD_STDOUT 
    #la a1, msg
    la a2, IMG_SIZE
    li a7, SYSCALL_WRITE
    ecall
    j exit 

exit:
    li a0, 0 
    li a7, SYSCALL_EXIT
    ecall 

div_round_nearest: /* a0 / a1 */
    slt t0, a0, zero 
    slt t1, a1, zero
    li t2, 2
    beq t0, t1, 2f
    1: # same sign ((a0 + a1/2)/a1)
        div t0, a1, t2 
        add t0, a0, t0 
        div t0, t0, a1 
        j 1f
    2: # diff sign ((a0 - a1/2)/a1)
        div t0, a1, t2 
        sub t0, a0, t0 
        div t0, t0, a1 
    1: #end 
        mv a0, t0
        ret

atoi:
    mv t0, a0 # preservar puntero a string
    mv a0, zero
    li t1, 0x30 # '1' 
    li t2, 0x39 # '9'
    atoi_loop:
        lb t3, 0(t0) # cargar primer caracter
        beqz t3, atoi_ok # si es un 0 llegamos al nulo
        

        bgt t1, t3, atoi_err
        bgt t3, t2, atoi_err 

        sub t3, t3, t1 # obtener numero actual
        
        /* multiplicar acumulado por 10 */
        mv t4, a0 
        slli a0, a0, 3
        add a0, a0, t4 
        add a0, a0, t4 
        
        add a0, a0, t3 # sumar valor actual
        add t0, t0, 1 # avanzar puntero 1 byte
        j atoi_loop
    atoi_err: # error
        li a1, ERR
        ret
    atoi_ok: # exito
        li a1, OK
        ret


