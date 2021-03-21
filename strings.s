.section .text

# type: (char* buf) -> int
.global strlen
strlen:
	mov rax, rdi
.Lstrlen.loop:
	mov cl, [rax]
	test cl, cl
	jz .Lstrlen.end
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

# type: (char* left, char* right, int len) -> bool
.global strncmp
strncmp:
	mov rax, 1
	xor r8, r8
.Lstrncmp.loop:
	cmp rdx, r8
	je .Lstrncmp.end
	dec rdx
	mov bl, [rdi]
	mov cl, [rsi]
	inc rdi
	inc rsi
	cmp bl, cl
	je .Lstrncmp.loop
	xor rax, rax
.Lstrncmp.end:
	ret

# type: (char* buf, int len) -> bool
.global isdigit
isdigit:
	mov rax, 1
.Lisdigit.loop:
	xor rbx, rbx
	cmp rsi, rbx
	je .Lisdigit.end
	mov bl, [rdi]
	mov cl, 48  # '0'
	cmp bl, cl
	jl .Lisdigit.bad
	mov cl, 57  # '9'
	cmp bl, cl
	jg .Lisdigit.bad
	inc rdi
	dec rsi
	jmp .Lisdigit.loop
.Lisdigit.bad:
	xor rax, rax
.Lisdigit.end:
	ret

# type: (char* buf, int len) -> bool
.global ishex
ishex:
	mov rax, 1
.Lishex.loop:
	xor rbx, rbx
	cmp rsi, rbx
	je .Lishex.end
	mov bl, [rdi]
	mov cl, 48
	cmp bl, cl
	jl .Lishex.hex
	mov cl, 57
	cmp bl, cl
	jg .Lishex.hex
	jmp .Lishex.continue
.Lishex.hex:
	mov cl, 97
	cmp bl, cl
	jl .Lishex.bad
	mov cl, 102
	cmp bl, cl
	jg .Lishex.bad
.Lishex.continue:
	inc rdi
	dec rsi
	jmp .Lishex.loop
.Lishex.bad:
	xor rax, rax
.Lishex.end:
	ret

# type: (char* buf, int len) -> void
.global reverse_string
reverse_string:
	add rsi, rdi
	cmp rdi, rsi
	jge .Lreverse_string.end
	dec rsi
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
	add rsi, rdi
	xor rax, rax
	mov r9, 1
.Lstoi.loop:
	dec rsi
	xor rcx, rcx
	mov cl, [rsi]
	sub rcx, 48
	imul rcx, r9
	add rax, rcx
	imul r9, 10
	cmp rdi, rsi
	jne .Lstoi.loop
	ret

# type: (int n, char* buf) -> int
# Returns len of resulting string
.global itos
itos:
	mov rax, rdi
	mov rdi, rsi
	mov r9, 10
.Litos.loop:
	xor rdx, rdx
	div r9
	add rdx, 48
	mov [rsi], dl
	inc rsi
	test rax, rax
	jnz .Litos.loop
# End of loop
	sub rsi, rdi
	push rsi
	call reverse_string
	pop rax
	ret
