global cout
global strlen
global strlen_count
global load_num_to_rsi
global exit

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

	mov edi,1 ; fd = 1
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

	mov rcx,0xffffffffffffffff ; length_max = 8bytes
	xor edi,edi ; terminated char = 0x0
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
	
	cmp rdi,0xff + 1
	js rsi_4
	cmp rdi,0xffff + 1
	js rsi_8
	cmp rdi,0xffffffff + 1
	jns rsi_32
	rsi_16:
		mov rsi,str_16
		push rsi
		add rsi,10 - 1
		jmp rsi_break
	rsi_4:
		mov rsi,str_4
		push rsi
		add rsi,3 - 1
		jmp rsi_break
	rsi_8:
		mov rsi,str_8
		push rsi
		add rsi,5 - 1
		jmp rsi_break
	rsi_32:
		mov rsi,str_32
		push rsi
		add rsi,20 - 1
	rsi_break:

	mov rax,rdi
	mov rdi,10
	load_digits:
		cqo
		div rdi

		or dl,0x30
		mov [rsi],dl

		sub rsi,1

		cmp rax,0
		jne load_digits

	pop rsi

	pop rdx

	ret

exit:
	mov eax,sys_exit
	xor edi,edi
	syscall

section .data
	; 8bit  -(str)-> 3bytes 
	; 16bit -(str)-> 5bytes 
	; 32bit -(str)-> 10bytes
	; 64bit -(str)-> 20bytes
	align 4
	str_4:
		db "---",0

	align 8
	str_8:
		db "----_",0

	align 16
	str_16:
		db "-_-------_",0

	align 32
	str_32:
		db "---_-------_-------_",0