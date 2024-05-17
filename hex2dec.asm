INCLUDELIB kernel32.lib
ExitProcess PROTO
GetStdHandle PROTO
WriteConsoleA PROTO


.data

; Variables
num			QWORD		10h
ans			BYTE		24 dup(0)
mystr		BYTE		24 dup(0)
mystrlen	BYTE		1 dup(0)
pad			BYTE		1 dup(0)
numwritten	BYTE		?
msg			BYTE		"Enter a hexidecimal number: ", 0

.code

;	  Procedure: hex2dec
;
;	Description: stores a decimal number in reverse order into a variable.
;
;	Arguments:
;     Pushed on the stack
;
;   Registers: rax, rcx, rdx, rsi
;
;	Return: None

hex2dec PROC
	push rbp
	mov rbp, rsp
;
; Change the number from hexidecimal to decimal
;
	;xor rax,rax				; Clean out the registers we are using
	;xor rcx,rcx
	;xor rsi,rsi
	xor rdx,rdx

	mov rax, [rbp+24]
	mov rsi, [rbp+16]
	mov rcx, 0ah			; Setup RCX with the divisor

up:
	
	xor rdx, rdx			; Set the remainder for the divide to zero
	div	rcx					; Divide RAX by CX (16 bit)
	mov [rsi], dl			; Copy the 8-bit remainder into 'ans' memory+si and increment si
	inc rsi					; Inrement 'ans' on memory position
	cmp rax, rcx			; Compare quotent remaining to 10 and if rax > 10, loop
	jae up

	mov	[rsi], al			; rax < 10, write the last digit to 'ans'

	mov rsp, rbp
	pop rbp
	ret
hex2dec ENDP

;	  Procedure: reverse_bytes_to_ascii
;
;	Description: Reverse a count of bytes and store in a string.
;                The procedure will strip all leading zeros from
;                the hexidecimal input and write a string to
;                the destination. The actual number of bytes
;                will be store in RDI upon return.
;
;	Arguments:
;     Pushed on the stack
;
;   Registers: rax, rcx, rdx, rdi, rsi
;
;	Return: rdx - number of bytes stored at destination
reverse_bytes_to_ascii PROC

	push rbp
	mov rbp, rsp

	xor rax, rax
	xor rdx, rdx
	mov rdi, [rbp+16]
	mov rsi, [rbp+24]
	mov rcx, [rbp+32]

cont:

	mov al, [rsi]			; check [next] byte at the end to see if it is non-zero
	cmp al,0				;	if it is, skip it
	jz next
	add al, 30h				; Convert the decimal to an ASCII equivalent
	mov [rdi], al			; Store the ASCII in the destination
	inc rdi					; Increment the destination by one memory location
	inc rdx

next:

	dec rsi					; We are going backwards, decrement the source
	dec rcx					; Decrement the counter
	cmp rcx, -1				; We want the 0th byte too so, check for -1
	jg cont					; Jump if rcx > -1
	mov rsp, rbp
	pop rbp
	ret
reverse_bytes_to_ascii ENDP

;	  Procedure: print_dec
;
;	Description: Uses WriteConsole function in windows library.
;                Changes rdx, r8, r9
;
;	Arguments:
;	Pushed on the stack
;
;	Return: None
print_dec PROC
; Print it out
	push rbp
	mov rbp, rsp
	xor r8,r8

	; Get a standard handle for Standard Out [device code -11]
	mov rcx, -11			; Load rcx with STDOUT
	CALL GetStdHandle		; Get a handle
	push rax				; GetStdHandle returns in RAX
	pop rcx					; It needs to be in rcx for the console write

	; Write to the console
	mov rdx, [rbp+24]		; set the address of the string
	mov r8b, [rbp+32]		; Set number of characters to write
	mov r9, [rbp+16]		; set the address of the variable for number of bytes written
	call WriteConsoleA		; Call to write to console
	mov rsp, rbp
	pop rbp
	ret

print_dec ENDP

main PROC

	; setup the call 'hex2dec(number, Address of string)
	; and call it

	mov	rax, num			; load RAX with the number
	lea rsi, ans			; Address of Answer

	push rax
	push rsi

	call hex2dec

	mov rcx, 24		; Initialize the counter to 1 minus the number of bits because the index starts at 0
							; Max we should see for a 64 bit number is 24
	dec rcx
	lea rsi, ans			; Intialize the source index to start at the end
	add rsi,rcx				; Initialize source index to the end of the data
	lea rdi, mystr			; Initialize the destination index to start at the begining

	; setup the call 'reverse_bytes_to_ascii(number of bytes, Address of source, address of destination)
	; and call it
	push rcx
	push rsi
	push rdi

	call reverse_bytes_to_ascii

	pop rdi
	pop rsi
	pop rcx

	; setup the call 'print_dec(length, string, return)
	; and call it

	lea rsi, mystr
	lea rdi, num

	push rdx
	push rsi
	push rdi
	call print_dec
	pop rdi
	pop rsi
	pop rdx

; Clean Exit
	mov rcx,0
	CALL ExitProcess
main ENDP

END
