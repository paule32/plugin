#!/bin/zsh

lhs=2 lhs2=4 rhs=80
asparms=(
#  -32		# 32 bit, obviously
  -g		# debug
  -mnaked-reg	# spare % prefix

  --listing-lhs-width=$lhs
  --listing-lhs-width2=$lhs2
  --listing-rhs-width=$rhs
)

ldparms=(
#  -m elf_i386
  --oformat=binary
#  --format=elf32-i386
  -Ttext=0
  -r
)

gccparms=(
  -Wall
  -g
#  -m32
  -O3
)

as $asparms -aghlms=arith1.l -o arith1.o arith1.s &&
{
  cp arith1.o arith1.pi
  objcopy -O binary arith1.pi
}

as $asparms -aghlms=arith2.l -o arith2.o arith2.s &&
{
  cp arith2.o arith2.pi
  objcopy -O binary arith2.pi
}

gcc $gccparms -o cr callreloc.c -ldl
