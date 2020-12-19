.include "stdlib.s"

.section .data
buf: .ds.b 256

.section .text

# type: (char* line, int len) -> int
# First bit from the left corresponds to the letter 'a', second to the 'b' and so on
.global parse_line
parse_line:
	xor rax, rax
	xor rbx, rbx
.Lparse_line.loop:
	cmp rsi, rbx
	je .Lparse_line.end
	mov cl, [rdi]
	sub cl, 97  # 'a'
	mov r8, 1
	shl r8, cl
	or rax, r8
	inc rdi
	dec rsi
	jmp .Lparse_line.loop
.Lparse_line.end:
	ret

# type: wtf
# does "or r13, rax"
or_r13_rax:
	or r13, rax
	ret

# type: wtf
# does "and r13, rax"
and_r13_rax:
	and r13, rax
	ret

.global _start
_start:
	xor r14, r14  # Answer
	xor r13, r13  # Local answer
	xor r12, r12  # Is everything over?
	mov r15, offset or_r13_rax
	mov rax, [rsp]
	mov rbx, 1
	cmp rax, rbx
	je .L_start.loop
	mov r15, offset and_r13_rax
	mov r13, 67108863  # 0b{'1' x 26}
	push r13
.L_start.loop:
	mov rdi, offset buf
	call readline
	xor rcx, rcx
	cmp rax, rcx
	je .L_start.loop_end
	cmp rbx, rcx
	je .L_start.count_group
	mov rdi, offset buf
	mov rsi, rbx
	call parse_line
	call r15
	jmp .L_start.loop
.L_start.count_group:
	xor rbx, rbx
	xor rdx, rdx
	mov rcx, r13
	mov r13, [rsp]
.L_start.count_loop:
	cmp rcx, rbx
	je .L_start.loop_continue
	mov rdx, rcx
	and rdx, 1
	add r14, rdx
	shr rcx, 1
	jmp .L_start.count_loop
.L_start.loop_end:
	inc r12
	jmp .L_start.count_group
.L_start.loop_continue:
	xor rcx, rcx
	cmp rcx, r12
	je .L_start.loop
	mov rdi, r14
	mov rsi, offset buf
	call itos
	mov rdi, offset buf
	mov rsi, rax
	call putsn
	call putnl

	add rsp, 8
	mov rax, SYS_EXIT
	xor rdi, rdi
	syscall
