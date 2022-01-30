global _start

extern G_set_dec_str_to_buf
extern G_cout_2
extern G_cout_LF

default rel ; 相対アドレッシング
bits 64

%define sys_write 1
%define sys_exit 0x3c

section .text
_start:
	xor ecx, ecx ; i = 0

	jmp L1

	cout_fizzbuzz:
		mov rsi, fizz
		call G_cout_2
		mov rsi, buzz
		call G_cout_2

	cout_LF:
		call G_cout_LF

	add ecx, 1 ; i++
	
	L1:
		cmp rcx, 101 ; break if i < 100
		je exit

	; if_fizzbuzz:
		mov edi, 15
		
		mov eax, ecx
		cqo

		div edi
		or edx, edx
		je cout_fizzbuzz

	if_fizz:
		mov edi, 3

		mov eax, ecx
		cqo

		div edi
		or edx, edx
		je cout_fizz

	if_buzz:
		mov edi, 5

		mov eax, ecx
		cqo

		div edi
		or edx, edx
		jne cout_num

	cout_buzz:
		mov rsi, buzz
		call G_cout_2
		jmp cout_LF

	cout_fizz:
		mov rsi, fizz
		call G_cout_2
		jmp cout_LF

	cout_num:
		mov edi, ecx
		call G_set_dec_str_to_buf
		mov rsi, rax
		call G_cout_2
		jmp cout_LF

	exit:
		mov eax, sys_exit
		mov edi, 0
		syscall

section .data
	align 8
	fizz:
		db 4,0,0,0,"fizz"

	align 8
	buzz:
		db 4,0,0,0,"buzz"