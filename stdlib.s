.ifndef included_stdlib
included_stdlib:

.intel_syntax noprefix

.include "constants.s"
.include "strings.s"
.include "lists.s"

.section .data
printn_buf: .ds.b 64

.section .text

# Choose between first and second part of the task
.macro chooseimpl reg, first, second
	mov \reg, offset \first
	mov rax, [rsp]
	mov rbx, 1
	cmp rax, rbx
	je .Lchooseimpl.end
	mov \reg, offset \second
	.Lchooseimpl.end:
.endm

.macro allow_tests
	.ifdef testing_included
		jmp run_tests
	.endif
.endm

.macro exit code
	mov rax, SYS_EXIT
	mov rdi, \code
	syscall
.endm

.macro print name
	mov rdi, offset \name
	mov rsi, \name\()_len
	call putsn
.endm

.macro printn reg
	mov rdi, \reg
	mov rsi, offset printn_buf
	call itos
	mov rdi, offset printn_buf
	mov rsi, rax
	call putsn
.endm

.macro trysyscall
	syscall
	test rax, rax
	js trysyscall_die
.endm

# type: () -> !
.global trysyscall_die
trysyscall_die:
	mov rdi, rax
	neg rdi
	mov rax, SYS_EXIT
	syscall

# type: (int fd, char* buf, int n) -> void
.global fputsn
fputsn:
	mov rax, SYS_WRITE
	trysyscall
	cmp rax, rdx
	je .Lfputsn.end
	sub rdx, rax
	add rsi, rax
	jmp fputsn
.Lfputsn.end:
	ret

# type: (int fd, char* buf) -> void
.global fputs
fputs:
	push rdi
	push rsi
	mov rdi, rsi
	call strlen
	pop rsi
	pop rdi
	mov rdx, rax
	jmp fputsn

# type: (char* buf, int n) -> void
.global putsn
putsn:
	mov rdx, rsi
	mov rsi, rdi
	mov rdi, STDOUT
	jmp fputsn

# type: (char* buf) -> void
.global puts
puts:
	mov rsi, rdi
	mov rdi, STDOUT
	jmp fputs

# type: (int fd) -> void
.global fputnl
fputnl:
	mov rsi, offset newline
	mov rdx, 1
	jmp fputsn

# type: () -> void
.global putnl
putnl:
	mov rdi, STDOUT
	jmp fputnl

# type: (char* buf) -> (bool newline, int num)
# First return value is true if eof isn't reached yet
.global readline
readline:
	mov rbx, rdi
	mov rsi, rdi
	# r10 is newline
	mov r10, 10
	mov rdi, STDIN
.Lreadline.loop:
	mov rax, SYS_READ
	mov rdx, 1
	trysyscall
	test rax, rax
	jz .Lreadline.end
	mov r8b, [rsi]
	cmp r8b, r10b
	je .Lreadline.end
	inc rsi
	jmp .Lreadline.loop
.Lreadline.end:
	sub rsi, rbx
	mov rbx, rsi
	ret

.endif
