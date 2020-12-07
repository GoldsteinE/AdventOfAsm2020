.intel_syntax noprefix

.set SYS_READ, 0
.set SYS_WRITE, 1
.set SYS_EXIT, 60

.set STDIN, 0
.set STDOUT, 1
.set STDERR, 2

.section .data

newline: .asciz "\n"

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

# type: (char* buf) -> int
.global strlen
strlen:
	mov rax, rdi
	xor rbx, rbx
.Lstrlen.loop:
	mov rcx, [rax]
	cmp rcx, rbx
	je .Lstrlen.end
	inc rax
	jmp .Lstrlen.loop
.Lstrlen.end:
	sub rax, rdi
	ret

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
	mov rdx, 2
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

# type: (char* buf, int len) -> int
.global stoi
stoi:
	mov rbx, rdi
	add rbx, rsi
	xor rax, rax
	mov r9, 1
.Lstoi.loop:
	dec rbx
	xor rcx, rcx
	mov cl, [rbx]	
	sub rcx, 48
	imul rcx, r9
	add rax, rcx
	imul r9, 10
	cmp rdi, rbx
	jne .Lstoi.loop
	ret

# type: (char* buf, int len) -> void
.global reverse_string
reverse_string:
	add rsi, rdi
	cmp rdi, rsi
	jge .Lreverse_string.end
	dec rsi
	xor rcx, rcx
	xor rdx, rdx
.Lreverse_string.loop:
	mov cl, [rsi]
	mov dl, [rdi]
	mov [rdi], cl
	mov [rsi], dl
	dec rsi
	inc rdi
	cmp rdi, rsi
	jl .Lreverse_string.loop
.Lreverse_string.end:
	ret

# type: (int n, char* buf) -> int
# Returns len of resulting string
.global itos
itos:
	mov rax, rdi
	mov rdi, rsi
	mov r9, 10
	xor r10, r10
.Litos.loop:
	xor rdx, rdx
	div r9
	add rdx, 48
	mov [rsi], dl
	inc rsi
	cmp rax, r10
	jne .Litos.loop
# End of loop
	movb [rsi], 0
	sub rsi, rdi
	push rsi
	call reverse_string
	pop rax
	ret
