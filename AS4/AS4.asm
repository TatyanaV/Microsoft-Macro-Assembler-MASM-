TITLE Prime Number Calculator					(AS4.asm)
; Author: Tatyana Vlaskin
; Course: CS 271					 Date: 11.09.2014
; Assignment: Program #4
; Description:   This program will calculate and display prime numbers in a given range
; The user is asked to eneter # of prime numbers that they want to be displayed.
; Acceptable number  that the user can enter is [1-200].
; If it is detected that the value is not in the acceptable range, 
; an error message is displayed and the user is asked to reenter an integer
; Once an integer is accepted, the program calculates and displayes the prime numbers
; The results will be displayed 10 primers  per line

;refference: https://github.com/donatzm/CS271/blob/master/donatzm/Assignment04.asm
;			 https://github.com/JohnLZeller/Classes/blob/master/CS271/program4.asm


INCLUDE Irvine32.inc

;contants
LOW_LIMIT = 1
HIGH_LIMIT = 200

.data

;program identifiers
ProgramName		    BYTE	"Welcome to the Assignment 4: Prime Number Calculator by ", 0				
AuthorName			BYTE	"Tatyana Vlaskin. ", 0
Introduction1		BYTE	"This program calculates prime " 
					BYTE	"numbers",10, "You are asked to enter the number of prime numbers you would like to "
					BYTE	"see.", 10, "I'll accept orderes for up to 200 primers.", 0
prompt				BYTE	"Enter the number of primers to display [1 .. 200] ", 0
error				BYTE	"Out of range! Try again. Acceptable numbers [1 .. 200]", 0
number				DWORD	?
truth				DWORD	?
test_Number			DWORD	1
factors				DWORD	?
divisor				DWORD	?
Primer_Found		DWORD	1
nextLine		    DWORD	10
goodbye			    BYTE	"Results certified by ", 0
goodbye2			BYTE	"Goodbye.", 0



.code
main PROC

	call	introduction
	call	getUserData
	call	showPrimes
	call	farewell

exit
main ENDP



;-----------------------------------------------------------------------------------------------------------------------------------
; introduction PROC 
; Displays an introduction for the program, programmer and instructions for use
; Receives: Nothing
; Returns: Nothing
; preconditions: none
; registers changed: edx
;-----------------------------------------------------------------------------------------------------------------------------------------------------

introduction PROC
	;prints program name and program author
	mov		edx, OFFSET programName
	call	WriteString
	mov		edx, OFFSET authorName
	call	WriteString
	call	CrLf

	;prints user instructions
	call	CrLf
	mov		edx, OFFSET Introduction1
	call	WriteString
	call	CrLf
	call	CrLf
	ret
introduction ENDP


;----------------------------------------------------------------------------------------------------------------------------------------
; getUserData PROC 
; Procedure to accept input from the user
; Receives: Nothing
; Returns: number
; preconditions: none
; registers changed: EAX
;-----------------------------------------------------------------------------------------------------------------------------------------

;procedure to get numbers from the user
getUserData PROC

numberInput:									;gets user input
		mov			edx, OFFSET prompt
		call		WriteString
		call		ReadInt
		mov			number, eax

		call		validateInput				;validates the input
		cmp			truth, 0
		je			numberInput					;jump if equal

		ret										;return from procedure

getUserData ENDP


;-------------------------------------------------------------------------------------------------------------------------------------------------
;validateInput PROC
;Procedure to validate input number
;receives: global number, global LOW_LIMIT, global HIGH_LIMIT, global error
;returns: none
;preconditions: none
;registers changed: EDX
;--------------------------------------------------------------------------------------------------------------------------------------------------

validateInput PROC
		
	call		CrLf
	cmp			number, LOW_LIMIT				;number < 1 invalid
	jl			invalid							;jump if less to invalid label


	cmp			number, HIGH_LIMIT				;number > 300 is invalid
	jg			invalid							;jump if greater to invalid lable

	
	mov			truth, 1						;number is valid
	jmp			valid							;unconditional jump --- if number is in the range 1-200

	
	invalid:									;lets the user know know the entry is invalid
		mov		truth, 0
		mov		edx, OFFSET error				;error is prepared
		call	WriteString						;error is displayed
		call	CrLf

	valid:									    ;if the number is valid return from procedure
		ret

validateInput ENDP


;---------------------------------------------------------------------------------------------------------------------------------------------------------
;showPrimes PROC
;Procedure to display the calculated primes
;receives: global Primer_Found, global nextline, global number
;returns: none
;preconditions: NumPrimes > 0
;registers changed: AL, EAX
;----------------------------------------------------------------------------------------------------------------------------------------------------------
showPrimes PROC

	call	CrLf
	mov		ecx, number							;valid number that was entered by the user is moved into the ecx register

	Primer_Loop:								;loop that will display primers on the console
		dec		nextLine						;decrements the number of terms to display before line break
		call	isPrime							;calls isPrime to calculate prime numbers
		mov		eax, Primer_Found				;if it was determined that the number is a primer number, move it to the eax register
		call	WriteDec						;write the numeber on the console
	
		cmp		nextLine, 0						;compare the line break to 0. please note that initially line break was set to 10
		je		newLine							;jump if equal to the new line
		mov		al, TAB							;if the number will stay on the same line, put some space between the numbers
		call	WriteChar
		jmp		oldLine							;go to the oldLine

	newLine:									;next number will be displayed on the new line
		call	CrLf							;moves the cursor to the new line
		mov		nextLine, 10					;reset the lineBreat to 10

	oldLine:									;the number is displayed on the same line
		loop	Primer_Loop						;continue looping though the numbers

		ret										;return from procedure

showPrimes ENDP


;---------------------------------------------------------------------------------------------------------------------------------------------------
; isPrime PROC 
; Checks to see whether a given number is a prime number or not
; Receives: global number, globale divisor, global factors, global test_number
; Returns: Nothing
; registers used: EAX, EDX
;---------------------------------------------------------------------------------------------------------------------------------------------------

isPrime PROC
	
	new_Number:									;look at the number one at a time and trying to determine if its a prime number
		mov		divisor, 0						;set divisor to 0
		mov		factors, 0						;set factors to 0
		inc		test_Number						;increment test number right. please note that number 1 is not a prime number, so we can go directly to number 2

	prime:										;divides test number to determine how many factors the number has
		inc		divisor							;increment the divisor, so we start with 1
		mov		eax, test_Number				;test number is moved in the eax
		mov		edx, 0							;edx is set to 0, this register will store the remainder after the division
		div		divisor							;divide by divisor
		cmp		edx, 0							;compare edx [register that stores the remainder] to 0 
		jne		do_Not_Add						;jump if not equal, this is an indication that this number is not divisible by the corresponding divisor
		inc		factors							;if we there was no jump to the do not add label, this is an indication that the number is divisible by the divisor
												; and we need to the increment factors

	do_Not_Add:									;ends loop when the divisor is equal to the test number		
		mov		eax, divisor					;we move divisor to the eax	
		cmp		test_Number, eax				;test number is compared to the eax [it has divisor now]
		je		Is_Primer						;jump if equal. this is an indication that we do not need to increment divisors any more,
												;at this point number of factors is equal to 2, so we need to display this number

		; if the test number is not equal to the divisor continue
		cmp		factors, 1						;compare number of factors to 1
		jle		prime							;jump if less or equal, if there are only 1 factor so far, continue checking if there are any more possible divisors
		jg		new_Number						;jump if greater, if there are more than 1 divisor, move on to the next number
												; (please note that at this point we know that test numbe is still not equal to divisor, thats why we move on 
												;to the next number)
	Is_Primer:									;move a test number to the primer found 
		mov		eax, test_Number				;move test number that was determined to be a prime number to the eax
		mov		Primer_Found, eax				;move eax, which has a value of newly found prime number to the primer_found variabel

	ret								
isPrime ENDP


;--------------------------------------------------------------------------------------------------------------------------------------------------------
;farewell PROC
;procedure to write a farewell message to the user
;receives: global goodbye, and globale goodbye2
;returns: none
;preconditions: none
;registers changed: EDX
;----------------------------------------------------------------------------------------------------------------------------------------------------------

farewell PROC
	call	CrLf
	call	CrLf
	mov		edx, OFFSET goodbye
	call	WriteString
	mov		edx, OFFSET authorName
	call	WriteString
	mov		edx, OFFSET goodbye2
	call	WriteString

	call	CrLf
	call	CrLf

	ret

farewell ENDP

END main