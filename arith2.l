GAS LISTING arith2.s 			page 1


 GNU assembler version 2.25 (x86_64-linux-gnu)
	 using BFD version (GNU Binutils for Debian) 2.25.
 options passed	: -g -mnaked-reg --listing-lhs-width=2 --listing-lhs-width2=4 --listing-rhs-width=80 -aghlms=arith2.l 
 input file    	: arith2.s
 output file   	: arith2.o
 target        	: x86_64-pc-linux-gnu
 time stamp    	: 2015-10-10T14:07:53.000+0200

GAS LISTING arith2.s 			page 2


   1                       	#	.data
   2                       	
   3                       		.org 0
   4                       	
   5 0000 64796E70          	.ascii	"dynp"			# magic _number_
   6 0004 00000100          	.long	0x00010000		# version (1.0.1 or something)
   7 0008 88000000 00000000 	.quad	plugin_name - .text	# pointer to plugin name (at the very bottom)
   8                       	
   9                       	exports_len:
  10 0010 02000000 00000000 	.quad	(eot-exports)/24	# 12 bytes per entry
  11                       	exports:
  12 0018 48000000 00000000 	.quad	subsi_symbol - .text
  13 0020 02000000 00000000 	.quad	2
  14                       	export_subsi:
  15 0028 00000000 00000000 	.quad	0 - .text		# subsi at: 0x400940, in executable
  16                       	
  17 0030 4E000000 00000000 	.quad	test_symbol - .text
  18 0038 00000000 00000000 	.quad	0
  19                       	export_test:
  20 0040 5E000000 00000000 	.quad	test_function - .text
  21                       	eot:
  22                       	
  23                       	subsi_symbol:
  24 0048 73756273 6900     	.asciz	"subsi"
  25                       	
  26                       	test_symbol:
  27 004e 74657374 756E6700 	.asciz "testung"
  28                       	
  29                       		.text
  30                       	
  31 0056 30000000          	_p1:	.long 48
  32 005a 15000000          	_p2:	.long 21
  33                       	
  34                       	test_function:
  35 005e 55                		pushq	rbp
  36 005f 4889E5            		movq	rsp, rbp
  37                       	
  38 0062 48897DF8          		movq	rdi, -8(rbp)		# get parameter 1
  39 0066 488975F0          		movq	rsi, -16(rbp)		# get parameter 2
  40                       	
  41 006a 488B55F8          		movq	-8(rbp), rdx		# work with
  42 006e 488B45F0          		movq	-16(rbp), rax
  43                       	
  44                       	
  45 0072 48C7C704 000000   		movq	$4, rdi
  46 0079 48C7C60C 000000   		movq	$12, rsi
  47 0080 FF15A2FF FFFF     		callq	*export_subsi(rip)
  48                       	
  49                       	
  50                       	
  51 0086 5D                		popq	rbp
  52 0087 C3                		ret
  53                       	
  54                       	# placed at the end, you can simply search from here for the
  55                       	# next '0' to find the end of the plugin
  56                       	plugin_name:
  57 0088 61726974 6800     	.asciz	"arith"
GAS LISTING arith2.s 			page 3


  58                       	
GAS LISTING arith2.s 			page 4


DEFINED SYMBOLS
            arith2.s:56     .text:0000000000000088 plugin_name
            arith2.s:9      .text:0000000000000010 exports_len
            arith2.s:21     .text:0000000000000048 eot
            arith2.s:11     .text:0000000000000018 exports
            arith2.s:23     .text:0000000000000048 subsi_symbol
            arith2.s:14     .text:0000000000000028 export_subsi
            arith2.s:26     .text:000000000000004e test_symbol
            arith2.s:19     .text:0000000000000040 export_test
            arith2.s:34     .text:000000000000005e test_function
            arith2.s:31     .text:0000000000000056 _p1
            arith2.s:32     .text:000000000000005a _p2

NO UNDEFINED SYMBOLS
