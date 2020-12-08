.intel_syntax noprefix

.include "constants.s"
.include "strings.s"

.section .text

.macro trysyscall
	syscall
	# rcx may be clobbered by syscall anyway
	xor rcx, rcx
	cmp rax, rcx
	jl trysyscall_die
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
	# r9 is zero
	xor r9, r9
	# r10 is newline
	mov r10, 10
	mov rdi, STDIN
.Lreadline.loop:
	mov rax, SYS_READ
	mov rdx, 1
	trysyscall
	cmp rax, r9
	je .Lreadline.end
	mov rcx, rax
	mov rax, 1
	mov r8b, [rsi]
	cmp r8b, r10b
	je .Lreadline.end
	add rsi, rcx
	jmp .Lreadline.loop
.Lreadline.end:
	movb [rsi], 0
	sub rsi, rbx
	mov rbx, rsi
	ret
