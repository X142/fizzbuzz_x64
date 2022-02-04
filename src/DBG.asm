global G_set_dec_str_to_buf
global G_cout_2
global G_cout_LF
global G_cout_num
global strlen
global cout
global str_to_num

bits 64
default rel

%define sys_write 1

; Unix系の ABI では、
; rbx, rbp, rsp, r12 - r15
; これらが callee saved レジスタであるが、
; 以下では、Debug 目的でレジスタを全て保存する場合がある

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
	push	rdi ; for debug
	push	rsi ; for debug
	push	rdx ; for debug
	push	rcx ; for debug
	push	r8  ; for debug

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

		; edx = edx = 4 - (ecx % 4)
		and ecx, 3
		neg ecx
		add ecx, 4
		; 文字列の先頭のアドレス = rsi + (4 - ecx % 4)
		; 	を求めるときに必要になるので、edx に保存しておく
		mov edx, ecx

		shl ecx, 3 ; 8 倍して、その分 r8d を左シフト
		shl r8d, cl

		mov ecx, edi
	L_loop_1_load:
		sub rsi, 4
		or r8d, 0x30303030
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

section .text
; =========================================
; G_cout_2
; 文字列を fd2 に表示する
; <<< IN
; rsi : 文字列が格納されているアドレス
;   先頭に 4 byte 値で文字列長が格納されている
G_cout_2:
	push	rdi ; for debug
	push	rdx ; for debug
	push	rcx ; for debug
	push	rax ; for debug
	
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

G_cout_num:
	push rsi
	push rax

	call G_set_dec_str_to_buf
	mov rsi, rax
	call G_cout_2

	pop rax
	pop rsi

	ret

G_cout_LF:
	push rsi

	mov rsi, LF
	call G_cout_2

	pop rsi

	ret

section .data
align 4
LF:
	db 1,0,0,0,0x0A

section .text
; =========================================
; str_to_num
; 	数字文字列を数値へ変換する
; <<< IN
; rdi : 数字文字列のアドレス
; 	null terminated かつ 10 bytes 以内
; >>> OUT
; rax : 変換された数値
; --- DESTROY
; rdi, rsi, rcx, rdx, r8, r9, r10
str_to_num:
	mov ecx, 10 + 1
	xor eax, eax ; null
	cld ; clear DF
	repne scasb

	not ecx
	add ecx, 10 + 1 ; 文字数（null を除く）

	je str_to_num_ret ; 0文字の場合、0を返す

	mov esi, ecx
	mov r9d, 10 ; かける数

	sub rdi, rcx ; rdi = 先頭 + 1
	sub rdi, 5 ; rdi = 先頭 - 4

	str_to_num_load:
		add rdi, 4
		mov r8d, [rdi]
		sub r8d, 0x30303030
		sub esi, 4 ; ecx = esi (= ecx - 4) になったら break
		jns str_to_num_add
		xor esi, esi ; ecx = esi (= 0) になったら break

	str_to_num_add:
		mul r9d ; 10倍

		mov r10d, 0xff ; この３行は、改善の余地があるか？
		and r10d, r8d
		add eax, r10d

		shr r8d, 8

		sub ecx, 1
		cmp ecx, esi
		jne str_to_num_add

		or esi, esi
		jne str_to_num_load

	str_to_num_ret:
	ret

section .text
; strlen rdi
strlen:
	push rcx

	mov ecx, 0xffffffff ; length_max = 4 bytes
	xor eax, eax ; null
	cld ; clear DF
	repne scasb

	not ecx ; 文字数（null を除く）
	mov eax, ecx

	pop rcx

	ret

; cout rdi
cout:
	push rdi ; for debug
	push rsi ; for debug
	push rdx ; for debug
	push rcx ; for debug
	push rax ; for debug
	
	mov rsi, rdi
	call strlen
	mov edx, eax ; length
	mov eax, sys_write
	mov edi, 2 ; fd = 2
	syscall

	pop rax
	pop rcx
	pop rdx
	pop rsi
	pop rdi

	ret