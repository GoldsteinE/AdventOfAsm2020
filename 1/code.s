.include "stdlib.s"

.section .text

# type: (int* start, int* end) -> int
.global find2020
find2020:
	mov rax, rdi
	mov rbx, rdi
	mov r8, 2020
.Lfind2020.loop:
	mov rcx, [rax]
	mov rdx, [rbx]
	add rcx, rdx
	cmp rcx, r8
	je .Lfind2020.end
	add rbx, 8
	cmp rbx, rsi
	jg .Lfind2020.continue
	jmp .Lfind2020.loop
.Lfind2020.continue:
	mov rbx, rax
	add rax, 8
	cmp rax, rsi
	jg .Lfind2020.error
	jmp .Lfind2020.loop
.Lfind2020.error:
	mov rax, SYS_EXIT
	mov rdi, 255
	syscall
.Lfind2020.end:
	mov rax, [rax]
	imul rax, rdx
	ret

# type: (int* start, int* end) -> int
.global find3_2020
find3_2020:
	mov rax, rdi
	mov rbx, rdi
	mov rcx, rdi
	mov r8, 2020
	push rdi
.Lfind3_2020.loop:
	mov rdx, [rax]
	mov r9, [rbx]
	mov r10, [rcx]
	add rdx, r9
	add rdx, r10
	cmp rdx, r8
	je .Lfind3_2020.end
	add rcx, 8
	cmp rcx, rsi
	jg .Lfind3_2020.inner_continue
	jmp .Lfind3_2020.loop
.Lfind3_2020.inner_continue:
	mov rcx, [rsp]
	add rbx, 8
	cmp rbx, rsi
	jg .Lfind3_2020.outer_continue
	jmp .Lfind3_2020.loop
.Lfind3_2020.outer_continue:
	mov rbx, [rsp]
	mov rcx, [rsp]
	add rax, 8
	cmp rax, rsi
	jg .Lfind3_2020.error
	jmp .Lfind3_2020.loop
.Lfind3_2020.error:
	mov rax, SYS_EXIT
	mov rdi, 255
	syscall
.Lfind3_2020.end:
	mov rax, [rax]
	imul rax, r9
	imul rax, r10
	add rsp, 8
	ret

.global _start
_start:
	sub rsp, 16
	mov r13, rsp

.L_start.input_loop:
	mov rdi, r13
	call readline
	mov r14, rax

	xor rcx, rcx
	cmp rcx, rbx
	je .L_start.input_loop_end

	mov rdi, r13
	mov rsi, rbx
	call stoi
	push rax

	xor rcx, rcx
	cmp rcx, r14
	jne .L_start.input_loop
.L_start.input_loop_end:

	mov rdi, rsp
	lea rsi, [r13 - 8]

	mov r8, [r13 + 16]
	mov r9, 1
	cmp r8, r9
	jne .L_start.mode3
.L_start.mode2:
	call find2020
	jmp .L_start.mode_end
.L_start.mode3:
	call find3_2020
.L_start.mode_end:

	mov rdi, rax
	mov rsi, r13
	call itos

	mov rdi, r13
	mov rsi, rax
	call putsn
	call putnl

	mov rax, SYS_EXIT
	xor rdi, rdi
	syscall
