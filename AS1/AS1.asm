TITLE Assignment1    (AS1.asm)

; Author:tatyana vlaskin

; Course / Project ID                 Date:10.11.2014
; Description:
; Write and test a MASM program to perform the following tasks:
; 1. Display your name and program title on the output screen.
; 2. Display instructions for the user.
; 3. Prompt the user to enter two numbers.
; 4. Calculate the sum, difference, product, (integer) quotient and remainder of the numbers.
; 5. Display a terminating message
; NOTE: You are not required to handle negative input or negative results.
; Extra-credit options(original definition must be fulfilled):
; 1.Repeat until the user chooses to quit.
; 2.Validate the second number to be less than the first.


INCLUDE Irvine32.inc

.data

Introduction	BYTE		"Assignment 1: Elementary Arithmetic by Tatyana Vlaskin", 0				;displays program title and my name
Message1		BYTE		"Enter 2 numbers, and Ill show you the sum, "
				BYTE		" difference,", 10, "product, quotient, and remainder. ", 0				; 10 is line feed: http://www.theasciicode.com.ar/extended-ascii-code/division-sign-obelus-ascii-code-246.html
Message2		BYTE		"Enter the first (larger) number: ", 0
Message3	    BYTE        "Enter the second (smaller) number, greater than zero: ", 0
Terminating		BYTE		"Impressed? Bye!", 10 , 10, 0
number1		    DWORD		?																		;will be determined at the run time
number2			DWORD		?																		;will be determined at the run time
sum				DWORD		?																		;will be determined at the run time
difference	    DWORD		?																		;will be determined at the run time
product		    DWORD		?
quotient	    DWORD	    ?
remainder		DWORD		?
plus			BYTE		" + ", 0
equal			BYTE		" = ", 0
minus			BYTE		" - ", 0
multiply		BYTE		" x ", 0
divide			BYTE	    " ", 246 ," ", 0														;http://www.theasciicode.com.ar/extended-ascii-code/division-sign-obelus-ascii-code-246.html
rem				BYTE	    " remainder ", 0
error			BYTE		"The first number must be larger than the second.", 0
again			BYTE		"Do you want to go again? Press y or Y to continue. ", 0
againInput		BYTE		?


.code
main PROC

;introduction
		;display name and program title
		mov		edx, OFFSET Introduction			;move destination, source, use edx when you are dealing with strings
		call	WriteString
		call	Crlf
		call	Crlf


		;displays instruction
		mov		edx, OFFSET Message1
		call	WriteString
 		call	Crlf
		call	Crlf


RESTART:
		call	CrLf
		mov		eax, 0
		mov		runningSum, eax
		mov		runningSize, eax
		jmp		INPUT

;get data
INPUT:
		;prompt the user to enter 1st number and stores input
		call	Crlf						;advances the cursor to the beginning of the next line in the console
		mov		edx, OFFSET Message2		;prepairs message 2 for stdout
		call	WriteString					;writes the message to the console
		call	ReadInt;					; reads an integer entered by the user
		mov		number1, eax				;stores the integer in the eax register. for numbers use eax
	
INPUT2:
		;prompt the user to enter 2nd numner and stores input
		call	Crlf
		mov		edx, OFFSET Message3
		call	WriteString
		call	ReadInt						;reads the 2nd integer
		mov		number2, eax

;Validating that the second number is less than the first
		mov		eax, number1
		cmp		eax, number2
		jge		CALCULATIONS							;jump if greater than or equal (if leftOp>=rightOp). See page 195 in the book


		;else
		mov		edx, OFFSET error
		call	WriteString
		jmp		INPUT2									;ask the user to different number. See page 632 in the book -6th edition


CALCULATIONS:
;calculations are performed

		;SUMMATION
		mov		eax, number1				;destination,source
		add		eax, number2
		mov		sum, eax					;sum ends up in the eax register
	

		;DIFFERENCE
		mov		eax, number1				;destination, source
		sub		eax, number2
		mov		difference, eax				;difference ends up in the eax register
	

		;MULTIPLICATIONS
		mov		eax, number1
		mov		ebx, number2
		mul		ebx
		mov	    product, eax

		;DIVISION							;followed example posted on the Blackboad
		mov		eax, number1
		cdq									;convert double word to quarwords
		mov		ebx, number2
		div		ebx
		mov		quotient, eax				;see page 627 6th edition Irvin
		mov		remainder, edx

;display results
		call	Crlf						;advances the cursor to the beginning of the next line in the console

		;SUMMATION RESULTS
		mov		eax, number1				;prepares 1st integer for stdout
		call	WriteDec
		mov		edx, OFFSET plus			;prepairs + siggn for stdout
		call    WriteString
		mov		eax, number2				;prepaires 2nd number for stout
		call	WriteDec
		mov		edx, OFFSET equal			;prepairs = sign got stdout
		call	WriteString
		mov		eax, sum					;prepairs sum for stdout
		call	WriteDec
		call	Crlf						;advances the cursor to the beginning of the next line in the console

		;SUBTRACTION RESULTS
		mov		eax, number1				;prepairs 1st integer for stdout
		call    WriteDec
		mov		edx, OFFSET minus			;prepaires - sign for stdout
		call	WriteString
		mov		eax, number2				;prepairs 2nd integer for stdout
		call	WriteDec
		mov		edx, OFFSET equal			;prepairs = sign for stdout
		call	WriteString
		mov		eax, difference				;prepairs difference for stdout
		call	WriteDec
		call	Crlf						;advances the cursor to the beginning of the next line in the console


		;MULTIPLICATION RESULTS
		mov		eax, number1				;prepairs 1st number for stdout
		call	WriteDec
		mov		edx, OFFSET multiply		;prepairs x sing for stdout
		call	WriteString
		mov		eax, number2				;prepairs 2nd number for stdout
		call	WriteDEc
		mov		edx, OFFSET equal			;prepairs equal sign for std out
		call	WriteString
		mov		eax, product				;prepairs product for stdout
		call    WriteDec
		call	Crlf						;advances the cursor to the beginning of the next line in the console


		;DIVISION RESULTS
		mov		eax, number1				;prepairs 1st # for stdout
		call	WriteDec					;display the number1
		mov		edx, OFFSET divide			;prepais divide for stdout
		call	WriteString					;display divide sign
		mov		eax, number2				;prepairs 2nd # for stdout	
		call	WriteDec					;display number2 
		mov	    edx, OFFSET equal			;prepairs = sign for stdout
		call	WriteString
		mov		eax, quotient				;prepairs quotient for stdout
		call	WriteDec
		mov		edx, OFFSET rem				;prepairs remainder message for setdout
		call	WriteString
		mov		eax, remainder				;prepaires remainder for stdout
		call	WriteDec
		call	Crlf
		call	Crlf

;ask the user if they want to go another round
		call	CrLf						;blank line
		mov		edx, OFFSET	again			;again is moved to edx
		call	WriteString					;message is displayed
		call	ReadChar					;entry is read
		mov		againInput, AL				;entry is stored

		;if the answer is capital case Y
		cmp		againInput, 'Y'				;compare the entry to Y
		je		RESTART						;jump if equal, see page 631 in the book

		;if the answer is lowercase y
		cmp		againInput, 'y'				;compare the entery to y
		je		RESTART						;if matches, do go to the input

		;if the user doe not say Y or y		;if entry is not Y or y, display goodbye message
		jmp		GOODBYE						;jump unconditionally to label. see page 632 in the book

;saying goodbye
GOODBYE:
		;TERMINATION MESSAGE
		call	CrLf
		call	CrLf
		mov		edx, OFFSET Terminating		;prepaire message
		call	WriteString					;prints message to the consol

		exit								; exit to operating system

main ENDP


END main
