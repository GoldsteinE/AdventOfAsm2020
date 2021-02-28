.include "stdlib.s"

.global testing_included
testing_included:

.section .data
testh_buf: .ds.b 256
testh_expect_save_rdi: .quad 0
testh_expect_save_rsi: .quad 0

.section .rodata

testh_ellipsis: .ascii "... "
.set testh_ellipsis_len, (. - testh_ellipsis)

testh_colon: .ascii ": "
.set testh_colon_len, (. - testh_colon)

testh_expected: .ascii "expected "
.set testh_expected_len, (. - testh_expected)

testh_found: .ascii ", found "
.set testh_found_len, (. - testh_found)

testh_failed: .ascii "\033[31mfail\033[0m\n"
.set testh_failed_len, (. - testh_failed)

testh_passed: .ascii "\033[32mok\033[0m\n"
.set testh_passed_len, (. - testh_passed)

.macro t name
	jmp test_\name\()

	test_\name\()_name: .ascii "\name\()"
	.set test_\name\()_name_len, (. - test_\name\()_name)

	.global test_\name\()
	test_\name\():
		.ifdef testh_t_was_called
			print testh_passed
		.endif

		print test_\name\()_name
		print testh_ellipsis

	.set testh_t_was_called, 0
.endm

.macro tests
	.section .text
	.global tests
	tests:
.endm

.macro end
	.ifdef testh_t_was_called
		print testh_passed
	.endif

	ret
.endm

.section .text

.global run_tests
run_tests:
	call tests
	exit 0

# type: (int found, int expected, char* reason, int reason_len) -> void
# Expected to be jmp'd from expect macro
expect_fail:
	# If we're here, we don't longer care about outer func registers
	# Or stack, or whatever
	push rdx
	push r10
	sub rsp, 16
	mov [rsp + 8], rdi
	mov [rsp], rsi
	print testh_failed
	print testh_expected
	printn [rsp]
	print testh_found
	add rsp, 8
	printn [rsp]
	add rsp, 8

	mov rax, [rsp]
	test rax, rax
	jz .Lexpect_fail.end

	print testh_colon
	pop rsi
	pop rdi
	call putsn

.Lexpect_fail.end:
	call putnl
	exit 1

.macro _expect_inner reason:vararg
	jmp 1f
	2:	
	.ascii "\reason\()"
	1:
	push rdx
	push r10
	mov rdx, offset 2b
	mov r10, offset 1b
	sub r10, offset 2b
	cmp rdi, rsi
	jne expect_fail
	pop r10
	pop rdx
.endm

.macro expect reg, val, reason:vararg
	# Can't afford to save these on stack: \reg or \val may contain rsp
	mov [testh_expect_save_rdi], rdi
	mov [testh_expect_save_rsi], rsi
	mov rdi, \reg
	mov rsi, \val
	_expect_inner \reason
	mov rdi, [testh_expect_save_rdi]
	mov rsi, [testh_expect_save_rsi]
.endm

.macro expectb reg, val, reason:vararg
	mov [testh_expect_save_rdi], rdi
	mov [testh_expect_save_rsi], rsi
	mov dl, \reg
	mov sil, \val
	# Now we can push, yay!
	push rax
	# Zeroing bits of rdi and rsi
	xor rax, rax
	mov al, dl
	mov rdi, rax
	mov al, sil
	mov rsi, rax
	pop rax
	_expect_inner \reason
	mov rdi, [testh_expect_save_rdi]
	mov rsi, [testh_expect_save_rsi]
.endm
