.data
.org 0x30

input_addr:         .word  0x80
output_addr:        .word  0x84

lw_high:            .word  0x00
lw_low:             .word  0x00
in1:                .word  0x00
in2:                .word  0x00
hw_low:             .word  0x00
hw_high:            .word  0x00

mask_low:           .word  0xFFFF
mask_high:          .word  0xFFFF0000

.text
.org 0x88

shr16:
    2/ 2/ 2/ 2/ 2/ 2/ 2/ 2/ 2/ 2/ 2/ 2/ 2/ 2/ 2/ 2/
    ;

shl16:
    2* 2* 2* 2* 2* 2* 2* 2* 2* 2* 2* 2* 2* 2* 2* 2*
    ;

add_to_mem:
    @
    +
    dup
    @p mask_low
    and
    !
    shr16
    ;

_start:
    loop ;
loop:
    lit 0x80 a! @
    dup if end

    dup
    @p mask_high and shr16 !p in1

    @p mask_low and dup !p in2

    lit lw_low a!
    add_to_mem
    dup !p in2

    lit lw_high a!
    @p in1 + add_to_mem

    lit hw_low a!
    add_to_mem

    @p hw_high + !p hw_high

    loop
end:
    @p hw_high
    shl16
    @p hw_low
    +
    @p output_addr a! !

    @p lw_high
    shl16
    @p lw_low
    +
    @p output_addr a! !

    halt