global G_set_dec_str_to_buf
global G_cout_2

bits 64
default rel

%define sys_write	1

; =========================================
; G_set_dec_str_to_buf
; edi で渡された値を、10進数の文字列に変換する
; 今回は、32 bit 値までの対応とした
; 生成される文字列を少し仕様変更している

; <<< IN
; edi : 10進数の文字列に変換したい値
; >>> OUT
; rsi : 変換された文字列がストアされた先頭アドレス
;   null termitated な文字列で、かつ、
;   文字列の先頭に文字数が 32bit 値で格納されている
; --- 破壊されるレジスタ
; rsi

section .text

G_set_dec_str_to_buf:
	push	rax	; 通常、これらのレジスタは退避する必要はない
	push	rdi
	push	rdx
	push	rcx
	
	mov	rcx, L_buf_dec_str + 14	; 文字数計算のため、アドレス値を保存
	mov	rsi, rcx
	
	mov	eax, edi
	mov	edi, 10
	
L_loop_1:
	xor	edx, edx
	div	edi
	
	add	edx, 0x30
	sub	rsi, 1
	mov	[rsi], dl
	
	or		eax, eax		; 0 判定をこうすると、生成コードが短くなる
	jne	L_loop_1
	
	sub	rcx, rsi
	sub	rsi, 4
	mov	[rsi], ecx

	pop	rcx
	pop	rdx
	pop	rdi
	pop	rax
	ret
	
; -----------------------------------------
section .data

	; 32 bit 値は最大で 10 文字
	; 文字数をストアするため、さらに 4 bytes 確保している
	; 最後の 0 は、null文字
L_buf_dec_str:
	DB "12345678901234", 0


; =========================================
; G_cout_2
; 文字列を fd1 に表示する
; <<< IN
; rsi : 文字列が格納されているアドレス
;   null termitated な文字列で、かつ、
;   先頭に 4 byte 値で文字列長が格納されている

section .text

G_cout_2:
	push	rax	; 通常、これらのレジスタは退避する必要はない
	push	rdi
	push	rsi
	push	rdx
	push	rcx
	
	mov	rax, sys_write
	mov	rdi, 1		; fd 1
	mov	edx, [rsi]	; 文字数
	add	rsi, 4		; 文字列の先頭アドレス
	syscall
	
	pop	rcx
	pop	rdx
	pop	rsi
	pop	rdi
	pop	rax
	ret
