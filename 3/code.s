.include "stdlib.s"

.section .data
mode: .byte 0, 0, 0, 0, 0, 0, 0, 0

.section .text

# type: (char* field, int width, int height, int right, int down) -> int trees
.global count_slope
count_slope:
	xor rax, rax	
	xor rbx, rbx  # x
	xor rcx, rcx  # y
	mov r11, 35
.Lcount_slope.loop:
	mov r9, rcx
	imul r9, rsi
	add r9, rbx
	add r9, rdi
	mov r9b, [r9]
	cmp r11b, r9b
	jne .Lcount_slope.next
	inc rax
.Lcount_slope.next:
	add rbx, r10
	add rcx, r8
	cmp rcx, rdx
	jge .Lcount_slope.end
	cmp rbx, rsi
	jl .Lcount_slope.loop
	sub rbx, rsi
	jmp .Lcount_slope.loop
.Lcount_slope.end:
	ret

# type: (char* field, int width, int height) -> int
.global solve1
solve1:
	mov r10, 3
	mov r8, 1
	jmp count_slope

# type: (char* field, int width, int height) -> int
.global solve2
solve2:
	.macro solve2_call_count_slope right, down
		mov rdi, r12
		mov rsi, r13
		mov rdx, r14
		mov r10, \right
		mov r8, \down
		call count_slope
		imul r15, rax
	.endm

	push r12
	push r13
	push r14
	push r15
	mov r15, 1

	mov r12, rdi
	mov r13, rsi
	mov r14, rdx

	mov r10, 1
	mov r8, 1
	call count_slope
	imul r15, rax

	solve2_call_count_slope 3, 1
	solve2_call_count_slope 5, 1
	solve2_call_count_slope 7, 1
	solve2_call_count_slope 1, 2

	mov rax, r15
	pop r15
	pop r14
	pop r13
	pop r12
	ret

.global _start
_start:
	chooseimpl r15, solve1, solve2
	mov [mode], r15

	sub rsp, 32	
	mov r12, rsp
	xor r13, r13
	xor r15, r15

.L_start.input_loop:
	mov rdi, r12
	call readline
	xor rax, rax
	cmp rax, rbx
	je .L_start.input_loop_end
	sub rsp, rbx
	inc r15
	add r13, rbx
	mov r14, rbx
	mov rdi, rsp
	mov rsi, r12
	mov rdx, rbx
	call strncpy
	mov rdi, rsp
	mov rsi, r14
	call reverse_string
	jmp .L_start.input_loop

.L_start.input_loop_end:
	mov rdi, rsp
	mov rsi, r13
	call reverse_string

	mov rdi, rsp
	mov rsi, r14
	mov rdx, r15
	mov rax, [mode]
	call rax

	mov rdi, rax
	mov rsi, r12
	call itos

	mov rdi, r12
	mov rsi, rax
	call putsn
	call putnl

	mov rax, SYS_EXIT
	xor rdi, rdi
	syscall
