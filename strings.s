.section .text

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

# type: (char* dest, char* src, int len) -> void
.global strncpy
strncpy:
	xor rax, rax
.Lstrncpy.loop:
	cmp rdx, rax
	je .Lstrncpy.end
	mov cl, [rsi]
	mov [rdi], cl
	inc rsi
	inc rdi
	dec rdx
	jmp .Lstrncpy.loop
.Lstrncpy.end:
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

# type: (char* buf, char c, int len) -> int
.global count
count:
	xor rax, rax
	add rdx, rdi
.Lcount.loop:
	cmp rdi, rdx
	je .Lcount.end
	mov bl, [rdi]
	inc rdi
	cmp sil, bl
	jne .Lcount.loop
	inc rax
	jmp .Lcount.loop
.Lcount.end:
	ret

# type: (char* buf, char c, int len)
#    -> (int left_len, char* right, int right_len)
.global split
split:
	mov rbx, rdi
	mov rcx, rdx
	add rcx, rdi
.Lsplit.loop:
	cmp rbx, rcx
	jge .Lsplit.notfound
	mov dl, [rbx]
	inc rbx
	cmp dl, sil
	jne .Lsplit.loop
	lea rax, [rbx - 1]
	sub rax, rdi
	sub rcx, rbx
	ret
.Lsplit.notfound:
	mov rax, rbx
	sub rax, rdi
	xor rcx, rcx
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
