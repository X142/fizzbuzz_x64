global G_set_dec_str_to_buf
global G_cout_2
global G_cout_LF

bits 64
default rel

%define sys_write 1

; Debug 目的の関数のため、レジスタを保存する
section .text
; =========================================
; G_set_dec_str_to_buf
; edi で渡された値を、10進数の文字列に変換する
; 32 bit 値までの対応

; <<< IN
; edi : 10進数の文字列に変換したい値
; >>> OUT
; rax : 変換された文字列がストアされた先頭アドレス
;   文字列の先頭に文字数が 32bit 値で格納されている
G_set_dec_str_to_buf:
	push	rdi
	push	rsi
	push	rdx
	push	rcx
	push	r8

	mov eax, edi
	mov edi, 10
	mov rsi, L_buf_dec_str + 14
	xor edx, edx
	xor ecx, ecx ; 文字数をカウントする
	xor r8d, r8d ; 8bit 左シフトしながら、10 で割った余りを加算していく

	L_loop_1:
		div edi

		shl r8d, 8
		add r8d, edx

		xor edx, edx
		add ecx, 1

		; rcx が 4 の倍数になったら、
		; 	つまり r8d が 上限 32bit に達したら、文字列 4bytes をロード
		; 商が 0 になったら、L_loop_1_shl_load 後、
		; 	文字列 4bytes をロード、さらに文字数を先頭 4bytes へロードして終了
		test ecx, 3 ; 4 の倍数判定（最下位 2bit が 0）
		je L_loop_1_load

		or eax, eax
		je L_loop_1_shl_load

		jmp L_loop_1 
	
	; 例えば、r8d に 0321 と入ってたら、
	; 	little endian に注意して、1bit 左シフトして、
	; 	3210 にしてロードしなければならない
	; これは、4 - (ecx % 4) bit 左シフトするということ
	L_loop_1_shl_load:
		mov edi, ecx ; 文字数 ecx を保存しておく

		; ecx = edx = 4 - (ecx % 4)
		mov edx, 3
		and edx, ecx
		mov ecx, 4
		sub ecx, edx
		; ecx はこのあと元に戻すので、edx に保存しておく
		; 	文字列の先頭のアドレス = rsi + ( 4 - ecx % 4 ) を求めるときに必要になる
		mov edx, ecx

		shl ecx, 3 ; 8 倍して、その分 r8d を左シフト
		shl r8d, cl

		mov ecx, edi
	L_loop_1_load:
		sub rsi, 4
		add r8d, 0x30303030
		mov [rsi], r8d
		xor r8d, r8d

		or eax, eax
		jne L_loop_1

	add rsi, rdx ; rsi に、保存しておいた edx を加算すると、丁度文字列が始まる 先頭アドレスになる
	sub rsi, 4 ; 先頭に文字数 ecx を入れるので、4 減算する
	mov [rsi], ecx
	mov rax, rsi ; raxを戻り値とすることにした
	
	pop	r8
	pop	rcx
	pop	rdx
	pop	rsi
	pop	rdi

	ret
	
; -----------------------------------------
section .data
; 32 bit 値は最大で 10 文字
; 文字数をストアするため、さらに 4 bytes 確保している
L_buf_dec_str:
	db "00003412341234"

align 4
LF:
	db 1,0,0,0,0x0A

section .text
; =========================================
; G_cout_2
; 文字列を fd2 に表示する
; <<< IN
; rsi : 文字列が格納されているアドレス
;   先頭に 4 byte 値で文字列長が格納されている
G_cout_2:
	push	rdi
	push	rdx
	push	rcx
	push	rax
	
	mov eax, sys_write
	mov edi, 2 ; fd = 2
	mov edx, [rsi] ; 文字数
	add rsi, 4 ; 文字列の先頭アドレス
	syscall
	sub rsi, 4
	
	pop rax
	pop rcx
	pop rdx
	pop rdi

	ret

G_cout_LF:
	push rsi

	mov rsi, LF
	call G_cout_2

	pop rsi

	ret
