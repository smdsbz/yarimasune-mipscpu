# Author:       Xiaoguang Zhu
# Version:      2.25 23:32

#### Includes and Defines ####

.eqv    STACK_BASE      0x2ffc
.eqv    STACK_LIMIT     0x2000


#     .data


    .text

CPUConfiguration:
    # set stack base address
    addi $sp, $zero, STACK_BASE
    # debug interrupt
    addi $k0, $zero, 0x3120 # ie, Main (2.25 23:32)
    mtc0 $k0, $14
    addi $k0, $zero, 0xbe0
    addi $k1, $zero, 0xbe1
    j InterruptHidden_Start
    # end debug
    # start system software
    j Main


#### Interrupt Related Segment ####

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

# ($k0) <= (($k1)[place] == 1) ? 1 : 0
.macro test_rk1_bit (%place)    # using $k0
    srl $k0, $k1, %place
    andi $k0, $k0, 0x1
.end_macro

# After this section:
#   stack:
#      __$sp__ (CP0.Cause) (CP0.EPC) $k1 $k0 ... __RAM_LIMIT__
InterruptHidden_Start:
    # interrupt close by interrupt hardware
    # manual bubbling to pipeline
    nop
    nop
    nop
    nop
    # push context to stack
    addi $sp, $sp, -16
    sw $k0, 16($sp)
    sw $k1, 12($sp)
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
    lw $k0, 8($sp)
    mtc0 $k0, $14
    lw $k1, 12($sp)
    lw $k0, 16($sp)
    addi $sp, $sp, 16           # pop context from stack
    enable_interrupt
    eret                        # ($sp) points to (CP0.EPC)
                                # 1.  pc <= ($sp)
                                # 2.  CP0.Status.IE <= 1
                                # 3.  CP0.Cause.IP[highest] <= 0

.macro mask_cause_ip (%mask)    # using $k0
    # mfc0 $k0, $13
    # andi $k0, $k0, %mask
    # mtc0 $k0, $13
.end_macro

InterruptService_internalcpu:
    mask_cause_ip (0xffffffef)
    enable_interrupt
    j InterruptHidden_End

InterruptService_internaltrap:
    mask_cause_ip (0xffffffcf)
    enable_interrupt
    j InterruptHidden_End

InterruptService_external0:
    mask_cause_ip (0xffffff8f)
    enable_interrupt
    j InterruptHidden_End

InterruptService_external1:
    mask_cause_ip (0xffffff0f)
    enable_interrupt
    j InterruptHidden_End

InterruptService_external2:
    mask_cause_ip (0xfffffe0f)
    enable_interrupt
    j InterruptHidden_End


#### System Software Entry ####

    .text

Main:
    #### program goes here ####

    j Main                      # loop back
