# type: (int* numbers, int len) -> int
.global ints_max
ints_max:
	xor rax, rax
	xor rbx, rbx
.Lints_max.loop:
	cmp rsi, rbx
	je .Lints_max.end
	mov rcx, [rdi]
	add rdi, 8
	dec rsi
	cmp rcx, rax
	jle .Lints_max.loop
	mov rax, rcx
	jmp .Lints_max.loop
.Lints_max.end:
	ret

# type: (int* numbers, int len) -> void
.global ints_sort
ints_sort:
	xor rax, rax
	mov rbx, 1
.Lints_sort.inner:
	# lea rcx, [rsi - 1]
	mov rcx, rsi
	cmp rbx, rcx
	jge .Lints_sort.continue
	lea rcx, [rbx - 1]
	mov r8, [rdi + rcx * 8]
	mov r9, [rdi + rbx * 8]
	cmp r8, r9
	jle .Lints_sort.inner_continue
	mov rax, 1
	mov [rdi + rcx * 8], r9
	mov [rdi + rbx * 8], r8
.Lints_sort.inner_continue:
	inc rbx
	jmp .Lints_sort.inner
.Lints_sort.continue:
	dec rsi
	xor r8, r8
	cmp rax, r8
	jne ints_sort
	ret
