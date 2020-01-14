; Row Sum Calculation					(salesman.asm)

; This program demonstrates the use of Base-Index addressing 
; with a two-dimensional table array of bytes (a byte matrix).

INCLUDE Irvine32.inc

enterData PROTO, rw:BYTE, clm:BYTE, sm:BYTE
	
.data

row BYTE 0
column BYTE 0
sum BYTE 0
tableB  BYTE  0,  0,  0,  0,  0
        BYTE  0,  0,  0,  0,  0
        BYTE  0,  0,  0,  0,  0
		BYTE  0,  0,  0,  0,  0

RowSize = 5		; size of each row
msg1 BYTE "Enter the salesman number (1-4): ",0
msg2 BYTE "Enter the product number (1-5): ",0
msg3 BYTE "Enter the sum : ",0
msg4 BYTE "The Sum of sales person ", 0 
msg5 BYTE ": "

.code
main PROC

	
	L1:
	mov	edx,OFFSET msg1		; "Enter row number:"
	call WriteString		; write msg1 to the terminal
	call Readint			; EAX = row number, will point to the first number in the row
	cmp al, -1				; compare sales person to -1
	je L2					; if -1, sum up the rows
	mov row, al				; else, continue
	mov edx, OFFSET msg2	; move the second message into edx
	call WriteString		; write msg2 to the terminal
	call Readint			; read input, which goes into eax
	mov column, al			; move al register to column
	mov edx, OFFSET msg3	; move the thrid message into edx
	call WriteString		; write msg3 (edx) to the terminal
	call Readint			; read input
	mov sum, al				; move sum to the al register
	
	invoke enterData, row, column, sum		; go to the enterData procedure
	loop L1


	L2:

	call  Crlf
	call  calc_row_sum				; EAX = sum
	
	exit

main ENDP



enterData PROC, rowIndex:BYTE, columnIndex:BYTE, sm:BYTE

	dec rowIndex					; decrement the row by 1
	dec ColumnIndex					; decrement the column by 1
	mov	  ebx,OFFSET tableB			; memory location of the 2d array
	movzx   eax, rowIndex			; mov the row index to eax
	mov	  ecx,RowSize				; ecx is 5, same as row size
	mul	  ecx						; row index * row size
	add	  ebx, eax					; row offset
	movzx   esi, columnIndex		; row index
	mov al, sm						; moving the sum to the al register
	mov BYTE PTR[ebx + esi], al		; moving the sum to the index of the "2d" array

ret
enterData ENDP


calc_row_sum PROC uses ebx ecx edx esi


	push ebp			; pushing epb onto the stack
	mov ebp, esp		; having esp point to the address of the stack
	sub esp, 12			; creating room for a local variable, which will determine when the nested loop ends
	mov DWORD PTR [ebp - 4], 0		; move 0 to the stack
	mov DWORD PTR [ebp - 8], 0		; represents the sum
	mov DWORD PTR [ebp - 12], 1		; represents sales person
	outerLoop:
		mov	  ebx,OFFSET tableB			; memory location of the 2d array
		cmp DWORD PTR [ebp - 4], 4		; comparing the value in the stack to 3. If value ==4, loop ends
		je L3

		mov	  ecx,RowSize				; moving row size to ecx, acts as a loop counter for L1
		mov eax, DWORD PTR [ebp - 4]	; moving row number into eax	
		mul	 ecx						; row index * row size
		add	 ebx,eax					; row offset, the actual index, which will be a multiple of 5 since the row size is 5
		mov	 eax,0						; accumulator
		mov	 esi,0						; column index

			L1:										; inner loop
				movzx edx, BYTE PTR[ebx + esi]		; get a byte, ebx represents the row, esi represents the column. Edx represents the actual value 
				add	 eax,edx						; add to accumulator
				inc	 esi							; next word in row
			loop L1

		mov DWORD PTR [ebp - 8], eax	; move the sum to the stack					
		mov eax, DWORD PTR [ebp - 12]	; getting the current index
		mov edx, OFFSET msg4			; moving the 4th message
		call WriteString				; write 4th message to the terminal
		call WriteDec					; print sales person 
		mov edx, OFFSET msg5			; preparing to print ":"
		call WriteString				; print msg5
		mov eax, DWORD PTR [ebp - 8]	; move sum from stack to eax
		call WriteDec					; print the sum for the row
		mov DWORD PTR [ebp - 8 ], 0		; resetting the sum on the stack
		inc DWORD PTR [ebp - 4]			; increment the index
		inc DWORD PTR [ebp - 12]		; increment to the next sales person
		call crlf						; new line

	loop outerLoop
	
	L3: 

	mov esp,ebp ; remove locals from stack
	pop ebp
	ret
calc_row_sum ENDP

END main