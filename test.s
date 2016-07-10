	.org 0

.ascii	"dynp"			# magic _number_
.long	0x00010000		# version (1.0.1 or something)
.quad	plugin_name - .text	# pointer to plugin name (at the very bottom)

exports_len:
.quad	(eot-exports)/24	# 12 bytes per entry
exports:
.quad	subsi_symbol - .text
.quad	0
export_subsi:
.quad	0 - .text		# subsi at: 0x400940, in executable

.quad	appstart_symbol - .text
.quad	0
export_test:
.quad	appstart_function - .text
eot:

subsi_symbol:
.asciz	"test_func"

appstart_symbol:
.asciz "start"

	.text

_p1:	.long 48
_p2:	.long 21

appstart_function:
	pushq	rbp
	movq	rsp, rbp

	movq	rdi, -8(rbp)		# get parameter 1
	movq	rsi, -16(rbp)		# get parameter 2

	movq	-8(rbp), rdx		# work with
	movq	-16(rbp), rax

	addq	$13, rax		# doubletes


	movq	$4, rdi
	movq	$12, rsi
	callq	*export_subsi(rip)



	popq	rbp
	ret

	movq	rax, -8(rbp)
	movq	rax, -16(rbp)

	pushq	_p2
	pushq	_p1

	movq	rax, 16(rbp)
	ret

# placed at the end, you can simply search from here for the
# next '0' to find the end of the plugin
plugin_name:
.asciz	"root"
