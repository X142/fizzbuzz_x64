global _start

extern G_set_dec_str_to_buf
extern G_cout_2
extern G_cout_LF
extern G_cout_num
extern strlen
extern cout
extern str_to_num

default rel ; 相対アドレッシング
bits 64

%define sys_write 1
%define sys_exit 0x3c

section .text
_start:
	push rbp
	mov rbp, rsp

	mov rdi, [rbp + 8]
	cmp edi, 1 + 2
	jne E_arg
 
	mov rdi, [rbp + 24]
	call str_to_num
	mov ecx, eax ; 初期値

	mov rdi, [rbp + 32]
	push rcx
	call str_to_num
	pop rcx
	mov r12d, eax ; 終了値

	jmp L1

	cout_fizzbuzz:
		mov rsi, fizz
		call G_cout_2
		mov rsi, buzz
		call G_cout_2

	cout_LF:
		call G_cout_LF

		add ecx, 1 ; インクリメント
	L1:
		cmp ecx, r12d ; 終了条件
		jg exit

	; if_fizzbuzz:
		mov edi, 15
		xor edx, edx
		mov eax, ecx
		div edi

		or edx, edx
		je cout_fizzbuzz

	if_fizz:
		mov edi, 3
		xor edx, edx
		mov eax, ecx
		div edi

		or edx, edx
		je cout_fizz

	if_buzz:
		mov edi, 5
		xor edx, edx
		mov eax, ecx
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
		call G_cout_num
		jmp cout_LF

	exit:
		mov rsp, rbp
		pop rbp

		mov eax, sys_exit
		mov edi, 0
		syscall

section .data
	align 4
	fizz:
		db 4,0,0,0,"fizz"

	align 4
	buzz:
		db 4,0,0,0,"buzz"

section .text
E_arg:
	mov rdi, e_arg
	call cout
	call G_cout_LF
	jmp exit

section .data	
e_arg:
	db "the number of arguments is incorrect!", 0