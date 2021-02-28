.include "stdlib.s"
.include "testing.s"

.section .rodata
string_fixture: .asciz "this text contains 32 characters"
strncmp_fixture: .ascii "foo foo frog"
hex_fixture: .ascii "0123456789abcdefg"

.section .text

.global _start
_start:
	allow_tests

tests
	t strlen
		mov rdi, offset string_fixture
		call strlen
		expect rax, 32, wrong string length

	t strlen_empty
		push 0
		mov rdi, rsp
		call strlen
		expect rax, 0, not zero on empty string
		add rsp, 8

	t strncpy
		push 0
		mov rdi, rsp
		mov rsi, offset string_fixture
		mov rdx, 4
		call strncpy
		expectb [rsp + 0], 116, letter t doesnt match
		expectb [rsp + 1], 104, letter h doesnt match
		expectb [rsp + 2], 105, letter i doesnt match
		expectb [rsp + 3], 115, letter s doesnt match
		pop rax
		shr rax, 32
		expect rax, 0, copied too much or corrupted memory

	t strncpy_zero
		# Passing NULL pointers so trying to copy anything would fail
		xor rdi, rdi
		xor rsi, rsi
		xor rdx, rdx
		call strncpy

	t strncmp_eq
		mov rdi, offset strncmp_fixture
		lea rsi, [strncmp_fixture + 4]
		mov rdx, 3
		call strncmp
		expect rax, 1, strings are equal

	t strncmp_ne
		mov rdi, offset strncmp_fixture
		lea rsi, [strncmp_fixture + 8]
		mov rdx, 3
		call strncmp
		expect rax, 0, strings are not equal

	t strncmp_zero
		# Passing NULL pointers so trying to read anything would fail
		xor rdi, rdi
		mov rsi, 0
		mov rdx, 0
		call strncmp
		expect rax, 1, empty strings are equal

	t isdigit_yes
		lea rdi, [string_fixture + 19]
		mov rsi, 2
		call isdigit
		expect rax, 1, 32 is a number

	t isdigit_no
		mov rdi, offset string_fixture
		mov rsi, 2
		call isdigit
		expect rax, 0, th is not a number

	t isdigit_zero
		# Passing NULL pointer so trying to read anything would fail
		mov rdi, 0
		mov rsi, 0
		call isdigit
		expect rax, 1, empty string kinda is a number

	t ishex_yes
		mov rdi, offset hex_fixture
		mov rsi, 16
		call ishex
		expect rax, 1, 0123456789abcdef is hex

	t ishex_no
		mov rdi, offset hex_fixture
		mov rsi, 17
		call ishex
		expect rax, 0, g is not hex

	t ishex_zero
		# Passing NULL pointer so trying to read anything would fail
		mov rdi, 0
		mov rsi, 0
		call ishex
		expect rax, 1, empty string kinda is hex

	t reverse_string_even
		push 0
		mov rdi, rsp
		mov rsi, offset string_fixture
		mov rdx, 4
		# strncpy is already tested, so this should be ok
		call strncpy
		mov rdi, rsp
		mov rsi, 4
		call reverse_string
		expectb [rsp + 0], 115, letter 1 is not s
		expectb [rsp + 1], 105, letter 2 is not i
		expectb [rsp + 2], 104, letter 3 is not h
		expectb [rsp + 3], 116, letter 4 is not t
		pop rax
		shr rax, 32
		expect rax, 0, corrupted memory after 4 letters

	t reverse_string_odd
		push 0
		mov rdi, rsp
		mov rsi, offset string_fixture
		mov rdx, 3
		call strncpy
		mov rdi, rsp
		mov rsi, 3
		call reverse_string
		expectb [rsp + 0], 105, letter 1 is not i
		expectb [rsp + 1], 104, letter 2 is not h
		expectb [rsp + 2], 116, letter 3 is not t
		pop rax
		shr rax, 24
		expect rax, 0, corrupted memory after 3 letters

	t reverse_string_zero
		# Passing NULL pointer so trying to read anything would fail
		mov rdi, 0
		mov rsi, 0
		call reverse_string

	t count_present
		mov rdi, offset string_fixture
		mov rsi, 116  # t
		mov rdx, 32
		call count
		expect rax, 5, fixture contains 5 letters t

	t count_absent
		mov rdi, offset string_fixture
		mov rsi, 113  # q
		mov rdx, 32
		call count
		expect rax, 0, fixture doesnt contain letter q

	t count_zero
		# Passing NULL pointer so trying to read anything would fail
		xor rdi, rdi
		xor rsi, rsi
		xor rdx, rdx
		call count
		expect rax, 0, empty string doesnt contain anything

	t split_present
		mov rdi, offset string_fixture
		mov rsi, 32  # space
		mov rdx, 32
		call split
		expect rax, 4, len of left part is wrong
		lea rax, [string_fixture + 5]
		expect rbx, rax, start of right part is wrong
		expect rcx, 27, len of right part is wrong

	t split_absent
		mov rdi, offset string_fixture
		mov rsi, 113  # q
		mov rdx, 32
		call split
		expect rax, 32, len of left part is wrong
		lea rax, [string_fixture + 32]
		expect rbx, rax, start of right part should be at the end of the string
		expect rcx, 0, right part should be empty

	t split_zero
		# Passing NULL pointer so trying to read anything would fail
		xor rdi, rdi
		xor rsi, rsi
		xor rdx, rdx
		call split
		expect rax, 0, left part should be empty
		expect rbx, 0, pointer should be untouched
		expect rcx, 0, right part should be empty

	t stoi
		mov rdi, offset hex_fixture
		mov rsi, 4
		call stoi
		expect rax, 123

	t itos
		push 0
		mov rdi, 123
		mov rsi, rsp
		call itos
		expect rax, 3, len of resulting string is wrong
		mov rdi, rsp
		lea rsi, [hex_fixture + 1]
		mov rdx, 3
		call strncmp
		expect rax, 1, string is not equal to 123
		add rsp, 8

	t itos_zero
		push 0
		mov rdi, 0
		mov rsi, rsp
		call itos
		expect rax, 1, len of resulting string is wrong
		mov rdi, rsp
		mov rsi, offset hex_fixture
		mov rdx, 1
		call strncmp
		expect rax, 1, string is not equal to 0
		add rsp, 8
end
