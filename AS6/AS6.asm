TITLE Sorting Random Integers					(AS6.asm)
;*******************************************************************************************************************************************
; Author: Tatyana Vlaskin
; Course: CS 271					 Date: 11.30.2014
; Assignment: Program #6B
; Description:  This program is a combination calculator. The program randomly generates n in the range [3...12]
; and r in the range [1..n], displays those values to the user and ask the user to enter results for combination.
; Result entered by the user is compared to the calculated result, which is calculated recursively using the following 
;formula: n!/(r!(n-r)!). The program reports the correct value and lets the use know if they got it wrong or right.
;The program repeats until the user decides to quit.
;references: 
;			 demo files provided on the blackboard
;			 lectures
;			 http://www.siliconkit.com/rebecca/help/masmpguide/Chap_07.htm
;			 http://www.cs.stedwards.edu/~ewinnub/cosc2331/mysubs.asm
;			 http://stackoverflow.com/questions/13657007/unhandled-exception-recursive-factorial-in-assembly-masm
;			 http://codingforums.com/computer-programming/221061-masm-project-dont-know-what-im-doing-wrong.html
;			 http://stackoverflow.com/questions/13666153/masm-convert-string-to-integer-processing-invalid-input
;			 http://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=9&ved=0CFUQFjAI&url=http%3A%2F%2Fdclab.cs.nthu.edu.tw%2F~course%2FAssembly%2Flecture%25207%2520%2528Chap.%25208%2529.ppt&ei=dpaDVIiYHsSqogSPloKICQ&usg=AFQjCNF0fa8gr3GQ-HU42uzeIXMVyuwLlw&bvm=bv.81449611,d.cGU
;*******************************************************************************************************************************************

INCLUDE Irvine32.inc

;macro taken from lecture 26

printString MACRO buffer
	push	edx
	mov		edx, OFFSET buffer
	call	WriteString
	pop		edx
ENDM

.data
n						DWORD	?
r						DWORD	?
answer					DWORD	?
result					DWORD	?
input					BYTE	10 DUP(0)
another					BYTE	"Another problem? (y/n): ", 0
error					BYTE	"Invalid response. ", 0
goodbye					BYTE	"OK.........Goodbye!", 0
aReg					DWORD	?
bReg					DWORD	?
cReg					DWORD	?
alReg					BYTE	?
dReg					DWORD	?

;constants
MIN_N = 3
MAX_N = 12
RANGE = MAX_N-MIN_N+1
MIN_R = 1

.code
main PROC

	call				Randomize				;sets the randomizer seed
	call				introduction
again:
												
	call				CrLf					;shows the problem to the user
	push				OFFSET r				;[ebp+12], in reality we are working with esp, but contents of esp will be coppied to ebp and we'll we working with ebp'
	push				OFFSET n				;[ebp+8]
	call				showProblem				;[ebp+4]
												
	call				CrLf					;gets user data
	push				OFFSET input			;[ebp+12]
	push				OFFSET answer			;[ebp+8]
	call				getData					;[ebp+4]
												
	push				n						;calculate combination [ebp+16]
	push				r						;[ebp+12]
	push				OFFSET result			;[ebp+8]
	call				combinations			;ebp+4
												
	push				n						;shows results [ebp+20]
	push				r						;[ebp+16]
	push				result					;[ebp+12]
	push				answer					;[ebp+8]
	call				showResults				;[ebp+4]

question:										;ask the user if they want to go another round									
	call				CrLf					;blank line
	printString			another
	call				ReadChar				;entry is read and stored in the AL
	cmp					al, 121					; 'y' character 
	je					again
	cmp					al, 89					; 'Y' character 
	je					again					;if not equal
	cmp					al, 110					; 'n' character
	je					farewell
	cmp					al, 78					; 'N' character
	je					farewell

	printString			error					;let the user know if the entry is invalid
	call				CrLf	
	jmp					question				;repets the question

farewell:
	call				CrLf	
	call				CrLf	
	printString			goodbye
	call				CrLf

exit
main ENDP


;-----------------------------------------------------------------------------------------------------------------------------------
; introduction PROC 
; Displays an introduction for the program, programmer and instructions for use
; Receives: Nothing
; Returns: Nothing
; preconditions: none
; registers changed: edx -see macro
;-----------------------------------------------------------------------------------------------------------------------------------------------------

introduction PROC

.data

ProgramName		    BYTE	"Welcome to the Assignment 6B: Combinations Calculator ", 0				
AuthorName			BYTE	"Tatyana Vlaskin. ", 0
Introduction1		BYTE	"I'll give you a combination problem. You enter your " 
					BYTE	"answer",10, "and I'll let you know if you are right.",0

.code
	pushad								;save registers	
	printString		ProgramName			;prints program name
	call			CrLf
	printString		AuthorName			;prints program author
	call			CrLf
	call			CrLf
	printString		Introduction1 		;prints user instructions
	call			CrLf
	popad								;restore registers

	ret

introduction ENDP



;----------------------------------------------------------------------------------------------------------------------------------------
; showProblem PROC
; Procedure that generades the random numbers and displays the problem
; Receives: addresses of r and n
; Returns: values for r and n
; preconditions: none
; registers changed: EAX, ebx,ecx,
; 
;-----------------------------------------------------------------------------------------------------------------------------------------
;procedure to generate the problem and show to the user
;parameters: n, r (by reference)
showProblem PROC
.data

problem				BYTE "Problem: ", 0
Number_in_Set		BYTE "Number of elements in the set: ", 0
Choose_from_Set		BYTE "Number of elements to choose from the set: ", 0

.code

	;save all registerS
	mov		aReg, eax					
	mov		bReg, ebx					
	mov		cReg ,ecx			
	push	ebp
	mov		ebp, esp

	mov		ebx, [ebp+8]					;address of n
	mov		ecx, [ebp+12]					;address of r

	;calculate n
	mov		eax, RANGE						;n is in the range [3..12]. per lecture 20, we need to put range into the eax. Range = hi-low +1
	call	RandomRange						;calculate pseudorandom number. results are in the eax in the range of [0 .....range-1]
	add		eax, MIN_N						; to get a number in the range [low...hi], we need to add low to the eax
	mov		[ebx], eax				
	
	;calculate r							;r needs to be in the range [1..n]. n is the value that was randomly generated above
	mov		eax, [ebx]						;the next 6 lines of code are taken from the Quiz 3 ;n, which is max for r is moved in the eax
	sub		eax, MIN_R						;we are trying to calculate range using the following formulat: RANGE_R = MAX_R - MIN_R + 1	
	inc		eax								;RANGE_R = MAX_R - MIN_R + 1	
	call	RandomRange
	add		eax, MIN_R						; to get a number in the range [low...hi], we need to add low to the eax
	mov		[ecx], eax						;R WILL BE STORED IN THE ECX


	;prints problem statement
	call			CrLf
	printString		problem
	call			CrLf
	printString		Number_in_Set
	mov				eax, [ebx]						;n is prepared to be written on the screen
	call			WriteDec						;n is displayed
	call			CrLf
	printString		Choose_from_Set	
	mov				eax, [ecx]						;r is preparied to be written on the screen
	call			WriteDec						; r is displayed on the screen
	call			CrLf

	;restores registers		
	mov			eax, aReg					
	mov			ebx, bReg				
	mov			ecx, cReg 
	pop				ebp
	ret				8								;12 bytes are removed from the stack


showProblem ENDP


;-------------------------------------------------------------------------------------------------------------------------------------------------
;getData PROC
;Procedure to prompt/get the user's answer
;receives: string entered by the user
;returns: true(1) is string contains only number characters (base 10)
;and the answer is soted in the stack
;returns: false(0) is there are non intergers in the string and the user
; is asked to reenter the number
;preconditions: none
;registers changed: EDX, al,ecx,eax
; Algorithm of converstion of the ASII string into an interger
; 1. Start at the beginning of the string
; 2. Multiply the value of answer by 10.
; 3. Split each character off the string and subtract by 48d to get the integer. 
;		Ex. student enters 156. 49 is stored as the first char in the variable temp. Subtract 48 from 49. The integer is 1.
; 4. Add integer to value of answer.
; 5. Inc esi (move one character right).
; 6. Loop
;--------------------------------------------------------------------------------------------------------------------------------------------------

getData PROC
.data
;input
prompt		 BYTE "How many ways can you choose? ", 0
invalid		 BYTE "Invalid response. The entry you made is not an integer!", 0
.code
	;save all registerS
	mov		aReg, eax					
	mov		cReg, ecx
	mov		dReg, edx
	mov		alReg, al					
	push	ebp
	mov		ebp, esp
start:
	printString prompt
	mov		edx, [ebp+12]			;Before calling ReadString, EDX should contain the address of
									;the array of bytes where the input characters should be stored

	mov		ecx, 10					;ECX  should contain the maximum number of bytes to be read plus one extra byte
	call	ReadString
	mov		ecx,eax					;actual number of bytes read in the EAX register. 
									;the length of the string is moved to the ecx

	mov		esi, [ebp+12]			;string is moved to the esi
	mov		edx, 0					; at the beggining we have 0 in this register, we will
									;checks input string for non-integer input
loop1:
	mov		al, [esi]				;gets character of the string
	cmp		al, 57					; checks if the enrry is larger thatn 9. '9' is character 57
	ja		invalid2
	cmp		al, 48					; checks if the entery is less than 0. '0' is character 48
	jb		invalid2
	movzx	eax, al					;instruction is used to coppy into a larger register
	push	ecx						;ecx is pushed on stack				
	mov		ecx, eax				;contents of the eax is moved to ecx	
									;eax has newly validated character
	mov		ebx, 10					;ebx is set to 10
	mov		eax, edx				; number from teh edx, which holds validated integers
	mul		ebx						;validated # is multipliped by 10					
	mov		edx, eax				; number from teh eax, which holds validated integers x10 is placed back into edx
	sub		ecx, 48					;48 is subtracted from the ecx that hold newly validated ASII character to get an integer
	add		edx, ecx				;newly validated number is added to the previous validate*10 numbers
	pop		ecx						; ecx is removed from the stack
	inc		esi						;increment esi to go to the next character
	loop	loop1					; while loop counter is not 0, go to the begining of the loop to validate that result
	jmp		quit					
invalid2:
	printString		invalid
	call			CrLf
	jmp				start
quit:
	mov				ebx, [ebp+8]	;address of answer will be stored in the ebx
	mov				[ebx], edx		;user input is pla into answer
	call			CrLf
	;restores registers
	mov				eax, aReg				
	mov				ecx, cReg
	mov				edx, dReg
	mov				al, alReg	
	pop				ebp
	ret				8
getData ENDP


;-------------------------------------------------------------------------------------------------------------------------------------------------
;combinations PROC
;description:
;	1. calls factorial (3 times) to calculate n!, r!, and (n-r)!.
;	2. calculates n!/(r!(n-r)!) , and stores the value in result.
;parameters: n,r (by value), result (by reference)
;receives: receives:  accepts n and r by value and result by address.
;returns: combination calculations
;preconditions: none
;registers changed: eax, ebx, edx,ecx
;--------------------------------------------------------------------------------------------------------------------------------------------------
combinations PROC

	;save all registerS
	mov		aReg, eax					
	mov		bReg, ebx					
	mov		cReg ,ecx	
	mov		dReg, edx	
	push	ebp
	mov		ebp, esp
	mov		eax, [ebp+16]				 ;value of n
	mov		ebx, [ebp+12]				 ;value of r
	
	; (n-r)! calcualtions
	mov		eax, [ebp+16]				;value of n
	sub		eax, [ebp+12]				;value of r  is subtracted from n  ;(n-r)
	mov		ebx, eax					;result of the subtraction is moved to the ebx
	push	ebx							;ebx is pushed on the stack
	call	factorial					;factorial of (n-r), the value is stored in the EAX register
	mov		ecx, eax					;result of (n-r)! is moved from the EAX to ECX
	
	;calculates r!
	mov		ebx, [ebp+12]				;calculates r!
	push	ebx
	call	factorial					;calculate r! the value will be stored in the EAX register
	mul		ecx							; ecx is multiplied by eax. EAX= r! and ECX = (n-r)!
	mov		ecx, eax					;result of r! * (n-r)! in ecx
	
	; n! calculations
	mov		ebx, [ebp+16]
	push	ebx
	call	factorial					;result of n! are stored in the EAX
	
	;n!/(r!*(n-r)!) calculations
	mov		edx, 0						;edx will stored remainder of the division
	div		ecx							;eax is divided by ecx. EAX = n! and ECX = r! * (n-r)! . r. result if stored in the EAX
	mov		ecx, [ebp+8]				;address of result
	mov		[ecx], eax					; r! * (n-r)!  from eax to [ecx]

	;restores registers		
	mov		eax, aReg					
	mov		ebx, bReg				
	mov		ecx, cReg
	mov		edx, dReg
	pop		ebp
	ret		12							;remove 14 bytes from the stack

combinations ENDP


;-------------------------------------------------------------------------------------------------------------------------------------------------
;factorial PROC
;procedure to calculate the factorial of a number
;parameters: ebx (by value)
;receives: string entered by the user
;returns: factorial solutions in the EAX
;preconditions: none
;registers changed: EAX
;--------------------------------------------------------------------------------------------------------------------------------------------------

factorial PROC

	push	ebp
	mov		ebp, esp
	mov		eax, [ebp+8]				;address of result
	cmp		eax, 0
	ja		L1
	mov		eax, 1						
	jmp		quit						;jump if less or equal
	
L1:	dec		eax							; if eax is not equal to 1, keep recursing
	push	eax							;factorial (number-1)
	call	factorial

	mov		esi, [ebp+8]				;get result
	mul		esi							;esi = aex * esi
quit:
	pop		ebp							;return eax
	ret		4							;removes 8 bytes from teh stack
factorial ENDP


;-------------------------------------------------------------------------------------------------------------------------------------------------
;showResults PROC
;procedure to show the results of the problem
;parameters: n, r, result, answer (by value)
;receives: string entered by the user
;returns: factorial solutions in the EAX
;preconditions: none
;registers changed: EAX, ecx, edx, 
;--------------------------------------------------------------------------------------------------------------------------------------------------

showResults PROC
.data
;output
result1				BYTE "There are ", 0
result2				BYTE " combinations of ", 0
result3				BYTE " items from a set of ", 0
result4				BYTE ".", 0
wrong				BYTE "You need more practice.", 0
correct				BYTE "You are correct!", 0

.code
	;save all registerS
	mov				aReg, eax					
	mov				bReg, ebx					
	mov				cReg ,ecx	
	mov				dReg, edx	
	push			ebp
	mov				ebp, esp
	mov				esi, [ebp+20]		;value of n
	mov				ebx, [ebp+16]		;value of r
	mov				ecx, [ebp+12]		;value of result
	mov				edx, [ebp+8]		;value of answer

	printString		result1				;displays the problem and answer
	mov				eax, ecx			;value of correct result 
	call			WriteDec			;is displayed

	printString		result2
	mov				eax, ebx			;value of r is displayed
	call			WriteDec

	printString		result3
	mov				eax, esi			;value of n is displayed
	call			WriteDec

	printString	 result4
	call			 CrLf
	cmp				ecx, edx			;eneterd value is compared to the value of the correct results
	je				right				;jump if equal
	printString		wrong				; if the answer that was entered is not correct, display the message
	call			 CrLf
	jmp				quit
right:									;if the answer is correct
	printString    correct
quit:
	call			CrLf
	call			CrLf
	;restores registers		
	mov				eax, aReg					
	mov				ebx, bReg				
	mov				ecx, cReg
	mov				edx, dReg
	pop				ebp
	ret				16

showResults ENDP

END main



