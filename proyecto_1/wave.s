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

.section .rodata 
/* Floating point constants */
D_FRAC_1_PI: .double 0.318309886183790671537767526745028724
D_FRAC_PI_2: .double 1.57079632679489661923132169163975144
D_PI: .double 3.14159265358979323846264338327950288
D_TAU: .double 6.28318530717958647692528676655900577
D_2: .double 2.0
D_0p5: .double 0.5
D_0p25: .double 0.25
D_16: .double 16.0
D_8: .double 8.0
D_0p225: .double 0.225

.section .data
image_in: .fill IMG_SIZE,0x1,0x0
image_out: .fill IMG_SIZE,0x1,0x0

.section .text
/*================================================*/
/*   Floating point trig functions                */
/*================================================*/
sin:
    fld ft0, D_FRAC_PI_2, t0
    fsub.d fa0, fa0, ft0
/* Parabolic cosine approximation, as implemented in micromath*/
cos: /* angle = fa0 */
    /* fa0 *= 1/(2pi) */
    fld ft0, D_FRAC_1_PI, t0
    fld ft1, D_2, t1
    fdiv.d ft0, ft0, ft1 
    fmul.d fa0, fa0, ft0
    /* fa0 -= 0.25 + floor(fa0+0.25) */
    fld ft0, D_0p25, t0 
    fadd.d ft1, fa0, ft0     
    fcvt.l.d t0, ft1, rdn # round down 
    fcvt.d.l ft1, t0
    fadd.d ft1, ft0, ft1 
    fsub.d fa0, fa0, ft1
    /* fa0 *= 16.0 * abs(x) - 8.0; */
    fld ft0, D_16, t0
    fabs.d ft1, fa0 
    fld ft2, D_8, t1 
    fmsub.d ft3, ft0, ft1, ft2
    fmul.d fa0, fa0, ft3 
    /* fa0 += 0.225 * fa0 * (abs(fa0) - 1.0); */
    fld ft0, D_0p225, t0 
    fmul.d ft0, ft0, fa0 
    /* fa0 += (ft0) * abs(fa0) - ft0); */
    fabs.d ft1, fa0
    fmsub.d ft0, ft0, ft1, ft0 
    fadd.d fa0, fa0, ft0 
    ret

/*================================================*/
/*   Main program                                 */
/*================================================*/

/*
 * Transform 
 * params: a0: x, a1: y, a2: Ax, a3: Ay, a4: Lx, a5: Ly 
 * return: a0: x', a1: y'
 */
transform:
    addi sp, sp, -8
    sd ra, 0(sp)
    /*no other function is using the fs regs so no prologue required*/
    fcvt.d.l fs0, a0 
    fcvt.d.l fs1, a1
    fcvt.d.l fs2, a2
    fcvt.d.l fs3, a3
    fcvt.d.l fs4, a4
    fcvt.d.l fs5, a5
    fld fs6, D_TAU, t0

    fmul.d ft7, fs6, fs1 
    fdiv.d fa0, ft7, fs4 
    call sin 
    fmul.d fa0, fa0, fs2
    fadd.d ft0, fa0, fs0
    fcvt.l.d a0, ft0, rne # x'

    fmul.d ft7, fs6, fs0 
    fdiv.d fa0, ft7, fs5 
    call sin 
    fmul.d fa0, fa0, fs3
    fadd.d ft0, fa0, fs1
    fcvt.l.d a1, ft0, rne # y'

    ld ra, 0(sp) 
    addi sp, sp, 8
    ret

.global _start
_start:
    ld t0, 0(sp) # argc
    li t1, 5
    bne t0, t1, exit_err 

    /* argv[0] is not relevant */
    
    ld a0, 16(sp) # argv[1] Ax
    call atoi 
    mv s0, a0 
    ld a0, 24(sp) # argv[2] Ay
    call atoi 
    mv s1, a0 
    ld a0, 32(sp) # argv[3] Lx
    call atoi 
    mv s2, a0 
    ld a0, 40(sp) # argv[4] Ly
    call atoi 
    mv s3, a0 

    /* Read source image as a binary file via STDIN */
    li a0, FD_STDIN
    la a1, image_in
    la a2, IMG_SIZE
    li a7, SYSCALL_READ
    ecall

    li s4, ROWS
    li s5, COLS
    li s6, 0 # i, iterate over rows
    la s8, image_in  # base address of the input image  
    la s9, image_out # base address of the output image  
    loop_y:
        mv s7, zero # j, iterate over columns 
        loop_x:
            mv a0, s7 
            mv a1, s6 
            mv a2, s0 
            mv a3, s1
            mv a4, s2
            mv a5, s3

            /*Apply changes to new image*/
            mul t0, a1, s5 # calculate positions from base to calc
            add t0, t0, a0   # x + y*cols
            add s10, t0, s8   # (uint8_t*) image_in + (x+y*cols)

            call transform 
            
            /* Only apply transformation if the new coords are within bounds*/
            rem t1, a1, s4 # y' % ROWS
            rem t0, a0, s5 # x' % COLS
            bne t1, a1, nosave 
            bne t0, a0, nosave

            mul t0, a1, s5  # calculate positions from base to calc
            add t0, t0, a0  # x' + y'*cols
            add s11, t0, s9 # (uint8_t*) image_out + (x'+y'*cols)

            lb t0, 0(s10) # fetch pixel value
            sb t0, 0(s11) # save value in new coords

            nosave:
            add s7, s7, 1
            blt s7, s5, loop_x  
        add s6, s6, 1
        blt s6, s4, loop_y

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

/* Simple, base 10 lazy implementation for atoi */
atoi:
    mv t0, a0 # preserve pointer to the string argument
    mv a0, zero
    li t1, 0x30 # '0' 
    li t2, 0x39 # '9'
    atoi_loop:
        lb t3, 0(t0) # load character
        beqz t3, atoi_ok # check for null termination
        

        bgt t1, t3, atoi_err # check number is >= 0
        bgt t3, t2, atoi_err # check number is <= 9

        sub t3, t3, t1 # calculate current number
        
        /* multiply accumulated amount by 10 */
        mv t4, a0 
        slli a0, a0, 3
        add a0, a0, t4 
        add a0, a0, t4 
        
        add a0, a0, t3 # add current value to accumulated amount
        add t0, t0, 1 # increase pointer value
        j atoi_loop
    atoi_err: # error
        li a1, ERR
        ret
    atoi_ok: # exito
        li a1, OK
        ret


