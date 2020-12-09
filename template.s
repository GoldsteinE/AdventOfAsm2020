.include "stdlib.s"

.section text

# type: ???
.global solve1
solve1:
	# Code
	ret

# type: ???
.global solve2
solve2:
	# Code
	ret

.global _start
_start:
	chooseimpl r15, solve1, solve2

	mov rax, SYS_EXIT
	xor rdi, rdi
	syscall
