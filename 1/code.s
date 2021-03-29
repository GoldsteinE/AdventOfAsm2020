.include "stdlib.s"

.section .data
buffer: .fill 16

.section .text

# type: (int* start, int* end) -> int
.global find2_2020
find2_2020:
	mov rax, rdi
	mov r8, 2020
.Lfind2_2020.outer:
	mov rbx, rax
.Lfind2_2020.inner:
	mov rcx, [rax]
	mov rdx, [rbx]
	add rcx, rdx
	cmp rcx, r8
	je .Lfind2_2020.end
	add rbx, 8
	cmp rbx, rsi
	jle .Lfind2_2020.inner
	add rax, 8
	cmp rax, rsi
	jle .Lfind2_2020.outer
	exit 255
.Lfind2_2020.end:
	mov rax, [rax]
	imul rax, rdx
	ret

# type: (int* start, int* end) -> int
.global find3_2020
find3_2020:
	mov rax, rdi
	mov r8, 2020
.Lfind3_2020.outer:
	mov rbx, rax
.Lfind3_2020.middle:
	mov rcx, rbx
.Lfind3_2020.inner:
	mov rdx, [rax]
	mov r9,  [rbx]
	add rdx, r9
	mov r9,  [rcx]
	add rdx, r9
	cmp rdx, r8
	je .Lfind3_2020.end
	add rcx, 8
	cmp rcx, rsi
	jle .Lfind3_2020.inner
	add rbx, 8
	cmp rbx, rsi
	jle .Lfind3_2020.middle
	add rax, 8
	cmp rax, rsi
	jle .Lfind3_2020.outer
	exit 255
.Lfind3_2020.end:
	mov rax, [rax]
	imul rax, r9
	mov r9,  [rbx]
	imul rax, r9
	ret

.global _start
_start:
	allow_tests
	chooseimpl r15, find2_2020, find3_2020

	mov r13, rsp

.L_start.input_loop:
	mov rdi, offset buffer
	call readline

	test rbx, rbx
	jz .L_start.input_loop_end
	mov r14, rax

	mov rdi, offset buffer
	mov rsi, rbx
	call stoi
	push rax

	test r14, r14
	jnz .L_start.input_loop
.L_start.input_loop_end:

	mov rdi, rsp
	lea rsi, [r13 - 8]
	call r15

	mov rdi, rax
	mov rsi, offset buffer
	call itos

	mov rdi, offset buffer
	mov rsi, rax
	call putsn
	call putnl

	exit 0
