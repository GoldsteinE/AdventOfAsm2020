.include "stdlib.s"

.section .data
password: .ascii "Password: "
lower: .ascii "Lower: "
upper: .ascii "Upper: "
character: .ascii "Character: "

.section .text

# type: (char* buf, int len)
#    -> (int l, int h, char c, char* rest, int len)
.global parse_line
parse_line:
	# Line: 1-3 a: abcde
	push r12
	push r13
	push r14
	push r15

	mov r12, rdi

	mov rdx, rsi
	mov rsi, 45  # Dash
	call split
	mov r12, rbx
	mov r13, rcx

	mov rsi, rax
	call stoi
	mov r14, rax

	mov rdi, r12
	mov rsi, 32  # Space
	mov rdx, r13
	call split

	mov rdi, r12
	mov rsi, rax
	mov r12, rbx
	mov r13, rcx
	call stoi

	mov rbx, rax
	mov rax, r14
	xor rcx, rcx
	mov cl, [r12]
	lea rdx, [r12 + 3]
	lea r8, [r13 - 3]

	pop r15
	pop r14
	pop r13
	pop r12	

	ret

# type: (char* buf, int len) -> bool
.global check_line1
check_line1:
	call parse_line
	push rax
	push rbx
	mov rdi, rdx	
	mov rsi, rcx
	mov rdx, r8
	call count
	pop rcx # Upper
	pop rbx # Lower
	mov rdx, rax
	xor rax, rax
	cmp rdx, rbx
	jl .Lcheck_line1.end
	cmp rdx, rcx
	jg .Lcheck_line1.end
	inc rax
.Lcheck_line1.end:
	ret


# type: (char* buf, int len) -> bool
.global check_line2
check_line2:
	call parse_line
	dec rax
	dec rbx
	mov rdi, rax
	add rdi, rdx
	mov rsi, [rdi]
	xor rax, rax
	cmp sil, cl
	jne .Lcheck_line2.second
	inc rax
.Lcheck_line2.second:
	mov rdi, rbx
	add rdi, rdx
	mov rsi, [rdi]
	cmp sil, cl
	jne .Lcheck_line2.end
	xor rax, 1
.Lcheck_line2.end:
	ret

.global _start
_start:
	chooseimpl r14, check_line1, check_line2

	xor r15, r15
	sub rsp, 128
.L_start.loop:
	mov rdi, rsp
	call readline
	xor rdi, rdi
	cmp rbx, rdi
	je .L_start.end
	mov rdi, rsp
	mov rsi, rbx
	call r14
	add r15, rax
	jmp .L_start.loop
.L_start.end:
	mov rdi, r15
	mov rsi, rsp
	call itos
	mov rdi, rsp
	mov rsi, rax
	call putsn
	call putnl
	mov rax, SYS_EXIT
	xor rdi, rdi
	syscall
