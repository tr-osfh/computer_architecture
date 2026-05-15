    .data
    .org 0x88

input_addr:         .word  0x80
output_addr:        .word  0x84


    .text
    .org 0x120

print_num:
    move.b      (A2)+, D0
    cmp.b       0x00, D0
    beq         print_num_end
    jsr         write_char
    jmp         print_num
print_num_end:
    rts

read_num:
    jsr         read_input

    cmp.b       0x0A, D0
    beq         read_num_return
    move.b      D0, (A2)+
    add.l       0x01, -8(A6)

    cmp.b       0x2D, D0
    beq         read_num_continue

    cmp.b       0x30, D0
    blt         error

    cmp.b       0x39, D0
    bgt         error

    cmp.b       0x01, (A6)
    beq         read_num_minus

    sub.b       0x30, D0
    add.l       D0, -4(A6)
    bvs         error
    mul.l       0x0A, -4(A6)
    jmp         read_num
    
read_num_minus:
    sub.b       0x30, D0
    sub.l       D0, -4(A6)
    bvs         error
    mul.l       0x0A, -4(A6)

    jmp         read_num

read_num_continue:
    move.l      0x01, (A6)
    jmp         read_num

read_num_return:
    rts

write_char:
    move.b      D0, (A3)+
    rts

read_input:
    movea.l     input_addr, A0
    movea.l     (A0), A0
    move.b      (A0), D0
    rts

_start:
    movea.l     0x100, A7
    movea.l     0x40, A3
    movea.l     0x00, A1
    move.l      0x00, D1
    
read_str:
    jsr         read_input

    cmp.l       0x20, D1
    bge         error
    
    move.b      D0, (A1)+
    add.l       0x01, D1

    cmp.b       0x0A, D0
    beq         write_str
    jmp         read_str

write_str:
    movea.l     0x00, A1
    move.l      0x00, D1 ; счетчик для буффера

write_cicle:
    move.b      (A1, D1), D0
    add.l       0x01, D1
    cmp.b       0x25, D0 ; провери на процент
    beq         check_plh
    cmp.b       0x0A, D0
    beq         print_answer
write:
    jsr         write_char
    jmp         write_cicle

check_plh:
    move.l      0x00, D3 ; Хранение факта минуса
    move.l      0x00, D2 ; счетчик для плейсхолдеров
    move.l      0x00, D4 ; хранение числа пробелов
    movea.l     D1, A2
    move.l      D1, D2
check_plh_cicle:
    move.b      (A2)+, D0

    cmp.b       0x64, D0
    beq         end_check_plh

    cmp.b       0x2D, D0
    bne         not_minus
    move.l      0x01, D3
    add.l       0x01, D2
    jmp         check_plh_cicle

not_minus:
    cmp.b       0x30, D0
    blt         write_cicle
    cmp.b       0x39, D0
    bge         write_cicle

    sub.b       0x30, D0
    mul.l       0x0A, D4
    add.l       D0, D4


    add.l       0x01, D2
    jmp         check_plh_cicle

end_check_plh:
    add.l       0x01, D2
    move.l      D2, D1
    movea.l     0x20, A2

    link        A6, -12
    movea.l     0x20, A2
    move.l      0x00, (A6)
    move.l      0x00, -4(A6)
    move.l      0x00, -8(A6)

    jsr         read_num

    move.l      (A6), D6
    move.l      -4(A6), D5
    move.l      -8(A6), D2
    unlk        A6
    jmp         write_plh

write_plh:
    cmp.b       0x00, D2
    beq         error
    movea.l     0x20, A2        ; Указатель на число

    sub.l       D2, D4

    cmp.l       0x00, D3
    beq         print_plh

    jsr         print_num
    jmp         print_plh

print_plh:
    cmp.l       0x00, D4
    bgt         print_plh_cicle
    jsr         print_num
    jmp         write_cicle
print_plh_cicle:
    move.b      0x20, D0
    jsr         write_char
    sub.l       0x01, D4
    bgt         print_plh_cicle

    cmp.l       0x00, D3
    bne         write_cicle
    jsr         print_num
    jmp         write_cicle

print_answer:
    move.l      0x40, D1
    movea.l     output_addr, A0
    movea.l     (A0), A0

print_loop:
    move.b      (A1, D1), D0
    cmp.b       0x00, D0
    beq         stop
    move.b      D0, (A0)
    add.l       0x01, D1
    jmp         print_loop

error:
    movea.l     output_addr, A0
    movea.l     (A0), A0
    move.l      0xFFFFFFFF, (A0)
    jmp         stop

stop: 
    halt