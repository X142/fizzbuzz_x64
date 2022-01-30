global G_set_dec_str_to_buf
global G_cout_2
global G_cout_LF

bits 64
default rel

%define sys_write	1

; Debug目的の関数のため、レジスタを保存する
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

	mov	eax, edi
	mov	edi, 10
	mov rsi, L_buf_dec_str + 14
	xor edx, edx
	xor ecx, ecx ; 文字数をカウントする
	xor r8d, r8d ; 左へ8bitシフトしながら、10で割った余りを加算していく

	L_loop_1:
		div	edi

		shl r8d, 8
		add r8d, edx

		xor	edx, edx
		add ecx, 1

		; r8d が いっぱいになったら 4bytes ロード
		; 商が0になったら 少し調整を加えて 4bytes ロード、break
		test ecx, 3 ; 4 の倍数判定（最下位 2bit が 0）
		je L_loop_1_load

		or eax, eax
		je L_loop_1_shl_load

		jmp L_loop_1 
	
	; 例えば、r8d に 0321 と入ってたら、
	; 1bit 左シフトして、3210に調整してロードしなければならない
	; 4 - (ecx % 4) bit 左シフトするということ
	L_loop_1_shl_load:
		mov edi, ecx ; ecxを保存しておく

		; ecx = edx = 4 - (ecx % 4)
		mov edx, 3
		and edx, ecx
		mov ecx, 4
		sub ecx, edx
		mov edx, ecx ; ecxはこの後元に戻してしまうので、edxに保存しておく

		shl ecx, 3 ; 8倍 して左シフト
		shl r8d, cl

		mov ecx, edi
	L_loop_1_load:
		sub	rsi, 4
		add r8d, 0x30303030 ; マスク
		mov [rsi], r8d
		xor r8d, r8d

		or eax, eax
		jne L_loop_1

	add rsi, rdx ; 保存しておいたedx = 4 - (ecx % 4) 足すと丁度文字列の先頭になる
	sub rsi, 4 ; 先頭に文字数(ecx)を入れるので、4引く
	mov [rsi], ecx
	mov rax, rsi ; raxを戻り値とすることにした
	
	pop	r8
	pop	rcx
	pop	rdx
	pop rsi
	pop	rdi

	ret
	
; -----------------------------------------
section .data
	; 32 bit 値は最大で 10 文字
	; 文字数をストアするため、さらに 4 bytes 確保している
L_buf_dec_str:
	db "00003412341234"

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
	push	rsi
	push	rdx
	push	rcx
	push	rax
	
	mov	eax, sys_write
	mov	edi, 2		; fd 2
	mov	edx, [rsi]	; 文字数
	add	rsi, 4		; 文字列の先頭アドレス
	syscall
	
	pop	rax
	pop	rcx
	pop	rdx
	pop	rsi
	pop	rdi

	ret

G_cout_LF:
	push rsi
	push rcx

	mov rsi, LF
	call G_cout_2

	pop rcx
	pop rsi

	ret
