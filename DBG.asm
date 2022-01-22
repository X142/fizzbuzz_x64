global cout
global strlen
global strlen_count
global strlen_count_break
global load_num_to_rsi
global load_digits
global load_digits_break
global exit
global str_32

default rel ; 相対アドレッシング
bits 64

%define sys_write 1
%define sys_exit 0x3c

section .text

; cout rsi
cout:
	push rcx
	push rdx
	push rax
	push rdi

	call strlen
	mov rdx,rax

	mov edi,1 ; stdout
	mov eax,sys_write
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
	strlen_count:
		sub rcx,1
		je strlen_count_break
		mov dl,byte [rsi]
		cmp dil,dl
		je strlen_count_break
		add rsi,1
		jmp strlen_count

	strlen_count_break:
		not rcx
		mov rax,rcx

	pop rsi
	pop rdx
	pop rdi
	pop rcx
	
	ret

; load_num_to_rsi rdi
load_num_to_rsi:
	push rdx

	mov rsi,str_32 + 19

	mov rax,rdi
	mov rdi,10
	load_digits:
		cqo
		div rdi

		or dl,0x30
		mov [rsi],dl

		cmp rax,0
		je load_digits_break

		sub rsi,1
		jmp load_digits
	load_digits_break:
	
	mov rsi,str_32

	pop rdx

	ret

exit:
	mov eax,sys_exit
	xor edi,edi
	syscall

section .data
	align 32
	str_32:
		db "---_-------_-------_",0