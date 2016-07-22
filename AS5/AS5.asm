TITLE Sorting Random Integers					(AS5.asm)
;*******************************************************************************************************************************************
; Author: Tatyana Vlaskin
; Course: CS 271					 Date: 11.15.2014
; Assignment: Program #5
; Description:  This program asks the user to enter the number of random numbers
;that they want to output on the screen. Once the number is entered, random numbers
;are generated, displayed on the screeen, sorts the list in descending order,
;displayes the median and displayed on the sorted list on the screen.
;
;Step by step instruction, taken from the assignment requirements:
;Write and test a MASM program to perform the following tasks:
;1. Introduce the program.
;2. Get a user request in the range [min = 10 .. max = 200].
;3. Generate request random integers in the range [lo = 100 .. hi = 999], storing them in consecutive elements of an array.
;4. Display the list of integers before sorting, 10 numbers per line.
;5. Sort the list in descending order (i.e., largest first).
;6. Calculate and display the median value, rounded to the nearest integer.
;7. Display the sorted list, 10 numbers per line.
;references: https://github.com/donatzm/CS271/blob/master/donatzm/Assignment05.asm
;			 lecture #19 
;			 lecture #20 --- i took a lot of code from that lecture
;			 lecture #14
;			 lecture #19a
;			 demo5.asm
;			 Assigmnet #4 --- reused some code from my assignment #4
;*******************************************************************************************************************************************


INCLUDE Irvine32.inc

;constants
MIN = 10									;Get a user request in the range [min = 10 .. max = 200], inclusive.
MAX = 200									;Get a user request in the range [min = 10 .. max = 200], inclusive.
LOW_LIMIT = 100								;random numbers will be generated in the range[lo = 100 .. hi = 999], inclusive
HI = 999									;random numbers will be generated in the range[lo = 100 .. hi = 999], inclusive
RANGE = HI - LOW_LIMIT + 1					;taken from lecture #20. 1st #s will be generated in the range [0..rang-1]. by adding
											;low limit to the generated #, the numbers will be in the range [low_limit..hi]


.data

.code
main PROC

.data
request			DWORD	?
array			DWORD	MAX DUP (?)
unsorted		BYTE	"The unsorted random numbers:", 0
sorted			BYTE	"The sorted list:", 0
medianMessage	BYTE	"The median is: ", 0


.code

	call	Randomize						;sets the randomizer seed
	call	introduction					;introduces the program

	push	OFFSET request					;pushes the address of the request on the stack [ebp+8]
	call	getData							;get data {parameters: request (reference)}	[ebp+4]

	push	OFFSET array					;pushes the address of the array on the stack [ebp+12]
	push	request							;pushes the number entered by the user on the stack [ebp+8]
	call	fillArray						;fill array {parameters: request (value), array (reference)} [ebp +4]

	push	OFFSET unsorted					;pushes address of the unsorted message on the stack [ebp+16]
	push	OFFSET array					;pushes address of the array on the stack [ebp+12]
	push	request							;pushes the request [number enetered by the user on the stack] [ebp+8]
	call	displayList						;call display procecure [ebp+4]
	
	push	OFFSET array					;address of the array pushed on the stack [ebp+12]
	push	request							;request is pushed on the stack [ebp+8]
	call	sortList						;call sortList, address of the next instructions is pushed on the stack [ebp+4]

	push	OFFSET medianMessage			;pushes address of the medianMessage message on the stack [ebp+16]
	push	OFFSET array					;pushes address of the array on the stack [ebp+12]
	push	request							;pushes the request [number enetered by the user on the stack] [ebp+8]
	call	displayMedian					;call displayMedian procecure [ebp+4]

	push	OFFSET sorted					;pushes address of the sorted message on the stack [ebp+16]	
	push	OFFSET array					;pushes address of the array on the stack [ebp+12]
	push	request							;pushes the request [number enetered by the user on the stack] [ebp+8]
	call	displayList						;call displaylist procecure [ebp+4]

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

.data
ProgramName		    BYTE	"Welcome to the Assignment 5: Sorting Random Integers by ", 0				
AuthorName			BYTE	"Tatyana Vlaskin. ", 0
Introduction1		BYTE	"This program generates random numbers in the range [100 .. 999]"
					BYTE	",",10, "displays the original list, sorts the list, and calculates "
					BYTE	"the", 10, "median value. Finally, it displays the list sorted in descending order.", 0

.code

	mov				edx, OFFSET programName
	call			WriteString								;prints program name
	mov				edx, OFFSET authorName
	call			WriteString								;prints authors name
	call			CrLf
	call			CrLf
	mov				edx, OFFSET Introduction1				;prints user instructions
	call			WriteString
	call			CrLf
	call			CrLf
	ret														;returns from procedure

introduction ENDP


;----------------------------------------------------------------------------------------------------------------------------------------
; getData PROC 
; Procedure to get and validate the number from the user 
; Receives: input from the user
; Returns:  Request in the ebp
; preconditions: none
; registers changed: ESP,EAX,EDX
; parameters: {request (reference)}
;-----------------------------------------------------------------------------------------------------------------------------------------

getData PROC

.data

prompt				BYTE	"How many numbers should be generated? [10 .. 200]: ", 0
error				BYTE	"Invalid input! Out of range! Try again. Acceptable numbers [10 .. 200]", 0

.code

push				ebp							;push old ebp on the stack, just to return to the original value
mov					ebp,esp						;esp is moved into the ebp

	Input:										;gets user input
		mov			edx, OFFSET prompt			;prepairs prompt
		call		WriteString					;writes the promp on the screen
		call		ReadInt						;takes the number, entered by the user and places the number in the EAX
		cmp			eax, MIN					;number < 10 invalid
		jl			invalid						;if the number is < 10, jump to invalid label
		cmp			eax, MAX					;if the number > 200, the number is invalid
		jg			invalid						;jump if greater > 200 to invalid lable
		jmp			valid						;unconditional jump --- if number is in the range 10-200

	
	invalid:									;lets the user know know the entry is invalid
		mov			edx, OFFSET error			;error is prepared
		call		WriteString					;error is displayed
		call		CrLf
		jmp			Input						; go back to the input label to request a different #

	valid:									    ;if the number is valid
		mov			ebx, [ebp + 8]				;address of request is at the ebp + 8 position. We move the value at that address 
												;in the EBX. See stack frame example in lecture #18
		mov			[ebx], eax					;user input which is in the EAX is stored in the request
		
		call		CrLf
		pop			ebp
		ret			4							;4+4 = 8 bytes is removed from the stack

getData ENDP



;----------------------------------------------------------------------------------------------------------------------------------------
; fillArray PROC
; procedure to fill array with user specified number of random numbers in the range [lo = 100 .. hi = 999]
; Receives: request 
; Returns: random numbers in the array
; preconditions: request enetered by the user was valid in the previous procedure
; registers changed: EAX, ESP,ECX,EDX
; parameters: request (value), array (reference)}
; this is taken from lecture #20
;-----------------------------------------------------------------------------------------------------------------------------------------

fillArray PROC

	push		ebp
	mov			ebp, esp
	mov			esi, [ebp+12]			;address of array in esi. this is the begining of the array
	mov			ecx, [ebp+8]			;ecx is loop control -- please note that [ebp+8] is where the request entered by the user is stored
	mov			edx, 0					;edx is element "pointer"

	more:								;loop to fill array
		mov		eax, RANGE				;per lecture 20, we need to put range into the eax. Range = hi-low +1
		call	RandomRange				;calculate pseudorandom number. results are in the eax in the range of [0 .....range-1]
		add		eax, LOW_LIMIT			; to get a number in the range [low...hi], we need to add low to the eax
		mov		[esi+edx], eax			;store in array
		add		edx, 4					;next element. dword is 4 bytes, so we need to add 4
		loop	more

		pop	ebp							;remove ebp from the stack
		ret	8							;remove 4+8 = 12 bytes from the stack. see lecture 20
fillArray ENDP


;----------------------------------------------------------------------------------------------------------------------------------------
; displayList PROC
; procedure to print array
; Receives: request 
; Returns: randome number in the array
; preconditions: request is valid
; registers changed: EDX, ESI,ESP,EAX,AL
;parameters: request (value), array (by reference), title (by reference)
;function is taken from lecture 20
;-----------------------------------------------------------------------------------------------------------------------------------------

displayList PROC
	push	ebp
	mov		ebp, esp
	mov		edx, [ebp+16]				;lists the "unsorted random list header"
	mov		esi, [ebp+12]				;address of array moved in the esi
	mov		ecx, [ebp+8]				;request is moved in the ecx, loop counter
	call	WriteString					;title is displayed
	call	CrLf
	call	CrLf
	mov		ebx, 10						;ebx is set to 10, this will be used to count # of numbers per line
more:									;loop to print array
	mov		eax, [esi]					;number at the array[0] is moved to the eax
	call	WriteDec					;# is writen on the screen
	dec		ebx							;ebx is decremeneted, we will print only 10 # per line
	cmp		ebx, 0						;ebx is compared to 0
	je		newLine						;if ebx = 0, we need to go the next line
	mov		al, TAB						;if the number will stay on the same line, we need to put pace between #s
	call	WriteChar					;space is displayed on the screen
	jmp		oldLine						;label ondLine will take us to the next # in the array

	newLine:
		call	CrLf					;line break after 10 numbers
		mov		ebx, 10					;reset ebx to 10, this will keep track of #s on the line

	oldLine:							;takes us to the next # in the array
		add		esi, 4					;esi is incremeneted by 4 because we are working with dwords.
		loop	more					;new number is generated
		call	CrLf					;when loop counter is 0
		pop		ebp						;pop ebp from the stack
		ret		8						;remove 8+4 =12 bytes from the stack


displayList ENDP


;----------------------------------------------------------------------------------------------------------------------------------------
; sortList PROC
; procedure to sort array (largest to smallest) using a bubble sort
; Receives: Nothing
; Returns: number
; preconditions: none
; registers changed: EAX, ESI, ECX,
; parameters: request (value), array (by reference)
; a lot of code is taken from lecture 14, 19, 19a, 20
;-----------------------------------------------------------------------------------------------------------------------------------------

sortList PROC
	push	ebp
	mov		ebp, esp
	mov		ecx, [ebp+8]			;request in ecx, will be used as a loop counter
	dec		ecx						;decrement loop counter

L1:									;outer loop
	push	ecx						;ecx is pushed on the stack
	mov		esi, [ebp+12]			;address of array in esi
L2:									;inner loop
	mov		eax, [esi]				;[esi] is the number at the corrsponding index
	cmp		[esi+4], eax			;compares consecutive numbers
	jl		L3						; if the number at the smaller index is large than go to label L3, which tells you go to the next #
	xchg	eax, [esi+4]			; if the # at the larger index is greater than at the smaller index, #s are switched
	mov		[esi], eax
L3:									;move on to the next #
	add		esi, 4					; to go to the next #, we need to add 4 to the esi
	loop	L2						;#s are compared in L2
	pop		ecx						; when the loops counter is 0, we restore the outer loop, see nested loop example in lecure 14
	loop	L1						;repeat the outer loop
	pop		ebp						;pop ebp from the stack
	ret		8						;remove 8+4 =12 bytes from the stack

sortList ENDP


;----------------------------------------------------------------------------------------------------------------------------------------
; displayMedian PROC
; procedure to display the median
; Receives: Nothing
; Returns: number
; preconditions: none
; registers changed: EAX
; parameters: request (value), array (by reference)
;-----------------------------------------------------------------------------------------------------------------------------------------

displayMedian PROC

.data
median BYTE ?

.code
	push	ebp
	mov		ebp, esp
	mov		edx, [ebp+16]			;median title is moved to the edx
	mov		esi, [ebp+12]			;address of array in esi
	mov		ecx, [ebp+8]			;request in ecx - this is out loop counter
	call	WriteString				; the median message is displayed on the screen
	call	CrLf	
	call	CrLf				
	
									; we need to check if the # of elements in the array is odd or even		
	mov	edx, 0						;set edx to 0
	mov	eax, ecx					;request is moved to the eax
	mov	ebx, 2						;2 is moved to exb
	div	ebx							; we divide eax/ebx
	cmp	edx, 0						; compare the value is the edx, which stores remainder of the division
	jne	odd							; if remainder is NOT equal to 0, this is the indication that we have odd # of elements in	
									;the array, we need to jump to odd lable to find the median

								    ; if even array, median is average of two middle numbers
	mov		edx, eax				;eax has the request, we move it to the edx
	mov		eax, 0					
	add		eax, [esi+edx*4]		;1st middle #
	dec		edx			
	add		eax, [esi+edx*4]		;2nd middle #
	mov		edx, 0					;set edx to 0, this will store remainder
	mov		ebx, 2					; ebx is moved to 2
	div		ebx						; eax, which has the sum of 2 middle #s is divided by 2 
	cmp		edx, 0					; check if the remander of the division is 0
	je		noRound					;jump if equal, this is the indication that we do not need to round the #
	inc		eax						; if there is a remainder, i round up-- i am running of time, so I cannnot figure out 
									; how to round to the closers #	

			;----------------------------------WORK ON THIS IF YOU HAVE TIME AFTER QUIZ		
			;take the remainder and compare it to the quotion  
			;mov		ecx, eax

			;cmp		edx, eax
			;jl		noRound										;jump if less
			;inc		eax											;if not less, the average/median needs to be incemeneted by 1
			;jmp		noRound										;jump unconditionally	to RESULTS
			;------------------------------------------------

noRound:
		mov		edx, OFFSET median					;prepair median 
		call	WriteString							;display median
		call	WriteDec
		call	CrLf
		jmp		return							
		
odd:													;if odd, array middle number
		mov		edx, eax
		mov		eax, [esi+edx*4]						;find the median #
		mov		edx, OFFSET median						; prepairs the median #
		call	WriteString								;writes the median # message
		call	WriteDec								;write the # on the screen
		call	CrLf
	return:
		call	CrLf
		pop		ebp
		ret		8										;removes 12 bytes from the stack
displayMedian ENDP

END main