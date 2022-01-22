global _start

extern cout
extern strlen
extern strlen_count
extern strlen_count_break
extern load_num_to_rsi
extern exit

global next_
global break_
global cout_fizzbuzz
global if_fizz
global if_buzz
global cout_fizz
global cout_buzz
global cout_num
global fizz
global buzz

default rel ; 相対アドレッシング
bits 64

%define sys_write 1
%define sys_exit 0x3c

section .text

_start:
	xor rcx,rcx ; i = 0

	jmp next_

	cout_fizzbuzz:
		mov rsi,fizz
		call cout
		mov rsi,buzz
		call cout

	cout_LF:
		mov rsi,LF
		call cout

	add rcx,1 ; i++
	
	next_:
		cmp rcx,33 ; break if i < 33
		je break_

	; if_fizzbuzz:
		mov eax,5
		mov edx,3
		mul rdx
		mov rdi,rax
		
		mov rax,rcx
		cqo

		div rdi
		cmp rdx,0
		je cout_fizzbuzz

	if_fizz:
		mov rdi,3

		mov rax,rcx
		cqo

		div rdi
		cmp rdx,0
		je cout_fizz

	if_buzz:
		mov rdi,5

		mov rax,rcx
		cqo

		div rdi
		cmp rdx,0
		jne cout_num

	cout_buzz:
		mov rsi,buzz
		call cout
		jmp cout_LF

	cout_fizz:
		mov esi,fizz
		call cout
		jmp cout_LF
	
	cout_num:
		mov rdi,rcx
		call load_num_to_rsi
		call cout
		jmp cout_LF

	break_:

	jmp exit

section .data
	align 4
	LF:
		db 0x0A,0

	align 8
	fizz:
		db "fizz",0

	align 8
	buzz:
		db "buzz",0