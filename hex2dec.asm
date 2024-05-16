INCLUDELIB kernel32.lib
ExitProcess PROTO
GetStdHandle PROTO
WriteConsoleA PROTO

.data
; Constants
mybits		equ			16
stdout		equ			-11

; Variables
num			WORD		125h
ans			BYTE		16 dup(0)
mystr		BYTE		17 dup('$')
mystrlen	QWORD		0
numwritten	BYTE		?
handle		QWORD		?



.code
main PROC
; Clean out the registers we are using

	xor rax,rax
	xor rcx,rcx
	xor rsi,rsi
	xor rdx,rdx

; Setup AX with our number
; Setup 10 as our divisor
; Load the address of 'ans' to hold the answer in reverse order
	mov	ax, num
	mov cx, 0ah
	lea rsi, ans

;
up:
	
	xor rdx, rdx			; Set the remainder for the divide to zero
	div	cx					; Divide RAX by CX (16 bit)
	mov [rsi], dl			; Copy the 8-bit remainder into 'ans' memory+si and increment si
	inc si					; Inrement 'ans' on memory position
	cmp rax, rcx			; Compare quotent remaining to 10 and if rax > 10, loop
	jae up

	mov	[rsi], al			; rax < 10, write the last digit to 'ans'

; Print the number by reversing the hex bytes

	xor rax, rax			; Clear the registers we are using
	xor rcx, rcx
	xor rdx, rdx

	lea rsi, ans			; Intialize the source index to start at the end
	mov rcx, mybits-1		; Initialize the counter to 1 minus the number of bits because the index starts at 0
	add rsi,rcx				; Initialize source index to the end of the data

	; Initialize the destination index to start at the beginning
	lea rdi, mystr

cont:
	mov al, [rsi]			; check [next] byte at the end to see if it is non-zero
	cmp al,0				;	if it is, skip it
	jz next
	add al, 30h				; Convert the decimal to an ASCII equivalent
	mov [rdi], al			; Store the ASCII in the destination
	inc rdi					; Increment the destination by one memory location
	inc [mystrlen]			; Keep track of the actual length
next:
	dec rsi					; We are going backwards, decrement the source
	dec rcx					; Decrement the counter
	cmp rcx, -1				; We want the 0th byte too so, check for -1
	jg cont					; Jump if rcx > -1

; Print it out

	xor rax, rax			; Clear registers we are using
	xor rcx, rcx
	xor rdx, rdx
	xor r8, r8
	xor r9, r9
	sub rsp, 32				; Shadow space for arguments

	; Get a standard handle
	mov rcx, stdout			; Load rcx with STDOUT
	CALL GetStdHandle		; Get a handle
	mov handle, RAX			; Save the handle in a variable 'handle'

	; Write to the console
	mov rcx, handle			; Load the handle in arg1 
	lea rdx, mystr			; Load mystr in arg2
	mov r8, [mystrlen]		; Load length in arg3
	lea r9, num				; Set the address to write the return value
	call WriteConsoleA		; Call to write to console
	add rsp, 32				; Remove shadow space from stack
; Clean Exit
	mov rcx,0
	CALL ExitProcess
main ENDP

END
