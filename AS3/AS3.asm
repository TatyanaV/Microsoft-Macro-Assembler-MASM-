TITLE Integer Accumulator					(AS3.asm)
; Author: Tatyana Vlaskin
; Course: CS 271					 Date: 11.20.2014
; Assignment: Program #3
; Description:  This program will ask a user for number inputs, until a negative number is entered.
;Once the user enters a negative number, the sum and average is calculated, excluding the negative number.
;The average is rounded to the nearst number. If the user enters a number that is outside the valid range,
;which is 0-100, inclusive an error message is displayed. At the end of the calculations, the user
;has an option to do another calcualtion, without closing the console window.
;STEP BY STEP DESCRIPTION OF THE PROGRAM
;1. Displays the program titles and programmers name
;2. Asks the user to enter their name and greets the user once the name is eneterd
;3. Display instructions to the user
;4. Repeatadly prompt the user to enter a number.
;5. Entered # is validated to be <=100
;6. Every valid # id counted and accumulated
;7. Once the negative # is enetered the negative # is discarded and the average of the nonnegative #s is calculated
;8. The following information is displayed back to the user: number of nonnegative #s eneterd, the sum of the #s, 
;the average rounded to the neares int and a parting message with users name
;references: https://github.com/jonziefle/CS271/blob/master/Homework%203/CS271_HW3.asm


INCLUDE Irvine32.inc

;constants
LOWER_LIMIT = 0;
UPPER_LIMIT = 100;


.data
Introduction	    BYTE	"Welcome to the Assignment 3: Integer Accumulator by ", 0				
AuthorsName			BYTE	"Tatyana Vlaskin ", 0
Question1			BYTE	"What is your name? ", 0
Greeting			BYTE	"Hello, ", 0
Instructions		BYTE	"This program calculates sum and average of #s, enetered by the "
					BYTE	"user. " , 10, "Please enter numbers less than or equal to "
					BYTE	"100. " , 10, "Enter a negative number when you are finished to see results."	, 0
Question2			BYTE	"Enter number: ", 0
Display1			BYTE	"You entered ",0
Display2			BYTE	" non-negative numbers.",0
SumDisplay			BYTE	"The sum of your numbers is ",0
AverageDisplay		BYTE	"The rounded average is ",0
Error				BYTE	"ERROR! The number is out of range. Enter a number between 0 and 100 inclusive. ",0
noNubmbers			BYTE	"You have NOT entered any non-negative "
					BYTE	"numbers. " , 10, "There is nothing to calculate. ",0
Goodbye				BYTE	"Thank you for playing Integer "
					BYTE	"Accumulator!", 10, "It's been a pleasure to meet you, ",0
tryAgain			BYTE	"Do you want to go again? Press y to play "
					BYTE	" again.", 10, "Press any other key to get to farewell message.", 0
two					DWORD	2							;We want to round when the remainder if it is half or more of the count
floatPoint			BYTE	"Average as the float-point: ",0


; Input Variables
UserName			BYTE	33  DUP(0)					;variable for the user name
number			    DWORD	?
count				DWORD	?
sum					DWORD	?
average				DWORD	?
remainder			DWORD	?
againInput			BYTE	?							;variable in case the user wants to do calculations for another number

.code
main PROC

; INTRODUCTION
		
		;display the name of the programer and program title
		mov			edx, OFFSET Introduction
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
		
		;rules of the program, let the user know that only # between 0-100 can be entered.
		mov			edx, OFFSET Instructions
		call		WriteString
		call		CrLf


RESTART:
		call	CrLf
		mov		eax, 0
		mov		sum, eax
		mov		average, eax
		mov		count, eax
		jmp		ASK_VALIDATE


;REQUESTING INTEGERS FROM THE USER
; asks for an integer and Validates the integer (makes sure that int is between 0-100, inclusive
ASK_VALIDATE:
			
		;ask for an int, and reads an int
		mov		edx, OFFSET Question2
		call	WriteString
		call	ReadInt								;Reads a 32-bit signed integer from the keyboard and return the value in EAX. 
		
		; validate an int [0-100]
		cmp		eax, UPPER_LIMIT					;CMP destination, source
		jg		ERROR_TO_HIGH						;jump if greater to the error message

		;check if the number is < 0
		cmp		eax, LOWER_LIMIT					;CMP destination, source
		jl		DONE								;jump if less to the end of the program

		; if the number is in the range [0-100] inclusive, go to the CALCULATION label
		jmp		CALCULATIONS						;jump unconditionally to the label CALCULATION


ERROR_TO_HIGH:

		; If number > 100, print error and go to the ASK_VALIDATE loop
		mov		edx, OFFSET Error
		call	WriteString
		call	CrLf
		jmp		ASK_VALIDATE

;adds numbers added by the user [0-100]
CALCULATIONS:
		mov		number, eax								; mov destination, source. number from the eax is moved to the number mem 
		mov		eax, sum								; mov destination, source. number from the total mem is moved to the eax reg
		add		eax, number								; add destination, source. A source operand is added to a destinantion operand, 
														; and the sum is stored in the destination. SUM = SUM + NUMBER
		mov		sum, eax								; mov destination, source. total from the EAX is moved to the sum operand

		;increments count 
		inc		count									;increment memory operand by 1. count valid entried

		;ask the user for the next number
		jmp		ASK_VALIDATE							; jump unconditionally to the ASK_VALIDATE label and ask the user the enter the next number


; If number < 0, then exit loop, calcualtes the average, and print calculations
DONE:
		call Crlf

		;calculates average
		cmp		count, 0									;CMP destination, source. if NO non-negative numbers were entered (count =0 , a special message will be displayed
		je		SPECIAL										;jump if equal. jumps to special message if no number entered

		;if the user enetered non-negative numbers, calculate the average
		mov		eax, sum									; mov destination, source. value from sum is moved to EAX				
		mov		edx, 0										;set edx to 0, the remainder after div operation will go there, so we want to initialize it to zero in case it has something else from previous operation
		div		count										;divident is EDX:EAX. divide sum by count
		mov		average, eax								; quation is in the EAX. move destination, source
		mov		remainder, edx								;remainder is in the EDX. move destination, source
		mov		eax, count									;mov destination, source. count is moved to the EAX register
		
		;compare the remainder to decide what is the nearst intereger. if remainder is half or more of the count, we want to round up

		;if remainder is 0
		cmp		remainder, 0	
		je		RESULTS										;if remainder is equal to zero jump to calculations

		;take count and divide it by 2
		mov		eax, count									;mov destination, source. count is moved into the EAX registed
		mov		edx,0										; set edx to 0, edx will store new remainder
		div		two											;divide count by 2. count is divided by 2
		cmp		edx, 0										;
		je		ROUND										;jump if equal, this is the indication that count is EVEN
		inc		eax											;this is the indication that count is ODD, add 1 to count/2. this is needed because lets say 
															;count is 3, so 3/2 = 1.5.
															; So in case we have  2, 10, 22, where remainder is 1, and we compare remainder 1 to the quation of 
															;the count/2,  which is one. The computer will think that average needs to be incremented, but in reality
															;the incrementation is not required. so we need to fix this to avoid incrementaion. the easy fix is add 1 
															;to the quation
														
ROUND:
		;take the remainder and compare it to the quotion of count/2 division. PLEASE note, quation of count/2 division is in the EAX right now
		cmp		remainder, eax
		jl		RESULTS										;jump if less
		inc		average										;if not less, the average needs to be incemeneted by 1
		jmp		RESULTS										;jump unconditionally	to RESULTS

	
; TERMINATING MESSAGE

;message is displayed if no non-negative #s were enteres
SPECIAL:

		call	CrLf
		mov		edx, OFFSET noNubmbers
		call	WriteString
		jmp		AGAIN								;jump unconditionaly to label AGAIN

; if non-negative numbers were entered
RESULTS:

		;display count
		call	CrLf
		mov		edx, OFFSET Display1
		call	WriteString
		mov 	eax, count
		call	WriteDec
		mov		edx, OFFSET Display2
		call	WriteString


		;display sum
		call	CrLf
		mov		edx, OFFSET sumDisplay
		call	WriteString
		mov		eax, sum
		call	WriteDec

		;display average
		call	CrLf
		mov		edx, OFFSET averageDisplay
		call	WriteString
		mov		eax, average
		call	WriteDec
		call	CrLf

AGAIN:
; THIS MAKES TESTING MUCH EASIER, SO I AM ADDING THIS TO THE CODE
;ask the user if they want to go another round
		call	CrLf
		call	CrLf							;blank line
		mov		edx, OFFSET	tryAgain			;again is moved to edx
		call	WriteString						;message is displayed
		call	ReadChar						;entry is read
		mov		againInput, AL					;entry is stored

		;if the answer is capital case Y
		cmp		againInput, 'Y'					;compare the entry to Y
		je		RESTART							;jump if equal, see page 631 in the book

		;if the answer is lowercase y
		cmp		againInput, 'y'					;compare the entery to y
		je		RESTART							;if matches, do go to the input

		;if the user doe not say Y or y			;if entry is not Y or y, display goodbye message
		jmp		FAREWELL						;jump unconditionally to label. see page 632 in the book

FAREWELL:
		
		call	CrLf
		call	CrLf
		mov		edx, OFFSET Goodbye						; Prepare message
		call	WriteString								; Print to console
		mov		edx, OFFSET userName
		call	WriteString
		call	CrLf
		call	CrLf


	exit
main ENDP

END main