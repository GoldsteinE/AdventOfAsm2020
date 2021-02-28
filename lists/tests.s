.include "stdlib.s"
.include "testing.s"

.section .rodata
ints_list_fixture: .quad 3, -1, 1, 4, 9, 2

.section .text

.global _start
_start:
	allow_tests

tests
	t ints_max
		mov rdi, offset ints_list_fixture
		mov rsi, 6
		call ints_max
		expect rax, 9

	t ints_sort
		# Copying fixture to writeable memory
		sub rsp, 48
		mov rdi, rsp
		mov rsi, offset ints_list_fixture
		mov rdx, 48
		call strncpy
		mov rdi, rsp
		mov rsi, 6
		call ints_sort
		expect [rsp + 0], -1
		expect [rsp + 8], 1
		expect [rsp + 16], 2
		expect [rsp + 24], 3
		expect [rsp + 32], 4
		expect [rsp + 40], 9
		add rsp, 48
end
