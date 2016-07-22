TITLE Fibonacci						(AS2.asm)
; Author: Tatyana Vlaskin
; Course: CS 271					 Date: 10.19.2014
; Assignment: Program #2
; Description: 
; 1)Getting string input
; 2)Designing and implementing a counted loop
; 3)Designing and implementing a post-test loop
; 4)Keeping track of a previous value
; 5)Implementing data validation
; REFERENCES: https://github.com/donatzm/CS271/blob/master/donatzm/Assignment02.asm

INCLUDE Irvine32.inc

;constants
LOWER_LIMIT = 1;
UPPER_LIMIT = 46;

.data

Introduction	    BYTE	"Assignment 1: Fibonacci Numbers ", 0				
Programed			BYTE	"Programed by ", 0
AuthorsName			BYTE	"Tatyana Vlaskin ", 0
Question1			BYTE	"What is your name? ", 0
Greeting			BYTE	"Hello, ", 0
Instructions		BYTE	"Enter the number of Fibonacci terms to be "
					BYTE	"displayed " , 10, "Give the number as an integer in the range [1 .. 46]."	, 0
Question2			BYTE	"How many Fibonacci terms do you want? ", 0
Terminating			BYTE	"Results certified by ", 0
Goodbuy				BYTE	"Goodbuy, ", 0
outOfRange			BYTE	"Out of range. Enter a number in [1 .. 46].", 0
tryAgain			BYTE	"Do you want to go again? Press y to continue. ", 0
space				BYTE	" ",9 ,0

; Input Variables
UserName			BYTE	33  DUP(0)					;variable for the user name
Fibonacci			DWORD	?							;variable for the fibonacci #
number2				DWORD	?							;variable for the (n-2) term in the fibonaci sequence
sum					DWORD	?							;variable for the sum
column				DWORD	?							;variable to count columns on the row
againInput			BYTE	?							;variable in case the user wants to do calculations for another number


.code
main PROC


; INTRODUCTION
		
		;display the name of the programer and program title
		mov			edx, OFFSET Introduction
		call		WriteString
		call		CrLf
		mov			edx, OFFSET Programed
		call		WriteString
		mov		    edx, OFFSET AuthorsName
		call		WriteString
		call		CrLf
		call		CrLf


		;prompt the user to enter their name
		mov			edx, OFFSET Question1
		call		WriteString
		mov			edx, OFFSET userName
		mov			ecx, SIZEOF userName
		;mov		ecx, 32
		call		ReadString


		;display the users name along with the Hello message
		call		CrLf
		mov			edx, OFFSET Greeting
		call		WriteString
		mov			edx, OFFSET userName
		call		WriteString
		call		CrLf


;INSTRUCTIONS TO THE USER
		
		;rules of the program, let the user know that only # between 1-46 inclusive can be eneterd
		mov			edx, OFFSET Instructions
		call		WriteString
		call		CrLf
		call		CrLf


;GET THE FIBONACCI # FROM THE USER

; ask for the number and validate that the entered # is between 1 and 46
VALIDATE:
		call		CrLf
		mov			edx, OFFSET Question2
		call		WriteString
		call		ReadInt						;read the integer from the keyboad and returns the value in EAX
		cmp			eax, LOWER_LIMIT			;value in the EAX, which is the value entered by the user is compared to 1
		jl			ERROR						; jump if less: if the value in the EAX is less than 1, an ERROR message is displayed and we ask the user to reenter the #
		cmp			eax, UPPER_LIMIT			; value in the EAX, which is the # entered by the user is compared to 46
		jg			ERROR						; if the value in the EAX is greater than 46, ERROR message is displayed and the user is asked to reenter the number
		jmp			ACCEPTABLE					; if the entry is within the range jump to lable ACCEPTABLE

;in case the user entered the number lower than 1 or higher than 46
ERROR:
		call		CrLf						;move to the next line 
		mov			edx, OFFSET outOfRange		;display out of range message
		call		WriteString
		call		Crlf
		jmp			VALIDATE					;jump unconditionally to label VALIDATE to ask the user for a different value

ACCEPTABLE:
		call		CrLf
		mov			Fibonacci, eax				;fibonacci # is accepted (withing the range) and the entered # is moved to the eax
		
		
;DISPLAY THE FIBONACCI RESULTS
		;distpay the fist value. we need the following code because 1st 2 term in the fibonacci sequence is equal to 1.
		mov			eax, 1						;first term is 1
		call		WriteDec					;write current sum, which is 1 becasue the lowerst possible # that the user can enter is 1
		mov			edx, OFFSET space			;space variable is prepared 
		call		WriteString					;display space variale to the console 
		mov			eax, 0						;eax will keep track of the sum, we'll initialize it to 1
		mov			ebx, 1						;First term is (n-1), we start at term 1
		mov			number2, 0					;Second term is (n-2), we set second term to 0 because 1st 2 terms in the fibonacci sequence is 1
		mov			ecx, Fibonacci				;loop counter is the # entered by the user for the Fibonacci #
		dec			ecx							;1st value is already calculated (its 1), so we need to decrement loop counter by 1
		mov			column, 2					;column count is set to 2 because 1st value is already displayed (its equal to 1)

		
;once first # is displayed, we enter this loop
Fibonacci_LOOP:
		;eax = (n - 1) + (n - 2) ; EAX will be used to calculate the sum of 2 adjacent terms.
		;EBX is used for the 1st term (n-1)  and number2 is second term (n-2)
		
		mov			eax, ebx					;destination, source. (n-1) is taken from the ebx and moved to eax. EBX is set to 1 at the begining of the sequence
		add			eax, number2				;(n-2) is added to (n-1). (n-2) is equal to 0 at the begining of the program
		mov			number2, ebx				;destination, source: (n-2) is assigned to be the value stored in the (n-1).  
		mov			ebx, eax					;destination, source. Value from the EAX which is the SUM value is moved to the EBX. this is the new (n-1) term
		call		WriteDec					;write current sum
		mov			edx, OFFSET space			;write the space after the number
		call		WriteString


		;move on to the next number
		;checks the number of columns on a line. Only 5 columns are allowed per line
		cmp			column, 5					;compare the column count to 5
		jge			resetColumns				;jump if greater or equal to 5 to label resetColumns
		mov			edx, column					;destination, source. column count is moved to the edx
		inc			edx							;add 1 to the edx. 
		mov			column, edx					;destination, source. edx value is coppied to the column variable thus column will be incremented by 1.
		jmp			sameRow						;unconditionaly jump to label sameRow, values will be printed on the same row



;resets the column count to 1 if the column count is 5
resetColumns:
		call		CrLf						;move to the next line 
		mov			column, 1					;set column count to 1


;continue displaying the values on the same row if the column count is <5	
sameRow:
		loop		Fibonacci_LOOP				;decrements ECX and jumps to the label if ECX is not equal to 0.


;ask the user if they want to go another round
		call	CrLf							;blank line
		mov		edx, OFFSET	tryAgain			;again is moved to edx
		call	WriteString						;message is displayed
		call	ReadChar						;entry is read
		mov		againInput, AL					;entry is stored

		;if the answer is capital case Y
		cmp		againInput, 'Y'					;compare the entry to Y
		je		VALIDATE						;jump if equal, see page 631 in the book

		;if the answer is lowercase y
		cmp		againInput, 'y'					;compare the entery to y
		je		VALIDATE						;if matches, do go to the input

		;if the user doe not say Y or y			;if entry is not Y or y, display goodbye message
		jmp		FAREWELL						;jump unconditionally to label. see page 632 in the book

;saying goodbuy
FAREWELL:
		call	CrLf
		call	CrLf
		mov		edx, OFFSET Terminating
		call	WriteString
		mov		edx, OFFSET AuthorsName
		call	WriteString
		call	CrLf
		mov		edx, OFFSET Goodbuy
		call	WriteString
		mov		edx, OFFSET UserName
		call	WriteString
		call	CrLf
		call	CrLf

		exit									; exit to operating system


main ENDP

END main
