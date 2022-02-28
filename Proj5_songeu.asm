TITLE Arrays, Addressing, and Stack-Passed Parameters     (Proj5_songeu.asm)

; Author: Eugene Song
; Last Modified: February 27, 2022
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

	intro1			BYTE	"The Birth of Sorted Random Integers! By Eugene...",13,10,13,10, 0
	intro2			BYTE	"This program's objective is to pump out 200 random integers from 15 through 50. It will display ",13,10
					BYTE	"and sort the original list containing the integers, display its median value, then rearrange ",13,10
					BYTE	"and output the list in ascending order and finally show the number of instances of each ",13,10 
					BYTE	"generated value, starting with the number of 10s.",13,10,13,10,0
	unsorted_label	BYTE	"Your unsorted random numbers:",13,10, 0
	median_label	BYTE	"The median value of the array: ",0 
	sorted_label	BYTE	"Your sorted random numbers:", 13,10, 0 
	instance_label	BYTE	"Your list of instances of each generated number, starting with the number of 15s:",13,10, 0
	farewell_msg	BYTE	"Goodbye and see you in Project 6!", 13,10, 0 
	space			BYTE	" ", 0 

	randArray		DWORD	ARRAYSIZE DUP (?)	
	arrayCount		DWORD	LENGTHOF randArray	
	numPerLine		DWORD	20
	counts			DWORD	HI-LO+1 DUP(?)
	countsCount		DWORD	LENGTHOF counts


.code
main PROC

	CALL	Randomize				; plant random seed 
	
	; ------------------------------------------------------------------
    ; Introduces title of program, author, and objective. 
    ; ----------------------------------------------------------
	PUSH	OFFSET intro1			
	PUSH	OFFSET intro2			
	CALL	introduction

	; ------------------------------------------------------------------------
    ; Fills empty array, randArray, with random numbers using 
    ;	RandomRange in any order.
    ; ----------------------------------------------------------
	PUSH	arrayCount			
	PUSH	OFFSET randArray
	CALL	fillArray

	; ------------------------------------------------------------------------
    ; Displays the array of unsorted random numbers. The numbers are  
	;	printed onto a new line after every 20 numbers with a space
	;		in between each number.
    ; --------------------------------------------------------------------
	PUSH	OFFSET unsorted_label
	PUSH	OFFSET randArray
	PUSH	OFFSET space
	PUSH	numPerLine
	PUSH	arrayCount
	CALL	displayList
	
	; ------------------------------------------------------------------------
    ; The array filled with random numbers is sorted using a   
	;		bubble-sort algorithm.
    ; ------------------------------------------------------------------
	PUSH	OFFSET randArray
	PUSH	arrayCount
	CALL	sortList

	; ---------------------------------------------------------------------------
    ; Displays the median value of the sorted array. If there is an 
	;		even number of numbers, the average of the middle two values with 
	;			the inclusion of the round up estimate is displayed. 
	;				If odd, the middle number is displayed.
    ; ------------------------------------------------------------------------
	PUSH	OFFSET median_label
	PUSH	OFFSET randArray
	CALL	displayMedian 

	; ------------------------------------------------------------------------
    ; Displays the array of sorted random numbers. Again, the numbers   
	;	are printed onto a new line after every 20 numbers with a 
	;		space in between each number.
    ; ---------------------------------------------------------------------
	PUSH	OFFSET sorted_label
	PUSH	OFFSET randArray
	PUSH	OFFSET space
	PUSH	numPerLine
	PUSH	arrayCount
	CALL	displayList
	
	; ------------------------------------------------------------------------
    ; Fills a second array, counts, with the number of occurrences of   
	;	each unique value in the sorted array. The numbers are printed 
	;		representing each number from LO through HI. 0 is also printed
	;			for values with no occurences. 
    ; -----------------------------------------------------------------------
	PUSH	OFFSET randArray
	PUSH	OFFSET counts
	CALL	countList 

	; -----------------------------------------------------------------------
    ; Displays the array of occurrences for each unique value from  
	;	the sorted array. The numbers are also printed onto a new line 
	;		after every 20 numbers with a space in between each number.
    ; --------------------------------------------------------------------
	PUSH	OFFSET instance_label
	PUSH	OFFSET counts
	PUSH	OFFSET space
	PUSH	numPerLine
	PUSH	countsCount
	CALL	displayList
	CALL	CrLf

	; -----------------------------------------------
    ; Displays a goodbye message.   
    ; ----------------------------------
	PUSH	OFFSET farewell_msg
	CALL	goodBye
	
	Invoke ExitProcess,0
main ENDP

; ---------------------------------------------------------------------------------
; Name: introduction
;
; Introduces program title, program author and program description.
;
; Preconditions: the strings must be type BYTE
;
; Postconditions: EDX changed.
;
; Receives:
;		[esp+12]	= address of intro1
;		[esp+8]		= address of intro2 
;
; Returns: n/a
; ---------------------------------------------------------------------------------
introduction PROC

	PUSH	EBP						; Step 1) Preserve EBP
	MOV		EBP, ESP				; Step 2) Assign static stack-frame pointer

	MOV		EDX, [ESP+12]			; move +12 bytes from ESP to grab intro1  [base + offset] 
	CALL	WriteString
	XOR		EDX, EDX
	MOV		EDX, [ESP+8]			; move +8 bytes from ESP to grab intro2	[base + offset]
	CALL	WriteString
	XOR		EDX, EDX
	
	POP		EBP						; POP EBP before RET
	RET		8						; clears pre-call introduction parameters including RET[stack pointer reset]

introduction ENDP

; ---------------------------------------------------------------------------------
; Name: fillArray
;
; Stores random numbers into empty array.
;
; Preconditions: 
;		the array must be type DWORD
;		CALL Randomize 
;
; Postconditions: n/a
;
; Receives:
;		[esp+8]		= address of randArray
;		[esp+12]	= length of randArray (arrayCount)
;		HI, LO are global variables
;
; Returns: 
;		array filled with random numbers in no particular order
;		[EDI+ECX*4]
; ---------------------------------------------------------------------------------
fillArray PROC

	PUSH	EBP						
	MOV		EBP, ESP
	XOR		ECX, ECX

_loopMe:
	MOV		EAX, HI						; upper bound
	ADD		EAX, 1						; EAX + 1 to include upper range
	CALL	RandomRange				
	MOV		EBX, LO						; lower bound
	PUSH	EAX							; store seed value --> stack
	MOV		EAX, HI
	ADD		EAX, 1					
	SUB		EAX, EBX				

	; --------------------------------------------------------------------
    ;	Switch EAX / EBX to prepare for div 
	;		Algorithm to generate random num within range:
	;			randomNum = seed % (upper-lower) + lower
    ; -----------------------------------------------------------
	MOV		EBX, EAX
	POP		EAX	 

	; --------------- at this point, EAX (seed) / EBX (upper-lower) ----------
	XOR		EDX, EDX
	DIV		EBX						

	MOV		EBX, LO
	ADD		EDX, EBX		

	; ------------ at this point, EDX has the randomNum btwn LO & HI -------------
	MOV		EAX, EDX

	; store/fill in array
	MOV		EDI, [ESP+8]			; reference 1st address of randArray
	MOV		[EDI+ECX*4], EAX		; algorithm to store into each index of array 
	MOV		EBX, [ESP+12]			; move arrayCount --> EBX
	INC		ECX

	; compare to array length
	CMP		ECX, EBX					
	JNE		_loopMe					; if ECX (counter) < randArray.length()

	POP		EBP
	RET		12
		
fillArray ENDP

; ---------------------------------------------------------------------------------
; Name: displayList
;
; Displays the contents of an array from smallest index to largest index.
;
; Preconditions: 
;		the array must be type DWORD 
;
; Postconditions: EAX changed
;
; Receives:
;		[ESP+24]		= address of label for array				STACK 
;		[ESP+20]		= address of passed array					------- ESP ------------
;		[ESP+16]		= address of space							POP EBP	
;		[ESP+12]		= address of numbers per line				SIZE OF ARRAY
;		[ESP+8]			= address of size of array					NUM PER LINE
;																	OFFSET SPACE (" ")
;																	OFFSET ARRAY
;																	OFFSET LABEL
; Returns: n/a
;
; ---------------------------------------------------------------------------------
displayList PROC 

	PUSH	EBP					
	MOV		EBP, ESP								
								
	MOV		EDX, [ESP+24]		
	CALL	WriteString
	XOR		ECX, ECX
	MOV		EDI, [ESP+20]			

	; --------------------------------------------------------------------------------
    ;	Start of loop to begin iterating through and printing each value of array
    ; -----------------------------------------------------------------------------
_displayLoop:
	MOV		EAX, [EDI + ECX * 4]	; store each value of randArray into EAX to print
	CALL	WriteDec
	MOV		EDX, [ESP+16]		
	CALL	WriteString
	XOR		EDX, EDX

	INC		ECX						; increment counter each time a num is displayed

	; -----------------------------------------------------------------------------
    ;	Insert new line
    ; --------------------------------------------------------------------
	MOV		EBX, [ESP+12]			; store numPerLine into EBX to use as divisor
	MOV		EAX, ECX 
	DIV		EBX
	CMP		EDX, 0					; compare numPerLine after printing first num

	JNE		_keepPrinting			; if remainder != 0 (20 does not divide index of printed num) 
	CALL	CrLf

	; check whether # displayed == length array
_keepPrinting:
	MOV		EAX, [ESP+8]
	CMP		ECX, EAX
	JNE		_displayLoop
	POP		EBP
	CALL	CrLf
	RET		20

displayList	ENDP

; ---------------------------------------------------------------------------------
; Name: sortList
;
; Sorts the contents of the passed array in ascending order. 
;
; Preconditions: 
;		the array must be type DWORD 
;
; Postconditions: n/a
;
; Receives:
;		[esp+8]		= address of array count
;		[esp+12]	= address of array
;
; Returns: 
;		array in ascending order
; ---------------------------------------------------------------------------------
sortList PROC

	PUSH	EBP						
	MOV		EBP, ESP

	MOV		ECX, [ESP+8]			; store outer loop counter for bubble sort  
	
	; iterate through each index once 
_outerLoop:  
	MOV		ESI, [ESP+12]			; syntax: MOV ESI, source_address (reference of first value) 
	MOV		EDX, ECX				; stores ECX value into EDX 
	MOV		ECX, [ESP+8]			; reset ECX's value to 200 after each outer iteration

_innerLoop:	
	MOV		EAX, [ESI]				; store first val
	MOV		EBX, [ESI+4]			; store second val
	CMP		EAX, EBX
	JLE		_goBackUp

	PUSH	ESI						; push element one reference
	ADD		ESI,4
	PUSH	ESI						; push element two reference
	SUB		ESI, 4					; reset value of ESI for inner loop
	
	MOV		[ESI], EBX
	MOV		[ESI+4], EAX
	CALL	exchangeElements		; swap elements
	
_goBackUp:

	ADD		ESI, 4					; increment by 4 memory addresses once nums have been checked
	CMP		ECX, 1h					; iterate (arraySize-1) times so I don't go out of array range
	JE		_exitInner
	LOOP	_innerLoop				

_exitInner:

	MOV		ECX, EDX
	LOOP	_outerLoop

	POP		EBP
	RET		8

sortList ENDP

; ---------------------------------------------------------------------------------
; Name: exchangeElements
;
; Swaps the value of the first index with the value of the next index using the 
;		bubble-sort algorithm.
;
; Preconditions: 
;		the array must be type DWORD 
;
; Postconditions: n/a
;
; Receives:
;		[ESP+12]		= address of first value 
;		[ESP+8]			= address of second value
;
; Returns: 
;		array with two values swapped
; ---------------------------------------------------------------------------------
exchangeElements PROC

	PUSH	EBP							
	MOV		EBP, ESP					

	MOV		EAX, [ESP+12]				; grab ESI location 
	MOV		EBX, [ESP+8]				; grab ESI + 4 location 

; turn EAX / EBX into their stack location's values 
	PUSH	EAX
	MOV		EAX, [EBX]
	POP		EBX
	PUSH	EAX
	MOV		EAX, [EBX]
	POP		EBX

; swap the two values in registers
	XCHG	EBX, EAX

; store back into respective array slots
	MOV		[ESI+4], EAX
	MOV		[ESI], EBX

	POP		EBP
	RET		8
exchangeElements ENDP

; ---------------------------------------------------------------------------------
; Name: displayMedian
;
; Displays the median of the passed array. 
;		Even number length: average of middle two numbers + round-up estimate = median
;		Odd number length: middle number = median
;
; Preconditions: 
;		the array must be type DWORD
;		the array must be sorted
;
; Postconditions: EDX changed
;
; Receives:
;		[ESP+8]			= address of filled sorted array 
;		[EBP+12]		= address of median label
;		ARRAYSIZE is a global variable
;
; Returns: 
;		eax = median integer
; ---------------------------------------------------------------------------------
displayMedian PROC

	PUSH	EBP						
	MOV		EBP, ESP	
	
	; display median label
	MOV		EDX, [EBP+12]			
	CALL	WriteString	

	; ----------------------------------------------------------------------------------------------
    ;	Check length of ARRAYSIZE...
	;		Adjust accordingly if even or odd
    ; ----------------------------------------------------------------------------
	XOR		EDX, EDX
	MOV		EAX, ARRAYSIZE	
	MOV		EBX, 2
	DIV		EBX						 

	CMP		EDX, 0
	JE		_evenNum

	; do odd
	XOR		EDX, EDX
	MOV		EDI, [ESP+8]					; reference ADDRESS of filled randArray into EDI
	DEC		EAX
	MOV		EAX, [EDI + EAX * 4]			; move [4*index number] places in the array (middle value since odd)
	CALL	WriteDec							
	JMP		_finish

	; do even
_evenNum:
	XOR		EDX, EDX
	MOV		EDI, [ESP+8]			
	PUSH	EAX
	DEC		EAX
	MOV		EAX, [EDI + EAX * 4]			;  store (arrayCount / 2)-nth index value 
	POP		EBX
	MOV		EBX, [EDI + EBX * 4]			; store (arrayCount / 2 + 1)- nth index value

	ADD		EAX, EBX 
	MOV		EBX, 2
	DIV		EBX

	CMP		EDX, 0
	JE		_noAdd
	INC		EAX							; account for half-round up here 
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

; ---------------------------------------------------------------------------------
; Name: countList
;
; Stores the number of iterations of each unique value from sorted array into 
;		a separate array.
;
; Preconditions: 
;		array1 must be type DWORD
;		array2 must be type DWORD
;
; Postconditions: n/a
;
; Receives:
;		[ESP+8]			= address of counts array
;		[EBP+12]		= address of randArray
;		LO, HI, ARRAYSIZE are global variables
;
; Returns: 
;		an array with the counts of unique values
; ---------------------------------------------------------------------------------
countList PROC

	PUSH	EBP
	MOV		EBP, ESP

	MOV		EDI, [EBP+8]					; reference countArray ADDRESS (EDI)
	MOV		ESI, [EBP+12]					; reference randArray ADDRESS (ESI)			

	MOV		EBX, 0							
	PUSH	EBX
	
	MOV		EAX, LO
	MOV		EBX, 0							; clear counter (EBX)
	MOV		ECX, 0							; clear counter that loops through each value

	; --------------------------------------------------------------------
    ; Block of code to iterate through randArray and compare value
    ;     of first element in EAX. If equal, increment counter. 
    ; --------------------------------------------------------------------
_top:

	CMP		EAX, [ESI+ECX*4]
	JNE		_middle
	INC		EBX								; if EAX == to the value in sorted array [ESI+ECX*4]
	
	; ------------------------------------------------------------------------
    ; Code to see which value is being compared between EAX and ECX   
    ; ------------------------------------------------------------------------
_middle:
	INC		ECX
	CMP		ECX, ARRAYSIZE
	JNE		_top							; check only from 0 through ARRAYCOUNT b/c [ESI] is index 0
	XOR		ECX, ECX						; clear ECX since we've already looped thru entire randArray to check

	; ----------------------------------------------------
    ; Store EBX (# of counts) into counts array  
    ; -----------------------------------------------
	POP		ECX
	MOV		[EDI+ECX*4], EBX				;each time <-- counter == # of indices 
	INC		ECX
	PUSH	ECX

_nextNum:
	INC		EAX								; holds LO through HI
	XOR		EBX, EBX						; clear EBX (counter) to use for next num 

	XOR		EDX, EDX
	MOV		EDX, HI
	CMP		EAX, EDX
	JNG		_top							; JNG b/c INC EAX will 50 -> 51..check 50 

_finish:
	POP		EBX
	POP		EBP
	RET		8

countList ENDP

; ---------------------------------------------------------------------------------
; Name: goodBye
;
; Displays parting message.
;
; Preconditions: String must be type BYTE. 
;
; Postconditions: EDX changed
;
; Receives:
;		[ESP+8]			= address of farewell string
;
; Returns: n/a
;
; ---------------------------------------------------------------------------------
goodBye PROC

	PUSH	EBP
	MOV		EBP, ESP
	XOR		EDX, EDX
	MOV		EDX, [ESP+8]					; store farewell string 
	CALL	WriteString
	POP		EBP
	RET		4

goodBye ENDP

END main
