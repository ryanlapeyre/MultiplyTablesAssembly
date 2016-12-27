**************************************
*
* Name:Ryan Lapeyre
* ID:16156898 / rml3md
* Date:11/2/16
* Lab4
*
* Program description:
* You are to design, write, assemble, and simulate an assembly language program which will
* multiply two TABLES of 8-bit 2'S-COMPLEMENT numbers. The actual multiplication has to
* be implemented in a subroutine that uses the algorithm devised in Lab3. The result will be an
* array of 2-byte numbers (you don’t have to add a sentinel to the result array). The sentinel for the
* input tables is $FF. 
*
* Pseudocode of Main Program:
*
*	
*  POINTER = &RESULT[0] // initialize the POINTER variable to the first index of the RESULT table.
*
* while(TABLE1->item != $FF)
* {
*	result->item = multiplyArrayIndex/subroutine(table1->item, table2->item)
*	(bumping the addresses here)
*	TABLE1 = TABLE1+1
*	TABLE2 = TABLE2+1
*	POINTER = POINTER+1
*	POINTER = POINTER+1
* }
*	
*
* Pseudocode of Subroutine:
*
* subroutine(NUM1, NUM2)
* {
*     FLAG = 1
*     if (NUM1 < 0) then
*     {         
*		FLIP	FLAG
*		complement NUM1
*     }
*
*     if (NUM2 < 0) then
*     {
*         flip FLAG
*         complement NUM2
*     }
*
*     while (COUNT != 0){
*        SUM = SUM + NUM1;
*        COUNT--;
*     }
*
*     if (SUM != 0) then complement SUM
*		     {
*				if(FLAG == -1)
*				{
*					flip SUM
*				}	
*			}
*
*	return SUM;
* }
*
**************************************

* start of data section

	ORG $B000
TABLE1	FCB	-50, 0, 64, -64,  64, -64, $FF
TABLE2	FCB	  0, -50, 124,  124, -124, -124, $FF

	ORG $B010
RESULT	RMB	12
POINTER	RMB	2


* define any variables that your main program might need here
* REMEMBER: Your subroutine must not access any of the main
* program variables including TABLE1, TABLE2, and RESULT.


	ORG $C000
* start of your main program
	LDS	#$E000	*Initializes the stack. 
	LDX	#RESULT	*Loads the RESULT Table into the X REGISTER, which we are using as a pointer.
	STX	POINTER	*Stores the first index of TABLE1 into the POINTER variable.
	LDY	#TABLE2	*Loads the first index of TABLE2 into the Y REGISTER.
	LDX	#TABLE1	*Loads the X REGISTER with the first index of TABLE1.
WHILE	LDAA	0,X		*Load contents in TABLE1 into A for the WHILE loop.
	CMPA	#$FF		*Compares the value in REGISTER A with the sentinel value of $FF.		
	BEQ	ENDWHILE	*Ends the loop if the value in REGISTER A does equals the sentinel value of $FF.
	LDAA	0,X		*Loads the current index address of X/TABLE1 into REGISTER A.
	LDAB	0,Y		*Loads the current index address of Y/TABLE2 into REGISTER B.
	PSHX			*Pushes the current index address of X on the stack pointer.
	PSHY			*Pushes the current index address of Y on the stack pointer.
	JSR	SUB		*Jump to the subroutine with the current REGISTER values. X and Y still hold addresses, A and B hold values.
	PULB			*Pulls the finished answer in the B REGISTER. Pull B first because it is BIG-ENDIAN format.
	PULA			*Pulls the finished answer in the A REGISTER. A last, because of BIG-ENDIAN format.
	INS			*Increments the stack closing the hole opened up.
	INS			*Second byte of hole opened in the stack. 
	LDX	POINTER	*Loads into X the current address of RESULT table.
	STD	0,X		*Stores the finished 2's complement answer into the current index of the RESULT table.
	INX			*Increments the RESULT table index. Increments twice because each value in the RESULT table is two bytes.
	INX			*Second part of instruction above.
	STX	POINTER	*Stores the RESULT table index address to the X REGISTER.
	PULY			*Pulls the TABLE2 index..
	INY			*Increments the TABLE2 index.
	PULX			*Pulls the X REGISTER, holding TABLE1 index address..
	INX			*Increments the X REGISTER address index.
	BRA	WHILE		*Branch back up to WHILE if finished condition not met.
ENDWHILE	BRA	ENDWHILE	*Ends the program.



* define any variables that your subroutine might need here
NUM1	RMB	1
NUM2	RMB	1
SUM	RMB	2
FLAG	RMB 	1
COUNT	RMB	1


	ORG $D000
* start of your subroutine
SUB
	STAA	NUM1	*Stores the current value in REGISTER A to NUM1.

	STAB	NUM2	*Stores the current value in REGISTER B to NUM2.
	CLR	SUM	*Clears the first byte of SUM.
	CLR	SUM+1	*Clears the second byte of SUM.
	CLR	COUNT	*Clears the COUNT variable to 0.
	LDAA	#1	*Loads a value of 1 into the A REGISTER.
	STAA	FLAG	*Setting FLAG to 1.
	CLRA		*clearing register A after usage
IF	CMPA	NUM1	*checks if num1 is negative
	BLE	ENDIF
THEN	NEG	NUM1	*taking the absolute value of num1
	NEG	FLAG	*flipping the NFLAG for a later comparison
ENDIF	NOP
IF2	CMPA	NUM2	*taking the absolute value of num2
	BLE	ENDIF2
THEN2	NEG	NUM2	*taking the absolute value of num2
	NEG	FLAG	*flipping the FLAG for a later comparison.
ENDIF2	NOP
	LDAA	NUM2	
	STAA	COUNT	*set count = num2
	LDD	#0	*clear registers
SUBWHILE	TST	COUNT	
	BEQ	ENDWHL	*while count != 0
	ADDB	NUM1	*add NUM1 to register B
	ADCA	#0	*add carry bit to A
	DEC	COUNT
	BRA	SUBWHILE
ENDWHL	STD	SUM	*while loop will terminate and store register D into result
IF3	LDD	#0
	CMPD	SUM	*checks if result is 0
	BEQ	ENDIF3	*if result =0 don't flip bits
IF4	LDAA	#-1	
	CMPA	FLAG	*check if FLAG = -1
	BNE	ENDIF4
THEN4	NEG	SUM	*flip result if FLAG is equal to -1
	DEC	SUM
	NEG	SUM+1
ENDIF4	NOP	
ENDIF3	NOP
	LDD	SUM     	*SUM = TABLE1->item * TABLE2->item
	PSHA			*Pushes the value of A onto the stack.	
	PSHB     		*Pushes the value of B onto the stack.
	DES			*Opens the hole for the return address.
	DES			*Second byte of instruction above.
	TSX			*Transfers the current value to the stack pointer.
	LDY	4,X		*Grabs the return address underneath the REGISTERS.
	STY	0,X		*Puts the address back on the Y REGISTER.
	RTS			*Return back to main.