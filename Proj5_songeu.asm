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
	intro2			BYTE	"This program generates 200 random numbers in the range [15 ... 50], displays the ",13,10
					BYTE	"original list, sorts the list, displays the median value of the list, displays the ",13,10
					BYTE	"list sorted in ascending order, then displays the number of instances of each ",13,10 
					BYTE	"generated value, starting with the number of 10s.",13,10,13,10,0
	unsorted_label	BYTE	"Your unsorted random numbers:",13,10, 0
	median_label	BYTE	"The median value of the array: ", 13,10,0 
	sorted_label	BYTE	"Your sorted random numbers:", 13,10, 0 
	instance_label	BYTE	"Your list of instances of each generated number, starting with the number of 10s:",13,10, 0
	farewell_msg	BYTE	"Goodbye, and thanks for coming!", 13,10, 0 



.code
main PROC

;	CALL Randomize			; random seed

	PUSH	OFFSET intro1	; push intro1 to stack
	PUSH	OFFSET intro2	; push intro2 to stack
	CALL introduction

	; fillArray
	; sortList
	; exchangeElements
	; displayMedian 
	; displayList
	; countList 


	Invoke ExitProcess,0	; exit to operating system
main ENDP

introduction PROC

	PUSH  EBP				; Step 1) Preserve EBP
	MOV   EBP, ESP			; Step 2) Assign static stack-frame pointer

	MOV		EDX, [ESP+12]	; move +12 bytes from ESP to store intro1 
	CALL	WriteString
	xor		EDX, EDX
	mov		EDX, [ESP+8]	; move +8 bytes from ESP to store intro2
	CALL	WriteString
	xor		EDX, EDX
	
	pop		EBP

	RET		8

introduction ENDP

END main
