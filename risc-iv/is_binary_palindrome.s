    .data
    .org 0x00

input_addr:     .word  0x80
output_addr:    .word  0x84

    .text
    .org 0x218

reverse:
    addi        sp, sp, -12
    sw          ra, 8(sp)
    sw          a0, 4(sp)
    sw          a2, 0(sp)
    
    beqz        a2, reverse_stop
    
    andi        t0, a0, 0x01
    slli        a1, a1, 1
    add         a1, a1, t0
    srli        a0, a0, 1
    addi        a2, a2, -1
    
    jal         ra, reverse
    j           reverse_free

reverse_stop:
    addi        a0, a1, 0

reverse_free:
    lw          ra, 8(sp)
    lw          a2, 0(sp)
    addi        sp, sp, 12
    jr          ra

_start:
    addi        sp, sp, 0x214

    lui         t0, %hi(input_addr)
    addi        t0, t0, %lo(input_addr)

    lw          t0, 0(t0)

    lw          t1, 0(t0)
    mv          s0, t1

    addi        a0, s0, 0
    addi        a1, zero, 0
    addi        a2, zero, 32

    jal         ra, reverse

    mv          s1, a0
    
    j           compare

compare:
    beq         s1, s0, is_binary

not_binary:
    mv          t5, zero
    j           stop

is_binary:
    addi        t5, zero, 1

stop:
    lui         t0, %hi(output_addr)
    addi        t0, t0, %lo(output_addr)
    lw          t0, 0(t0)
    sw          t5, 0(t0)  
    halt
