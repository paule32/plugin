
#	.data

	.org 0

# the whole plugin is reflected in C by

# struct plugin
# {
#  int                  magic;	// "dynp"
#  int                  version;
#  char*                name;
#  struct exports_table et;
# }


.ascii	"dynp"			# magic _number_
.long	0x00010000		# version (1.0.0 or something)
.long	plugin_name - .text	# pointer to plugin name (at the very bottom)

# each descriptor in the exports table consists of three
# entries:
#  - pointer to the exported symbol name (ascii data)
#  - a type identifier	(0 - function, 1 - data)
#  - pointer to the actual funtion
#
# note: `type` is given as quad/int for alignment
#       purposes only
#
# c declaration is as follows:
#
# struct exports_entry
# {
#   unsigned int exp_name;
#   unsigned int type;
#   unsigned int func_ptr;
# }
# // we use ints to avoid chains of casts when relocating
# // (ints add fine to a base pointer)
#
# struct exports[exports_len];
#

exports_len:
.long	(eot-exports)/12	# 12 bytes per entry
exports:
.long	add_symbol - .text
.long	0
.long	add_function - .text

.long	sub_symbol - .text
.long	0
.long	sub_function - .text

.long	mul_symbol - .text
.long	0
.long	mul_function - .text

.long	div_symbol - .text
.long	0
.long	div_function - .text
eot:

add_symbol:
.asciz	"add"

sub_symbol:
.asciz	"sub"

mul_symbol:
.asciz	"mul"

div_symbol:
.asciz	"div"

#	.text

# !!! failure: this doesn not clean edx before division
#              (nor does it restore the original value
#              before returning)
div_function:			# int div(int a, int b); // a/b
	movq	rdi,rax
	divq	rsi
	ret

# !!! failure: this trashes edx and does not restore it
mul_function:			# int mul(int a, int b);
	movq	rdi,rax		# a
	mulq	rsi
	ret

sub_function:			# int sub(int a, int b); // a-b
	movq	rdi,rax		# a
	subq	rsi,rax		# b
	ret

add_function:			# int add(int a, int b);
	movq	rdi,rax		# a
	addq	rsi,rax		# b
	ret

# placed at the end, you can simply search from here for the
# next '0' to find the end of the plugin
plugin_name:
.asciz	"arith"







