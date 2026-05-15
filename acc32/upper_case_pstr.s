.data
.org 0x30
input:          .word  0x80
output:         .word  0x84

ptr:            .word  0x00

counter:        .word  0x00
cur:            .word  0x00
cur_word:       .word  0x00

const_1:        .word  0x01
const_32:       .word  0x20
const_low:      .word  0x5F
const_a:        .word  0x61
const_z:        .word  0x7A
const_n:        .word  0x0A
const_err:      .word  0xCCCCCCCC
const_mread:    .word  0xFFFFFF00
const_mwrite:   .word  0xFF

.text
.org 0x90
_start: 
    bltz        init_loop
    jmp         init_loop

init_loop:
    load_addr   ptr
    sub         const_32
    beqz        read_start 
    add         const_32
    
    load_addr   const_low
    store_ind   ptr
    
    load_addr   ptr
    add         const_1
    store_addr  ptr
    jmp         init_loop

read_start:
    load_imm    0x00
    store_addr  ptr
    jmp         read_loop

read_loop:
    load_addr   ptr
    add         const_1
    store_addr  ptr

    load_addr   input
    load_acc
    store_addr  cur

    sub         const_n
    beqz        end_reading

    load_addr   counter
    add         const_1
    store_addr  counter

    sub         const_32
    beqz        overflow

    load_addr   cur
    sub         const_a
    ble         save_element
    load_addr   cur
    sub         const_z
    bgt         save_element
    
    load_addr   cur
    sub         const_32
    store_addr  cur

    jmp         save_element

save_element:
    load_addr   ptr
    load_acc
    and         const_mread
    store_addr  cur_word

    load_addr   cur
    add         cur_word
    store_ind   ptr

    jmp         read_loop

end_reading:
    load_addr   0x00
    and         const_mread
    store_addr  cur_word

    load_addr   counter
    add         cur_word
    store_addr  0x00

    load_imm    0x01
    store_addr  ptr

    jmp         print_result

print_result:
    load_addr   ptr
    sub         const_32
    beqz        stop
    add         const_32
    load_acc
    and         const_mwrite
    sub         const_low
    beqz        stop
    add         const_low
    store_ind   output
    load_addr   ptr
    add         const_1
    store_addr  ptr
    jmp         print_result

overflow:
    load_addr   const_err
    store_ind   output
    halt

stop:
    halt