TITLE Arrays, Addressing, and Stack-Passed Parameters     (Proj5_songeu.asm)

; Author: Eugene Song
; Last Modified: February 23, 2022
; OSU email address: songeu@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 5             Due Date: February 27, 2022
; Description: This program will introduce the program and the author. Then it will provide a description
;					of what the program will do. It will generate 200 random numbers between a range from
;						10 through 29, sort the list, display the medium value, display the list in ascending 
;							order and finally display the number of instances of each value in the list. 

INCLUDE Irvine32.inc

ARRAYSIZE = 200
LO = 15
HI = 50 



.data

	intro1			BYTE	"The Birth of Sorted Random Number Integers! By Eugene",13,10,13,10, 0
	intro2			BYTE	"This program's objective is to pump out 200 random integers from 15 through 50. It will display ",13,10
					BYTE	"and sort the original list containing the integers, display its median value, then rearrange ",13,10
					BYTE	"and output the list in ascending order and finally show the number of instances of each ",13,10 
					BYTE	"generated value, starting with the number of 10s.",13,10,13,10,0
	unsorted_label	BYTE	"Your unsorted random numbers:",13,10, 0
	median_label	BYTE	"The median value of the array: ",0 
	sorted_label	BYTE	"Your sorted random numbers:", 13,10, 0 
	instance_label	BYTE	"Your list of instances of each generated number, starting with the number of 15s:",13,10, 0
	farewell_msg	BYTE	"Goodbye, and thanks for coming!", 13,10, 0 
	space			BYTE	" ", 0 

	someArray		DWORD	ARRAYSIZE DUP (?)	
	arrayCount		DWORD	LENGTHOF someArray	
	numPerLine		DWORD	20
	countArray		DWORD	?




.code
main PROC
	CALL	Randomize				; random seed 
	
	; introduction
	PUSH	OFFSET intro1			; push intro1 to stack
	PUSH	OFFSET intro2			; push intro2 to stack
	CALL	introduction

	; fill array first
	PUSH	arrayCount			
	PUSH	OFFSET someArray		; push empty array onto stack
	CALL	fillArray

	; display unsorted random nums 
	PUSH	OFFSET unsorted_label
	PUSH	OFFSET someArray
	PUSH	OFFSET space
	PUSH	numPerLine
	CALL	displayList
	
	; sort list before outputting the median value
	PUSH	OFFSET someArray
	PUSH	arrayCount
	CALL	sortList

	; display the median value of sorted random nums
	PUSH	OFFSET median_label
	PUSH	OFFSET someArray
	CALL	displayMedian 

	; display sorted random nums
	PUSH	OFFSET sorted_label
	PUSH	OFFSET someArray
	PUSH	OFFSET space
	PUSH	numPerLine
	CALL	displayList
	
	; generate new array of counts
	PUSH	OFFSET someArray
	PUSH	OFFSET countArray
	CALL	countList 

	; display the new array of counts
	;PUSH	OFFSET instance_label
	;PUSH	OFFSET countArray
	;PUSH	OFFSET space
	;PUSH	numPerLine
	;CALL	displayList

	; display good bye msg
	;PUSH	OFFSET farewell_msg
	;CALL	goodBye
	



	Invoke ExitProcess,0			; exit to operating system
main ENDP

introduction PROC

	PUSH	EBP						; Step 1) Preserve EBP
	MOV		EBP, ESP				; Step 2) Assign static stack-frame pointer

	MOV		EDX, [ESP+12]			; move +12 bytes from ESP to store intro1  [base + offset] 
	CALL	WriteString
	XOR		EDX, EDX
	MOV		EDX, [ESP+8]			; move +8 bytes from ESP to store intro2	[base + offset]
	CALL	WriteString
	XOR		EDX, EDX
	
	POP		EBP
	RET		8						; clears pre-call introduction parameters [stack pointer reset]

introduction ENDP

fillArray PROC

	PUSH	EBP						; Step 1) Preserve EBP
	MOV		EBP, ESP				; Step 2) Assign static stack-frame pointer

	; generate arraySize-n random numbers

	XOR		ECX, ECX
_loopMe:

	MOV		EAX, HI					; upper bound
	ADD		EAX, 1					; EAX + 1 to include upper range
	CALL	RandomRange				; takes EAX (upper); outputs new EAX 
	MOV		EBX, LO
	PUSH	EAX						; store seed value --> stack
	MOV		EAX, HI
	ADD		EAX, 1					; to include upper range again
	SUB		EAX, EBX				; upper - lower --> EAX

		; switch EAX / EBX to prepare for div
	MOV		EBX, EAX
	POP		EAX						; popped off seed --> EAX 

		; EAX (seed) / EBX (upper-lower) at this point
	XOR		EDX, EDX
	DIV		EBX						; randomNum = seed % (upper-lower) + lower

	MOV		EBX, LO
	ADD		EDX, EBX		

		; at this point, EDX has the randomNum btwn LO & HI

	MOV		EAX, EDX				; EAX has randomNum btwn LO & HI

	; store/fill in array
	MOV		EDI, [ESP+8]			; reference 1st address of someArray
	MOV		[EDI + ECX * 4], EAX	; algorithm to store into each index of array 
	MOV		EBX, [ESP+12]			; move arrayCount --> EBX
	INC		ECX

	; compare to array length
	CMP		ECX, EBX					
	JNE		_loopMe					; if counter < array.length(someArray)

	POP		EBP
	RET		12
		
fillArray ENDP

displayList PROC

; ONLY ONE DISPLAYLIST PROC for 3 different arrays to print; therefore universally PUSH labels / values the 


	PUSH	EBP						; Step 1) Preserve EBP
	MOV		EBP, ESP				; Step 2) Assign static stack-frame pointer

	; STACK
	; --------------------------
	; POP EBP
	; RET ADDRESS
	; NUM PER LINE
	; OFFSET SPACE (" ")
	; OFFSET ARRAY
	; OFFSET LABEL

	MOV		EDX, [ESP+20]			; LABEL OFFSET IS ALWAYS @ BOTTOM MOST OF STACK			
	CALL	WriteString
	XOR		ECX, ECX				; cleared ECX to start iteration

	MOV		EDI, [ESP+16]			; reference 1st address of filled someArray into EDI

	; begin iterating through and printing each value of array
_displayLoop:
	MOV		EAX, [EDI + ECX * 4]	; store each value of array into EAX to print
	CALL	WriteDec
	MOV		EDX, [ESP+12]			; create space after each number
	CALL	WriteString

	XOR		EDX, EDX				; clear EDX to use in DIV

	INC		ECX						; increment counter each time num is displayed

	; insert new lines here 

	MOV		EBX, [ESP+8]			; store numPerLine into EBX to use as divisor
									; compare numPerLine after printing first num
	MOV		EAX, ECX 
	DIV		EBX
	CMP		EDX, 0

	JNE		_keepPrinting			; if remainder != 0 (IE...20 does not divide index of printed num) 
	CALL	CrLf

_keepPrinting:
	; check whether # displayed is == length array
	CMP		ECX, ARRAYSIZE
	JNE		_displayLoop

	POP		EBP
	CALL	CrLf
	RET		16

displayList	ENDP

sortList PROC

	; BUBBLE SORT (n^2) 
	; NESTED LOOP

	PUSH	EBP						; Step 1) Preserve EBP
	MOV		EBP, ESP				; Step 2) Assign static stack-frame pointer

	MOV		ECX, [ESP+8]			; store outer loop counter for bubble sort  
	
_outerLoop: ; do nothing except iterate through each index once 
	
	MOV		ESI, [ESP+12]			; syntax: MOV ESI, source_address (reference of first value) 
	MOV		EDX, ECX				; stores ECX value into EDX 

	MOV		ECX, [ESP+8]			; reset ECX's value to 200 after each outer iteration

_innerLoop:	

	; address of index 0 of filled array
	MOV		EAX, [ESI]				; store first value into EAX to compare
	MOV		EBX, [ESI+4]			; store second value into EBX to compare

	CMP		EAX, EBX
	JLE		_goBackUp

	
	PUSH	ESI						; push element one reference
	ADD		ESI,4
	PUSH	ESI						; push element two reference
	SUB		ESI, 4					; reset value of ESI for inner loop
	
	MOV		[ESI], EBX
	MOV		[ESI+4], EAX

	; swap elements
	CALL	exchangeElements
	
_goBackUp:

	ADD		ESI, 4					; increment by 4 memory addresses once nums have been checked
	CMP		ECX, 1h				; only want to iterate through innerLoop 199 times so I don't go out of array range
	JE		_exitInner
	LOOP	_innerLoop				

_exitInner:

	MOV		ECX, EDX
	LOOP	_outerLoop

	POP		EBP
	RET		8

sortList ENDP

exchangeElements PROC

	PUSH	EBP							; standard ebp push
	MOV		EBP, ESP					; standard static base pointer
	MOV		EAX, [ESP+12]				; grab ESI location 
	MOV		EBX, [ESP+8]				; grab ESI + 4 location 

; turn EAX / EBX into their stack location's values 
	PUSH	EAX
	MOV		EAX, [EBX]
	POP		EBX
	PUSH	EAX
	MOV		EAX, [EBX]
	POP		EBX

; exchange the two values 
	XCHG	EBX, EAX

; store back into respective array slots
	MOV		[ESI+4], EAX
	MOV		[ESI], EBX

	POP		EBP
	RET		8
exchangeElements ENDP

displayMedian PROC

	PUSH	EBP						; Step 1) Preserve EBP
	MOV		EBP, ESP				; Step 2) Assign static stack-frame pointer

	MOV		EDX, [EBP+12]			
	CALL	WriteString

	; check length of array size
	XOR		EDX, EDX				; clear EDX to use for div
	MOV		EAX, ARRAYSIZE	
	MOV		EBX, 2
	DIV		EBX						 

	CMP		EDX, 0
	JE		_evenNum

	; do odd
	XOR		EDX, EDX
	MOV		EDI, [ESP+8]			; reference 1st address of filled someArray into EDI
	DEC		EAX
	MOV		EAX, [EDI + EAX * 4]	; move [4 x index number] places in the array (middle value since odd)
	CALL	WriteDec							
	JMP		_finish

_evenNum:
	; do even
	XOR		EDX, EDX
	MOV		EDI, [ESP+8]			; reference 1st address of filled someArray into EDI
	PUSH	EAX
	DEC		EAX
	MOV		EAX, [EDI + EAX * 4]	;  store (arrayCount / 2)-nth index value 
	POP		EBX
	MOV		EBX, [EDI + EBX * 4]	; store (arrayCount / 2 + 1)- nth index value

	ADD		EAX, EBX 
	MOV		EBX, 2
	DIV		EBX

	CMP		EDX, 0
	JE		_noAdd
	INC		EAX						; half- round up here 
	CALL	WriteDec
	JMP		_finish

_noAdd:
	CALL	WriteDec

_finish:

	CALL	CrLf
	CALL	CrLf
	POP		EBP
	RET		8

displayMedian ENDP

countList PROC
	
	PUSH	EBP
	MOV		EBP, ESP

	MOV		
_top:


_middle:


_finish:


	POP		EBP
	RET		8

countList ENDP







goodBye PROC

	PUSH	EBP
	MOV		EBP, ESP

	XOR		EDX, EDX
	MOV		EDX, [ESP+8]
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf

	POP		EBP
	RET		4

goodBye ENDP











END main
