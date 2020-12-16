.include "stdlib.s"

.section .rodata

byr: .ascii "byr"
iyr: .ascii "iyr"
eyr: .ascii "eyr"
hgt: .ascii "hgt"
hcl: .ascii "hcl"
ecl: .ascii "ecl"
pid: .ascii "pid"

cm: .ascii "cm"
in: .ascii "in"

amb: .ascii "amb"
blu: .ascii "blu"
brn: .ascii "brn"
gry: .ascii "gry"
grn: .ascii "grn"
hzl: .ascii "hzl"
oth: .ascii "oth"

  valid: .ascii "V"
invalid: .ascii "I"

.section .data

buf: .ds.b 256

.section .text

# "Header" of parameter check
# After this macro, (char* rdi, int rsi) specify parameter value
.macro check_exists param, bit, next
	.Lcheck_line.\param:
		mov rdi, [rsp + 24]     # Left
		mov rsi, offset \param  # Right
		mov rdx, 3              # Len
		call strncmp
		xor rdi, rdi
		cmp rdi, rax
		je .Lcheck_line.\next
		or r14, \bit
		mov rdi, [rsp + 24]
		add rdi, 4              # Stripping `xyz:`
		mov rsi, [rsp + 16]
		sub rsi, 4
.endm

.macro check_number low, high, bit, next
	push rdi
	push rsi
	call isdigit
	pop rsi
	pop rdi
	xor rbx, rbx
	cmp rax, rbx
	je .Lcheck_line.\next
	call stoi
	mov rbx, \low
	cmp rax, rbx
	jl .Lcheck_line.\next
	mov rbx, \high
	cmp rax, rbx
	jg .Lcheck_line.\next
	or r15, \bit
	jmp .Lcheck_line.\next
.endm

.macro check_string string, happy
	push rdi
	push rsi
	mov rsi, offset \string
	mov rdx, 3
	call strncmp
	pop rsi
	pop rdi
	xor rbx, rbx
	cmp rax, rbx
	jne \happy
.endm

# type: (char* line, int len) -> (u8, u8)
# Each bit of return value corresponds to presence/validity
# of one of the parameters:
# 0b0000_0001 / 01: byr / Birth year
# 0b0000_0010 / 02: iyr / Issue year
# 0b0000_0100 / 04: eyr / Expiration year
# 0b0000_1000 / 08: hgt / Height
# 0b0001_0000 / 16: hcl / Hair color
# 0b0010_0000 / 32: ecl / Eye color
# 0b0100_0000 / 64: pid / Passport ID
# So:
# 0b0111_1111 / 127     / Passport is valid
.global check_line
check_line:
	push r14
	push r15
	xor r14, r14
	xor r15, r15
	mov rdx, rsi
	sub rsp, 32
	mov [rsp + 24], rdi
.Lcheck_line.loop:
	mov rsi, 32  # Space
	call split
	xor rsi, rsi
	cmp rax, rsi
	je .Lcheck_line.end
	mov [rsp + 16], rax  # int left_len
	mov [rsp + 8], rbx   # char* right
	mov [rsp], rcx       # int right_len

	check_exists byr, 1, iyr
		check_number 1920, 2002, 1, iyr

	check_exists iyr, 2, eyr
		check_number 2010, 2020, 2, eyr

	check_exists eyr, 4, hgt
		check_number 2020, 2030, 4, hgt

	check_exists hgt, 8, hcl
		mov rbx, 3
		cmp rsi, rbx
		jl .Lcheck_line.hcl
		push rdi
		push rsi
		add rdi, rsi
		sub rdi, 2
		mov rsi, offset cm
		mov rdx, 2
		call strncmp
		pop rsi
		pop rdi
		xor rbx, rbx
		cmp rax, rbx
		je .Lcheck_line.hgt_in
		sub rsi, 2
		check_number 150, 193, 8, hcl
	.Lcheck_line.hgt_in:
		push rdi
		push rsi
		add rdi, rsi
		sub rdi, 2
		mov rsi, offset in
		mov rdx, 2
		call strncmp
		pop rsi
		pop rdi
		xor rbx, rbx
		cmp rax, rbx
		sub rsi, 2
		check_number 59, 76, 8, hcl

	check_exists hcl, 16, ecl
		mov rbx, 7
		cmp rsi, rbx
		jne .Lcheck_line.ecl
		mov bl, [rdi]
		mov cl, 35  # '#'
		cmp bl, cl
		jne .Lcheck_line.ecl
		inc rdi
		dec rsi
		call ishex
		xor rbx, rbx
		cmp rax, rbx
		je .Lcheck_line.ecl
		or r15, 16

	check_exists ecl, 32, pid
		mov rbx, 3
		cmp rsi, rbx
		jne .Lcheck_line.pid
		check_string amb, .Lcheck_line.hcl_happy
		check_string blu, .Lcheck_line.hcl_happy
		check_string brn, .Lcheck_line.hcl_happy
		check_string gry, .Lcheck_line.hcl_happy
		check_string grn, .Lcheck_line.hcl_happy
		check_string hzl, .Lcheck_line.hcl_happy
		check_string oth, .Lcheck_line.hcl_happy
		jmp .Lcheck_line.pid
	.Lcheck_line.hcl_happy:
		or r15, 32

	check_exists pid, 64, continue
		mov rbx, 9
		cmp rsi, rbx
		jne .Lcheck_line.continue
		call isdigit
		xor rbx, rbx
		cmp rax, rbx
		je .Lcheck_line.continue
		or r15, 64

.Lcheck_line.continue:
	mov rdi, [rsp + 8]
	mov rdx, [rsp]
	mov [rsp + 24], rdi
	jmp .Lcheck_line.loop
.Lcheck_line.end:
	mov rax, r14
	mov rbx, r15
	add rsp, 32
	pop r15
	pop r14
	ret

.global _start
_start:
	xor r12, r12
	xor r13, r13
.L_start.outer_loop:
	xor r14, r14
	xor r15, r15
.L_start.inner_loop:
	mov rdi, offset buf
	call readline
	xor rdi, rdi
	cmp rdi, rax
	je .L_start.loop_end
	cmp rdi, rbx
	je .L_start.outer_loop_continue
	mov rdi, offset buf
	mov rsi, rbx
	call check_line
	or r14, rax
	or r15, rbx
	jmp .L_start.inner_loop
.L_start.outer_loop_continue:
	mov rdi, 127
	cmp r14, rdi
	jne .L_start.outer_loop
	inc r12
	cmp r15, rdi
	jne .L_start.outer_loop
	inc r13
	jmp .L_start.outer_loop
.L_start.loop_end:
	mov rdi, 127
	cmp r14, rdi
	jne .L_start.end
	inc r12
	cmp r15, rdi
	jne .L_start.end
	inc r13
.L_start.end:
	mov rdi, r12
	mov rsi, offset buf
	call itos
	mov rdi, offset buf
	mov rsi, rax
	call putsn
	call putnl

	mov rdi, r13
	mov rsi, offset buf
	call itos
	mov rdi, offset buf
	mov rsi, rax
	call putsn
	call putnl

	mov rax, SYS_EXIT
	xor rdi, rdi
	syscall
