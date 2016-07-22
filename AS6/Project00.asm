TITLE Dog Years     (template.asm)

; Author: Tatyana Vlaskin
; Course / Project ID : Demo 00                Date:
; Description:

INCLUDE Irvine32.inc

DOG_FACTOR = 7

.data

userName	BYTE			33 DUP(0)	;string to be entered by user
userAge		DWORD			?			;string to be enetered by use	
intro_1		BYTE			"Hi, my name is Lassie, and I am here to tell you your age in dog year",0
prompt_1	BYTE			"What is your name?",0
intro_2		BYTE			"Nice to meet you, ",0
prompt_2	BYTE			"How old are you?",0
dogAge		DWORD			?
result_1	BYTE			"Wow...that's ",0
result_2	BYTE			" in dog years !",0
goodBye		BYTE			"Good-bye, ",0
.code
main PROC

;introduce the programmer
	mov	edx, OFFSET intro_1
	call	WriteString
	call	CrLf	;go to new line


;get the user name
	mov		edx, OFFSET prompt_1
	call	WriteString
	mov		edx, OFFSET userName
	mov		ecx, 32 ;maximum length of strength of the user name
	call	ReadString
;get user age
	mov		edx, OFFSET prompt_2
	call	WriteString
	call	ReadInt
	mov		userAge, eax


;calculate user "dog years"
	mov		eax, userAge
	mov		ebx, DOG_FACTOR
	mul		ebx
	mov		dogAge,	eax

;report results
	mov		edx, OFFSET result_1
	call	WriteString
	mov		eax, dogAge
	call	WriteDec
	mov		edx, OFFSET result_2
	call	WriteString
	call	CrLf

;say "Good-bye"
	mov		edx, OFFSET	goodBye
	call	WriteString
	call	CrLf
	mov		edx, OFFSET userName
	call	WriteString
	call	CrLf

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
