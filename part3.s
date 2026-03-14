.section .bss
.globl out_buf
.lcomm out_buf, 16

.section .data
Numbers:
    .long 1
    .long 15
    .long 4
    .long 2
    .long 7
    .long 9
    .long 23
    .long 7
    .long 3
    .long 11

Array_length:
    .long 10

msg_max: .ascii "Max array value is: "

.section .text
.globl _start

_start:
    # Initialize our loop variables
    mov $0, %rsi            # i = 0 (using rsi as the array index)
    mov Array_length, %r8d  # limit = 10
    mov Numbers, %r9d       # current_max = Numbers[0]
    
    # "While pattern" jump to condition first (like unoptimized C)
    jmp check_loop_cond

execute_loop_body:
    # Load Numbers[i] into a temp register
    mov Numbers(,%rsi,4), %r10d
    
    # Compare current_max to Numbers[i]
    cmp %r9d, %r10d
    jle iterate_next        # If Numbers[i] <= max, skip updating
    
    mov %r10d, %r9d         # update max: current_max = Numbers[i]

iterate_next:
    inc %rsi                # i++

check_loop_cond:
    # Evaluate while (i < Array_length)
    cmp %r8d, %esi
    jl execute_loop_body    # Jump back to body if i < 10

print_results:
    # 1) Print the string message
    mov $1, %rax
    mov $1, %rdi
    mov $msg_max, %rsi
    mov $20, %rdx
    syscall

    # 2) Setup ASCII conversion for the max value (matches your earlier style)
    mov %r9, %rax           # Put max integer in rax for division
    mov $10, %rbx           # Base 10
    mov $out_buf, %rsi
    add $14, %rsi
    
    movb $10, (%rsi)        # Append newline
    dec %rsi

convert_int_to_ascii:
    mov $0, %rdx
    div %rbx
    add $48, %dl            # shift remainder into ASCII char range
    movb %dl, (%rsi)
    dec %rsi
    cmp $0, %rax
    jnz convert_int_to_ascii

    inc %rsi
    
    # 3) Calculate string length dynamically and print the number
    mov $out_buf, %rdx
    add $15, %rdx
    sub %rsi, %rdx

    mov $1, %rax
    mov $1, %rdi
    syscall

    # Exit program safely
    mov $60, %rax
    mov $0, %rdi
    syscall

.section .note.GNU-stack,"",@progbits
