global _start
global cout
global strlen
global strlen_count
global strlen_count_break
global exit
global fizz
global buzz
global if_buzz
global cout_fizz
global cout_buzz
global next_

default rel ; 相対アドレッシング
bits 64

%define sys_write 1
%define sys_exit 0x3c

section .text

_start:
	xor rcx,rcx ; 初期値 = 0

	jmp next_

	cout_fizz:
		mov esi,fizz
		call cout

	cout_LF:
		mov rsi,LF
		call cout

	add rcx,1 ; インクリメント
	
	next_:
		cmp rcx,16 ; break条件
		je break_

	; if_fizz
		mov rax,rcx
		mov edi,3
		cqo
		idiv rdi
		cmp rdx,0
		je cout_fizz

	if_buzz:
		mov rax,rcx
		mov edi,5
		cqo
		idiv rdi
		cmp rdx,0
		jne cout_num

	cout_buzz:
		mov rsi,buzz
		call cout
		jmp cout_LF
	
	cout_num:
		jmp cout_LF

	break_:

	jmp exit

	; cout rsi
	cout:
		push rcx
		push rdx
		push rax
		push rdi

		call strlen
		mov rdx,rax

		mov eax,sys_write
		mov rdi,1 ; stdout
		syscall

		pop rdi
		pop rax
		pop rdx
		pop rcx

		ret

	; strlen rsi
	strlen:
		push rcx
		push rdi
		push rdx
		push rsi

		mov rcx,0xffffffffffffffff ; 最大文字 = 8bytes
		xor edi,edi ; 終端文字 = 0x0
		strlen_count: ; 1byte づつ数える,終端文字または最大文字に達すると終了
			sub rcx,1
			je strlen_count_break
			mov dl,byte [rsi]
			cmp dil,dl
			je strlen_count_break
			add rsi,1
			jmp strlen_count

		strlen_count_break:
		; ここで、rcx = -1-length なので bit反転,1加算で length が求まる
		not rcx
		mov rax,rcx

		pop rsi
		pop rdx
		pop rdi
		pop rcx
		
		ret
	
	; exit
	exit:
		mov eax,sys_exit
		xor edx,edx ; exit code = 0
		syscall

section .data
	align 2
	LF:
		db 0x0A,0

	align 8
	fizz:
		db "fizz",0

	align 8
	buzz:
		db "buzz",0
