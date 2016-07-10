GAS LISTING arith1.s 			page 1


 GNU assembler version 2.25 (x86_64-linux-gnu)
	 using BFD version (GNU Binutils for Debian) 2.25.
 options passed	: -g -mnaked-reg --listing-lhs-width=2 --listing-lhs-width2=4 --listing-rhs-width=80 -aghlms=arith1.l 
 input file    	: arith1.s
 output file   	: arith1.o
 target        	: x86_64-pc-linux-gnu
 time stamp    	: 2015-10-10T14:07:53.000+0200

GAS LISTING arith1.s 			page 2


   1                       	
   2                       	#	.data
   3                       	
   4                       		.org 0
   5                       	
   6                       	# the whole plugin is reflected in C by
   7                       	
   8                       	# struct plugin
   9                       	# {
  10                       	#  int                  magic;	// "dynp"
  11                       	#  int                  version;
  12                       	#  char*                name;
  13                       	#  struct exports_table et;
  14                       	# }
  15                       	
  16                       	
  17 0000 64796E70          	.ascii	"dynp"			# magic _number_
  18 0004 00000100          	.long	0x00010000		# version (1.0.0 or something)
  19 0008 6C000000          	.long	plugin_name - .text	# pointer to plugin name (at the very bottom)
  20                       	
  21                       	# each descriptor in the exports table consists of three
  22                       	# entries:
  23                       	#  - pointer to the exported symbol name (ascii data)
  24                       	#  - a type identifier	(0 - function, 1 - data)
  25                       	#  - pointer to the actual funtion
  26                       	#
  27                       	# note: `type` is given as quad/int for alignment
  28                       	#       purposes only
  29                       	#
  30                       	# c declaration is as follows:
  31                       	#
  32                       	# struct exports_entry
  33                       	# {
  34                       	#   unsigned int exp_name;
  35                       	#   unsigned int type;
  36                       	#   unsigned int func_ptr;
  37                       	# }
  38                       	# // we use ints to avoid chains of casts when relocating
  39                       	# // (ints add fine to a base pointer)
  40                       	#
  41                       	# struct exports[exports_len];
  42                       	#
  43                       	
  44                       	exports_len:
  45 000c 04000000          	.long	(eot-exports)/12	# 12 bytes per entry
  46                       	exports:
  47 0010 40000000          	.long	add_symbol - .text
  48 0014 00000000          	.long	0
  49 0018 65000000          	.long	add_function - .text
  50                       	
  51 001c 44000000          	.long	sub_symbol - .text
  52 0020 00000000          	.long	0
  53 0024 5E000000          	.long	sub_function - .text
  54                       	
  55 0028 48000000          	.long	mul_symbol - .text
  56 002c 00000000          	.long	0
  57 0030 57000000          	.long	mul_function - .text
GAS LISTING arith1.s 			page 3


  58                       	
  59 0034 4C000000          	.long	div_symbol - .text
  60 0038 00000000          	.long	0
  61 003c 50000000          	.long	div_function - .text
  62                       	eot:
  63                       	
  64                       	add_symbol:
  65 0040 61646400          	.asciz	"add"
  66                       	
  67                       	sub_symbol:
  68 0044 73756200          	.asciz	"sub"
  69                       	
  70                       	mul_symbol:
  71 0048 6D756C00          	.asciz	"mul"
  72                       	
  73                       	div_symbol:
  74 004c 64697600          	.asciz	"div"
  75                       	
  76                       	#	.text
  77                       	
  78                       	# !!! failure: this doesn not clean edx before division
  79                       	#              (nor does it restore the original value
  80                       	#              before returning)
  81                       	div_function:			# int div(int a, int b); // a/b
  82 0050 4889F8            		movq	rdi,rax
  83 0053 48F7F6            		divq	rsi
  84 0056 C3                		ret
  85                       	
  86                       	# !!! failure: this trashes edx and does not restore it
  87                       	mul_function:			# int mul(int a, int b);
  88 0057 4889F8            		movq	rdi,rax		# a
  89 005a 48F7E6            		mulq	rsi
  90 005d C3                		ret
  91                       	
  92                       	sub_function:			# int sub(int a, int b); // a-b
  93 005e 4889F8            		movq	rdi,rax		# a
  94 0061 4829F0            		subq	rsi,rax		# b
  95 0064 C3                		ret
  96                       	
  97                       	add_function:			# int add(int a, int b);
  98 0065 4889F8            		movq	rdi,rax		# a
  99 0068 4801F0            		addq	rsi,rax		# b
 100 006b C3                		ret
 101                       	
 102                       	# placed at the end, you can simply search from here for the
 103                       	# next '0' to find the end of the plugin
 104                       	plugin_name:
 105 006c 61726974 6800     	.asciz	"arith"
 106                       	
 107                       	
 108                       	
 109                       	
 110                       	
 111                       	
 112                       	
GAS LISTING arith1.s 			page 4


DEFINED SYMBOLS
            arith1.s:104    .text:000000000000006c plugin_name
            arith1.s:44     .text:000000000000000c exports_len
            arith1.s:62     .text:0000000000000040 eot
            arith1.s:46     .text:0000000000000010 exports
            arith1.s:64     .text:0000000000000040 add_symbol
            arith1.s:97     .text:0000000000000065 add_function
            arith1.s:67     .text:0000000000000044 sub_symbol
            arith1.s:92     .text:000000000000005e sub_function
            arith1.s:70     .text:0000000000000048 mul_symbol
            arith1.s:87     .text:0000000000000057 mul_function
            arith1.s:73     .text:000000000000004c div_symbol
            arith1.s:81     .text:0000000000000050 div_function

NO UNDEFINED SYMBOLS
