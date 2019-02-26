# Author:       Xiaoguang Zhu
# Version:      2.25 15:29

#### Includes and Defines ####

.eqv    STACK_BASE      0x2ffc
.eqv    STACK_LIMIT     0x2000


#     .data


    .text

.macro disable_interrupt    # using $k1
    mfc0 $k1, $12
    nor $k1, $zero, $k1     # HACK: not $k1, $k1
    ori $k1, $k1, 1
    nor $k1, $zero, $k1
    mtc0 $k1, $12
.end_macro

.macro enable_interrupt     # using $k1
    mfc0 $k1, $12
    ori $k1, $k1, 0x1
    mtc0 $k1, $12
.end_macro

CPUConfiguration:
    # set stack base address
    addi $sp, $zero, STACK_BASE
    enable_interrupt
    # debug interrupt
    # addi $k0, $zero, 0x3120 # ie, Main (2.25 23:32)
    # mtc0 $k0, $14
    # addi $k0, $zero, 0xbe0
    # addi $k1, $zero, 0xbe1
    # j InterruptHidden_Start
    # end debug
    # start system software
    j Main
    nop
    nop
    nop


#### Interrupt Related Segment ####

    .text

# ($k0) <= (($k1)[place] == 1) ? 1 : 0
.macro test_rk1_bit (%place)    # using $k0
    srl $k0, $k1, %place
    andi $k0, $k0, 0x1
.end_macro

# After this section:
#   stack:
#               +4          +8          +12         +16
#      __$sp__  CP0.Cause   CP0.EPC     (reserved)  (reserved)
#
#               +20         +24         +28         +32
#               $k1         $k0         $v1         $v0
#
#               +36         +40         +44         +48
#               $a3         $a2         $a1         $a0
#
#               +52         +56         +60         +64
#               $s7         $s6         $s5         $s4
#
#               +68         +72         +76         +80
#               $s3         $s2         $s1         $s0
#
#               +84         +88         ...         __RAM_LIMIT__
#               $s8/$fp     $ra         ...         ...
InterruptHidden_Start:
    # interrupt closed by interrupt hardware
    # manual bubbling to pipeline
    nop
    nop
    nop
    nop
    # push context to stack
    addi $sp, $sp, -88
    sw $ra, 88($sp)
    sw $fp, 84($sp)
    sw $s0, 80($sp)
    sw $s1, 76($sp)
    sw $s2, 72($sp)
    sw $s3, 68($sp)
    sw $s4, 64($sp)
    sw $s5, 60($sp)
    sw $s6, 56($sp)
    sw $s7, 52($sp)
    sw $a0, 48($sp)
    sw $a1, 44($sp)
    sw $a2, 40($sp)
    sw $a3, 36($sp)
    sw $v0, 32($sp)
    sw $v1, 28($sp)
    sw $k0, 24($sp)
    sw $k1, 20($sp)
    # reserved slot 16($sp)
    # reserved slot 12($sp)
    mfc0 $k1, $14
    sw $k1, 8($sp)
    mfc0 $k1, $13
    sw $k1, 4($sp)
InterruptVector:
    lw $k1, 4($sp)
    test_rk1_bit (12)
    bne $k0, $zero, InterruptService_external2
    test_rk1_bit (11)
    bne $k0, $zero, InterruptService_external1
    test_rk1_bit (10)
    bne $k0, $zero, InterruptService_external0
    test_rk1_bit (9)
    bne $k0, $zero, InterruptService_internaltrap
    test_rk1_bit (8)
    bne $k0, $zero, InterruptService_internalcpu
    # or else
    enable_interrupt
    j InterruptHidden_End

InterruptHidden_End:
    disable_interrupt
    # recover register context
    lw $k0, 8($sp)              # CP0.EPC <= 8($sp)
    mtc0 $k0, $14
    lw $ra, 88($sp)
    lw $fp, 84($sp)
    lw $s0, 80($sp)
    lw $s1, 76($sp)
    lw $s2, 72($sp)
    lw $s3, 68($sp)
    lw $s4, 64($sp)
    lw $s5, 60($sp)
    lw $s6, 56($sp)
    lw $s7, 52($sp)
    lw $a0, 48($sp)
    lw $a1, 44($sp)
    lw $a2, 40($sp)
    lw $a3, 36($sp)
    lw $v0, 32($sp)
    lw $v1, 28($sp)
    lw $k0, 24($sp)             # NOTE: recovery of $k0, $k1 is unneccessary,
    lw $k1, 20($sp)             #       since `enable_interrupt -> eret` is
                                #       uninterruptible (let along hardly occur)
    addi $sp, $sp, 88           # pop context from stack
    enable_interrupt
    eret                        # ($sp) points to (CP0.EPC)
                                # 1.  pc <= CP0.EPC
                                # 3.  CP0.Cause.IP[IPService] <= 0

# .macro mask_cause_ip (%mask)    # using $k0
#     mfc0 $k0, $13
#     andi $k0, $k0, %mask
#     mtc0 $k0, $13
# .end_macro

InterruptService_internalcpu:
    # mask_cause_ip (0xffffffef)
    enable_interrupt
    addi $a0, $zero, 0
    addi $v0, $zero, 34
    syscall
    j InterruptHidden_End

InterruptService_internaltrap:
    # mask_cause_ip (0xffffffcf)
    enable_interrupt
    addi $a0, $zero, 1
    addi $v0, $zero, 34
    syscall
    j InterruptHidden_End

InterruptService_external0:
    # mask_cause_ip (0xffffff8f)
    enable_interrupt
    addi $a0, $zero, 2
    addi $v0, $zero, 34
    syscall
    sll $a0, $a0, 4
    syscall
    sll $a0, $a0, 4
    syscall
    sll $a0, $a0, 4
    syscall
    sll $a0, $a0, 4
    syscall
    sll $a0, $a0, 4
    syscall
    sll $a0, $a0, 4
    syscall
    sll $a0, $a0, 4
    syscall
    j InterruptHidden_End

InterruptService_external1:
    # mask_cause_ip (0xffffff0f)
    enable_interrupt
    addi $a0, $zero, 3
    addi $v0, $zero, 34
    syscall
    sll $a0, $a0, 4
    syscall
    sll $a0, $a0, 4
    syscall
    sll $a0, $a0, 4
    syscall
    sll $a0, $a0, 4
    syscall
    sll $a0, $a0, 4
    syscall
    sll $a0, $a0, 4
    syscall
    sll $a0, $a0, 4
    syscall
    j InterruptHidden_End

InterruptService_external2:
    # mask_cause_ip (0xfffffe0f)
    enable_interrupt
    addi $a0, $zero, 4
    addi $v0, $zero, 34
    syscall
    sll $a0, $a0, 4
    syscall
    sll $a0, $a0, 4
    syscall
    sll $a0, $a0, 4
    syscall
    sll $a0, $a0, 4
    syscall
    sll $a0, $a0, 4
    syscall
    sll $a0, $a0, 4
    syscall
    sll $a0, $a0, 4
    syscall
    j InterruptHidden_End


#### System Software Entry ####

    .text

Main:
    #### program goes here ####

    j Main                      # loop back
