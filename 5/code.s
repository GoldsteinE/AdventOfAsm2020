.include "stdlib.s"

.section .data

buf: .ds.b 16

.section .text

# type: (int* numbers, int len) -> int
.global solve1
solve1:
	jmp ints_max

# type: (int* numbers, int len) -> int
.global solve2
solve2:
	push rdi
	call ints_sort
	pop rdi
	mov rax, 2
.Lsolve2.loop:
	mov r8, [rdi]
	mov r9, [rdi + 8]
	sub r9, r8
	cmp r9, rax
	je .Lsolve2.end
	add rdi, 8
	jmp .Lsolve2.loop
.Lsolve2.end:
	lea rax, [r8 + 1]
	ret

# type: (char* bin, int len, char one) -> int
.global parse_bin
parse_bin:
	xor rax, rax
	xor rbx, rbx
.Lparse_bin.loop:
	cmp rsi, rbx
	je .Lparse_bin.end
	shl rax, 1
	mov cl, [rdi]
	inc rdi
	dec rsi
	cmp cl, dl
	sete cl
	or al, cl
	jmp .Lparse_bin.loop
.Lparse_bin.end:
	ret

.global _start
_start:
	chooseimpl r15, solve1, solve2

	xor r13, r13
.L_start.input_loop:
	mov rdi, offset buf
	call readline
	xor rcx, rcx
	cmp rbx, rcx
	je .L_start.input_loop_end
	mov rdi, offset buf
	mov rsi, 7
	mov rdx, 66  # 'B'
	call parse_bin
	mov r14, rax
	mov rdi, offset buf
	add rdi, 7
	mov rsi, 3
	mov rdx, 82  # 'R'
	call parse_bin
	imul r14, 8
	add r14, rax
	push r14
	inc r13
	jmp .L_start.input_loop
.L_start.input_loop_end:

	mov rdi, rsp
	mov rsi, r13
	call r15

	mov rdi, rax
	mov rsi, offset buf
	call itos
	mov rdi, offset buf
	mov rsi, rax
	call putsn
	call putnl

	mov rax, SYS_EXIT
	xor rdi, rdi
	syscall
