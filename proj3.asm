# CSE 220 Programming Project #3
# Regina Wong
# REWONG
# 112329774

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text
initialize:
	li $v0, -1
	li $v1, -1
	blez $a1, initializeDone
	blez $a2, initializeDone
	move $v0, $a1
	move $v1, $a2
	sb $a1, ($a0) # puts in the row number in return value
	addi $a0, $a0, 1
	sb $a2, ($a0) # puts in the col number in the return value
	addi $a0, $a0, 1
	mul $t0, $a1, $a2 # counter
	initalizeLoop:
		beqz $t0, initalizeLoopDone
		sb $a3, ($a0)
		addi $t0, $t0, -1
		addi $a0, $a0, 1
		j initalizeLoop
	initalizeLoopDone:
	initializeDone:
	jr $ra

load_game:
	addi $sp, $sp, -12
	sw $s0, ($sp) 
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	
	move $s0, $a0 # state
	move $s1, $a1 # filename
	# open the file
		li $v0, 13
		move $a0, $a1 # address of null-terminated filename string
		li $a1, 0 # flags
		move $a2, $0 # mode
		syscall
	# Reading a File
		move $s2, $v0 # moves file descriptor into $s2
		li $v0, -1
		li $v1, -1
		bltz $s2, loadGameEnd
		# Read num of row
		# First Digit (Saved to $t0)
			li $v0, 14
			move $a0, $s2 # file descriptor
			move $a1, $s0
			li $a2, 1
			syscall 
			lbu $t0, ($s0)
			li $t2, 10
			addi $t0, $t0, -48
			mul $t2, $t2, $t0 # saves the ten digit(Might be needed depending if there is a second digit)
		# Second Digit (Saved to $t1)
			li $v0, 14
			move $a0, $s2 # file descriptor
			move $a1, $s0
			li $a2, 1
			syscall 
			lbu $t1, ($s0)
			li $t6, '\n'
			beq $t1, $t6, colNum
			addi $t1, $t1, -48
			add $t0, $t2, $t1 # adds the tens digit($t2) and the second digit($t1) 
				li $v0, 14 # reads and ignore the new line
				move $a0, $s2 # file descriptor
				move $a1, $s0
				li $a2, 1
				syscall 
		# Read num for col 
		colNum:
		#First Digit
			li $v0, 14
			move $a0, $s2 # file descriptor
			move $a1, $s0
			li $a2, 1
			syscall
			lbu $t1,($s0)
			addi $t1, $t1, -48
			li $t2, 10
			mul $t2, $t2, $t1
		# Second Digit
			li $v0, 14
			move $a0, $s2 # file descriptor
			move $a1, $s0
			syscall
			lbu $t3, ($s0)
			li $t6, '\n'
			beq $t3, $t6, rowAndColFound # if it is empty the col value would just be $t1
			addi $t3, $t3, -48
			add $t1, $t2, $t3 # adds the value of the 10 digit and the ones 
				li $v0, 14 # reads and ignore the new line
				move $a0, $s2 # file descriptor
				move $a1, $s0
				li $a2, 1
				syscall 
		rowAndColFound: # $t0 is the row, $t1 is the col
	sb $t0, ($s0) # stores the row in the state
	sb $t1, 1($s0) # stroes the col in the state
	addi $s0, $s0, 2 
	mul $t2, $t0, $t1 # Counter - The amount of values that should be read
	li $t5, 0 # Counter for O's
	li $t6, 0 # Counter for invalid character
	readStruct:
		li $v0, 14
 		move $a0, $s2 # file descriptor
		move $a1, $s0
		li $a2, 1 # only read one at a time
		syscall
		lbu $t3,($s0)
		beqz $t3, closeTheFile
			li $t4, '\n' # Checks if it is a new line, if it is it would not be added to the state and counter would remain the same
			addi $s0, $s0, -1
			addi $t2, $t2, 1
			beq $t4, $t3, nextLetter
			addi $t2, $t2, -1
			addi $s0, $s0, 1
			# Check if special value
			li $t4, 'O'
			bne $t4, $t3, notO
			addi $t5, $t5, 1 # increment the counter for O
			j nextLetter
			notO:
			li $t4, '.'
			bne $t4, $t3, notValid
			j nextLetter
			notValid:
			sb $t4, ($s0) # replaces the invalid char with '.'
			addi $t6, $t6, 1 # incrementthe counter for invalid character
			nextLetter:
		addi $t2, $t2, -1
		addi $s0, $s0, 1
		j readStruct
	# closes the file
	closeTheFile:
	li $v0, 16
	move $a0, $s2 # file descriptor
	syscall	
	move $v0, $t5 # move the counter for 'O' into $v0
	move $v1, $t6 # move the counter for invalid char into $v1

	loadGameEnd:
	lw $s0, ($sp) 
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	addi $sp, $sp, 12
    jr $ra

get_slot:
	li $v0, -1
	bltz $a1, finishGettingSlot
	bltz $a2, finishGettingSlot
	lb $t0, ($a0) # row of the struct
	lb $t1, 1($a0) # col of the struct
	bge $a1, $t0, finishGettingSlot
	bge $a2, $t1, finishGettingSlot
	addi $a0, $a0, 2
	mul $t3, $a1, $t1 # row * # of col = x
	add $t3, $t3, $a2 # x = x + col
	add $a0, $a0, $t3 # adds x to the address
	lb $v0, ($a0)
	finishGettingSlot:
    jr $ra

set_slot:
	li $v0, -1
	bltz $a1, notValidSlot
	bltz $a2, notValidSlot
	lb $t0, ($a0) # row of the struct
	lb $t1, 1($a0) # col of the struct
	bge $a1, $t0, notValidSlot
	bge $a2, $t1, notValidSlot
	addi $a0, $a0, 2
	mul $t3, $a1, $t1 # row * # of col = x
	add $t3, $t3, $a2 # x = x + col
	add $a0, $a0, $t3 # adds x to the address
	sb $a3, ($a0)
	move $v0, $a3
	notValidSlot:
    jr $ra

rotate: # must call initialize($t0), get_slot and set_slot($t0 - $t3)
	li $v0, -1
	bltz $a1, rotateDone
		addi $sp, $sp, -16
		sw $s0, ($sp) 
		sw $s1, 4($sp)
		sw $s2, 8($sp)
		sw $s3, 12($sp)
	move $s0, $a0 # Piece
	move $s1, $a1	 # Rotation
	move $s2, $a2 #Rotated_Piece
	move $s3, $ra # return value
	#call Get and Set
		li $a1, -1
		jal get_slot
		move $a1, $s1	 # Rotation
		move $ra, $s3
		li $a1, -1
		jal set_slot
		move $a1, $s1	 # Rotation
		move $ra, $s3
	# Find the row and col of the struct
		lb $t0, ($s0) # Stores the row number (r)
		lb $t1, 1($s0) # Stores the col number (c)
	#Breaks into the cases
		#Square
		beq $t0, $t1, square
		#Line
		li $t2, 4
		beq $t0, $t2, lineCases
		beq $t1, $t2, lineCases
		#Remaining - Assume 4 cases when turned
		# finds smallest num of rotation
		li $t9, 4
		div $s1, $t9
		mfhi $t9 # stores the rotation number
		beqz $t9, rotate0
		addi $t9, $t9, -1
		beqz $t9, rotate1
		addi $t9, $t9, -1
		beqz $t9, rotate2
		j rotate3
			rotate0:
				sb $t0, ($s2)
				sb $t1, 1($s2)
				lb $t9, 2($s0)
				sb $t9, 2($s2)
				lb $t9, 3($s0)
				sb $t9, 3($s2)
				lb $t9, 4($s0)
				sb $t9, 4($s2)
				lb $t9, 5($s0)
				sb $t9, 5($s2)
				lb $t9, 6($s0)
				sb $t9, 6($s2)
				lb $t9, 7($s0)
				sb $t9, 7($s2)
				j rotateRestoreValues
			rotate1:
			li $t9, 2
			beq $t9, $t0, rotate12
				sb $t1, ($s2)
				sb $t0, 1($s2)
				lb $t9, 2($s0)
				sb $t9, 4($s2)
				lb $t9, 3($s0)
				sb $t9, 7($s2)
				lb $t9, 4($s0)
				sb $t9, 3($s2)
				lb $t9, 5($s0)
				sb $t9, 6($s2)
				lb $t9, 6($s0)
				sb $t9, 2($s2)
				lb $t9, 7($s0)
				sb $t9, 5($s2)
				j rotateRestoreValues
			rotate12:
				sb $t1, ($s2)
				sb $t0, 1($s2)
				lb $t9, 2($s0)
				sb $t9, 3($s2)
				lb $t9, 3($s0)
				sb $t9, 5($s2)
				lb $t9, 4($s0)
				sb $t9, 7($s2)
				lb $t9, 5($s0)
				sb $t9, 2($s2)
				lb $t9, 6($s0)
				sb $t9, 4($s2)
				lb $t9, 7($s0)
				sb $t9, 6($s2)
				j rotateRestoreValues
			rotate2:
				sb $t0, ($s2)
				sb $t1, 1($s2)
				lb $t9, 2($s0)
				sb $t9, 7($s2)
				lb $t9, 3($s0)
				sb $t9, 6($s2)
				lb $t9, 4($s0)
				sb $t9, 5($s2)
				lb $t9, 5($s0)
				sb $t9, 4($s2)
				lb $t9, 6($s0)
				sb $t9, 3($s2)
				lb $t9, 7($s0)
				sb $t9, 2($s2)
				j rotateRestoreValues
			rotate3:
				li $t9, 2
			beq $t9, $t0, rotate32
				sb $t1, ($s2)
				sb $t0, 1($s2)
				lb $t9, 2($s0)
				sb $t9, 5($s2)
				lb $t9, 3($s0)
				sb $t9, 2($s2)
				lb $t9, 4($s0)
				sb $t9, 6($s2)
				lb $t9, 5($s0)
				sb $t9, 3($s2)
				lb $t9, 6($s0)
				sb $t9, 7($s2)
				lb $t9, 7($s0)
				sb $t9, 4($s2)
				j rotateRestoreValues
			rotate32:
				sb $t1, ($s2)
				sb $t0, 1($s2)
				lb $t9, 2($s0)
				sb $t9, 6($s2)
				lb $t9, 3($s0)
				sb $t9, 4($s2)
				lb $t9, 4($s0)
				sb $t9, 2($s2)
				lb $t9, 5($s0)
				sb $t9, 7($s2)
				lb $t9, 6($s0)
				sb $t9, 5($s2)
				lb $t9, 7($s0)
				sb $t9, 3($s2)
				j rotateRestoreValues
	lineCases:
		li $t9, 2 
		div $s1, $t9
		mfhi $t9 # stores the rotation number
		beqz $t9, square
		move $t9, $t0
		move $t0, $t1
		move $t1, $t9
	square:
			move $a0, $a2
			move $a1, $t0
			move $a2, $t1
			li $a3, 'O'
		jal initialize
			move $a0, $s0 # Piece
			move $a1, $s1	 # Rotation
			move $a2, $s2 #Rotated_Piece
			move $ra, $s3
		li $t0, '.'
		sb $t0, 6($s2)
		sb $t0, 7($s2)	
	rotateRestoreValues:
		move $v0, $s1
		lw $s0, ($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		addi $sp, $sp, 16
	rotateDone:
    jr $ra

count_overlaps: # must use get_slot
	li $t9, -1 # counter
	bltz $a1, count_overlapsDone # If it is less than zero, go to the end bc it is unvalid
	bltz $a2, count_overlapsDone
	lb $t0, ($a0) # Stores the row number (r) (state)
	lb $t1, 1($a0) # Stores the col number (c) (state)
	lb $t7, ($a3) # Stores the row number (r) (piece)
	lb $t8, 1($a3) # Stores the col number (c) (piece)
	add $t3, $t7, $a1
	add $t4, $t8, $a2
	bgt $t3, $t0, count_overlapsDone # If the row/num + the size of the piece > row/col of the state, it would go to the end b/c unvalid
	bgt $t4, $t1, count_overlapsDone
	
	addi $sp, $sp, -20
		sw $s0, ($sp) 
		sw $s1, 4($sp)
		sw $s2, 8($sp)
		sw $s3, 12($sp)
		sw $s4, 16($sp)
	move $s0, $a0 # State
	move $s1, $a1	 # Row
	move $s2, $a2 # Col
	move $s3, $a3 # Piece
	move $s4, $ra # return value 
	
	li $a1, -1
	jal get_slot
	move $a1, $s1	 # Rotation
	
	mul $t6, $t7, $t8 # count down for loop
	move $t4, $s1 # Row
	move $t5, $s2 # Col
	li $t2, 0
	addi $s3, $s3, 2
	li $t9, 0
	countOverLapLoop:
		beqz $t6, count_overlapRestoreValues
		lb $t7, ($s3)
		li $t0, 'O' # Check if it is an 'O' only would see if psn valid if 'O'
		bne $t7, $t0, notO_Overlap
			move $a0, $a0
			move $a1, $t4
			move $a2, $t5
				jal get_slot
			move $a0, $s0
			move $a1, $s1
			move $a2, $s2
			move $t0, $v0
			bne $t7, $t0, notO_Overlap
			addi $t9, $t9, 1
		notO_Overlap:
			addi $t2, $t2, 1
			div $t2, $t8
			mfhi $t0
			addi $t5, $t5, 1
			bnez $t0, notNextRow
				addi $t4, $t4, 1
				move $t5, $s2
		notNextRow:
		addi $s3, $s3, 1
		addi $t6, $t6, -1
		j countOverLapLoop
	count_overlapRestoreValues:
	move $ra, $s4
		lw $s0, ($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		addi $sp, $sp, 20
	count_overlapsDone:
	move $v0, $t9
	jr $ra

drop_piece: # must call get_slot, set_slot, rotate and count_overlaps
	li $v0, -2
	bltz $a1, dropDone
	lb $t0, 1($a0)
	bge $a1, $t0, dropDone
	
	lw $t0, ($sp)
	addi $sp, $sp, -32
	sw $s0, ($sp) 
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp) # used for the counter
	
	move $s0, $a0 # State
	move $s1, $a1 # Col
	move $s2, $a2 # Piece
	move $s3, $a3 # Rotation
	move $s4, $t0 # Rotated Piece
	move $s6, $s4 # Rotated Piece 
	move $s5, $ra # return address
	# Rotate the Piece
		move $a0, $a2
		move $a1, $a3
		move $a2, $t0
			jal rotate
		move $a0, $s0 # State
		move $a1, $s1 # Col
		move $a2, $s2 # Piece
		move $ra, $s5 # return address
	#Check if to see if valid -> overlap($v0 = -3)
		li $s7, -3
		lb $t0, 1($s4)
		add $t0, $t0, $a1
		lb $t1, 1($a0)
		bgt $t0, $t1, dropLoopRestoreValues
	li $t4, 0 #Count Over lap -> Once it is greater than 0 it would stop the loop
	li $s7, 0 # counter - > return value 
	dropLoop:
		bnez $t4, dropLoopDone
			move $a0, $a0 # state
			move $a2, $a1 # col
			move $a1, $s7 #row
			move $a3, $s4 # piece
			jal count_overlaps
			move $t4, $v0
			move $a0, $a0
			move $a1, $s1
			move $a2, $s2
			move $a3, $s3
			move $s4, $s6
			addi $s7, $s7, 1
		j dropLoop
	dropLoopDone:
		li $v0, -1
		addi $s7, $s7, -2
		bltz $s7, dropLoopRestoreValues
	settingValues: #Set and Get ($t0, $t1, $t3)
		li $t2, 0 # counter to see if the row should change
		move $t4, $s7 # Row
		move $t5, $s1 # col
		addi $s4, $s4, 2 # rotated Piece
		lb $t6, ($s6)
		lb $t7, 1($s6)
		mul $t6, $t6, $t7 # counter
		lb $t8, 1($s6) # div to see to move to next col
		loopForSettingValues:
			beqz $t6, dropLoopRestoreValues
			lb $t7, ($s4)
			li $t0, 'O' # Check if it is an 'O' only would see if psn valid if 'O'
			bne $t7, $t0, notODrop
				move $a0, $a0# struct
				move $a1, $t4# row
				move $a2, $t5 # col
				li $a3, 'O' # character
				jal set_slot
				move $a0, $s0
				move $a1, $s1
				move $a2, $s2
			notODrop:
				addi $t2, $t2, 1
				div $t2, $t8
				mfhi $t0
				addi $t5, $t5,1
				bnez $t0, notNextRowDrop
					addi $t4, $t4, 1
					move $t5, $s1
			notNextRowDrop:
			addi $s4, $s4, 1
			addi $t6, $t6, -1 
		j loopForSettingValues
	dropLoopRestoreValues:
		move $v0, $s7
		move $ra, $s5
		lw $s0, ($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $s7, 28($sp)
		addi $sp, $sp, 32
	dropDone:
	jr $ra

check_row_clear: # must use get and set($t0, $t1, $t3)
	# Check for invalid values
	li $v0, -1
	bltz $a1, checkClearRowDone
	lb $t0, ($a0)
	bge $a1, $t0, checkClearRowDone
	
	addi $sp, $sp, -16
	sw $s0, ($sp) 
	sw $s1, 4($sp)
	sw $s2, 8($sp) 
	sw $s3, 12($sp)
	move $s0, $a0 # state
	move $s1, $a1 # row
	move $s3, $ra # return address
	
	li $t2, 'O' # Check if it an O
	move $t4, $a1 # row num
	lb $t5, 1($a0) # col counter
	addi $t5, $t5, -1
	CheckIfRowIsAllO:
		bltz $t5, RemoveRow
		move $a0, $a0 # struct
		move $a1, $t4 # row
		move $a2, $t5 # col
		jal get_slot
		move $a0, $s0
		move $a1, $s1
		bne $t2, $v0, RowNotAllO
		addi $t5, $t5, -1
		j CheckIfRowIsAllO
	RemoveRow: # get and set the values of the struct
		move $t4, $a1 # row to set the info
		addi $t6, $t4, -1 # row to get the info
	RROuter:
		blez $t4, RROuterDone
		lb $t5, 1($a0) # col counter
		addi $t5, $t5, -1
		RRInnerLoop:
			bltz $t5, RRInnerLoopEnd
			# Get
				move $a0, $a0 # struct
				move $a1, $t6 # row
				move $a2, $t5 # col
					jal get_slot
				move $a0, $s0
				move $a1, $s2
			# Set
				move $a0, $a0 # struct
				move $a1, $t4 # row 
				move $a2, $t5 # col
				move $a3, $v0
					jal set_slot
				move $a0, $s0,
				move $a1, $s1
			addi $t5, $t5, -1
			j RRInnerLoop
		RRInnerLoopEnd:
		addi $t4, $t4, -1
		addi $t6, $t6, -1
		j RROuter
	RROuterDone:
		lb $t5, 1($a0) # col counter
		addi $t5, $t5, -1
	addRow:
		bltz $t5, DoneRemoving
		move $a0, $a0 # struct
		move $a1, $t4 # row 
		move $a2, $t5 # col
		li $a3, '.'
			jal set_slot
		move $a0, $s0,
		move $a1, $s1
		addi $t5, $t5, -1
		j addRow
	DoneRemoving:
		li $v0, 1
		j CheckRowClearRestoreValues
	RowNotAllO:
		li $v0, 0
	CheckRowClearRestoreValues:
		move $ra, $s3
		lw $s0, ($sp) 
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		addi $sp, $sp, 16
	checkClearRowDone:
	jr $ra

simulate_game:	# load_game, drop_piece and check_row_clear
	# Allocate Space
	lw $t0, ($sp)
	lw $t1, 4($sp)
	
	addi $sp, $sp, -32
	sw $s0, ($sp) 
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp) 
	
	move $s0, $a0 # state
	move $s2, $a2 # moves
	move $s3, $a3 # Rotated Piece
	move $s4, $t0 # number of Pieces to drop
	move $s5, $t1 # Pieces Array (Size of each element: 8 bytes)
	li $s6, 0 # num_successful_drops - Return Value $v0 - the number of pieces that were successfully dropped into the game field
	li $s7, 0 # Score - Return Value $v1 - the final score of the game
	move $s1, $ra # Return Address
	
	# Checks invalid(Text File cannot be found)
	jal load_game
	bltz $v1, SimulateGameRestoreValue
	move $a0, $s0
	move $a2, $s2
	
	li $t0, 0 #  move_number
	li $t1, 4 
	li $t2, 0 # moves length counter
	move $t3, $a2
	strLen:
		lb $t4, 0($t3) #stores the first bit of the string
		beqz $t4, strLenDone # To see if you are at the end of the String
		addi $t2, $t2, 1 # increment the length counter
		addi $t3, $t3, 1 #moves the pointer to the next bit
		j strLen
	strLenDone:
	div $t2, $t1
	mflo $t1 # moves_length - the number of moves encoded in pieces string
	li $t2, 0 # game over 0 - false, 1 - true
	whileLoop: # game over ne 0, num_successful_drops($s6) < num_pieces_to_drop($s4), move_number($t0) < moves_length($t1)
		bnez $t2, SimulateGameRestoreValue
		bge $s6, $s4, SimulateGameRestoreValue	
		bge $t0, $t1, SimulateGameRestoreValue
		move $s2, $a2
		# extract the next piece, column and rotation from the string
		lb $t3, ($a2) # Piece
		lb $a3, 1($a2) # rotation
		addi $a3, $a3, -48
		lb $t5, 2($a2) # ten's digit
		lb $t6, 3($a2) # one's digit
		addi $t6, $t6, -48
		beqz $t5, SingleDigit
			addi $t5, $t5, -48
			li $t7, 10
			mul $t5, $t5, $t7
			add $t6, $t5, $t6
		SingleDigit:
			move $a1, $t6 # col
			move $t5, $s5 # copy of array
		FindingPiece: # Compare to $t3
			li $t4, 'T'
				bne $t4, $t3, notT
				move $a2, $t5
				j CallingDropPiece
			notT:
			li $t4, 'J'
				addi $t5, $t5, 8
				bne $t4, $t3, notJ			
				move $a2, $t5
				j CallingDropPiece
			notJ:
			li $t4, 'Z'
				addi $t5, $t5, 8
				bne $t4, $t3, notZ
				move $a2, $t5
				j CallingDropPiece
			notZ:
			li $t4, 'O'
				addi $t5, $t5, 8
				bne $t4, $t3, notOPiece
				move $a2, $t5
				j CallingDropPiece
			notOPiece:
			li $t4, 'S'
				addi $t5, $t5, 8
				bne $t4, $t3, notS
				move $a2, $t5
				j CallingDropPiece
			notS:
			li $t4, 'L'
				addi $t5, $t5, 8
				bne $t4, $t3, notL
				move $a2, $t5
				j CallingDropPiece
			notL:
				addi $t5, $t5, 8
				move $a2, $t5
		CallingDropPiece:
			addi $sp, $sp, -12
			sw $t0, ($sp)
			sw $t1, 4($sp)
			sw $t2, 8($sp)
			move $a0, $a0 # state
			move $t0, $s3 #rotated_piece
			addi $sp, $sp, -4
			sw $t0, 0($sp)
				jal drop_piece
			addi $sp, $sp, 4
			move $a0, $s0
			move $a1, $s1
			move $a2, $s2
			move $a3, $s3
			lw $t0, ($sp)
			lw $t1, 4($sp)
			lw $t2, 8($sp)
			addi $sp, $sp, 12
		CheckingIfPieceIsValid:
			bgez $v0, Valid
			li $t3, -1
			addi $t0, $t0, 1
			addi $a2, $a2, 4
			blt $v0, $t3, whileLoop
				li $t2, 1
			j whileLoop
		Valid:
		# check for line clears by starting at the top of the game field and working our way down
		li $t3, 0 # number of lines that can be cleared after the piece was dropped
		lb $t4, ($a0)
		addi $t4, $t4, -1
			addi $sp, $sp, -12
			sw $t0, ($sp)
			sw $t1, 4($sp)
			sw $t2, 8($sp)
		removingRowLoop:
			beqz $t4, doneCheckingRemovingRowLoop
				move $a0, $a0 # state
				move $a1, $t4# row
				addi $sp, $sp, -8
				sw $t3, ($sp)
				sw $t4, 4($sp)
					jal check_row_clear
				move $a0, $s0
				move $a1, $s1
				move $a2, $s2
				lw $t3, ($sp)
				lw $t4, 4($sp)
				addi $sp, $sp, 8
				blez $v0, moveUp
					addi $t3, $t3, 1
					j removingRowLoop
				moveUp:
					addi $t4, $t4, -1
					j removingRowLoop
		doneCheckingRemovingRowLoop:
		lw $t0, ($sp)
		lw $t1, 4($sp)
		lw $t2, 8($sp)
		addi $sp, $sp, 12
			beqz $t3, incCounter # 0 row
			addi $s7, $s7, 40
			addi $t3, $t3, -1
			beqz $t3, incCounter # 1 row
			addi $s7, $s7, 60
			addi $t3, $t3, -1
			beqz $t3, incCounter # 2 rows
			addi $s7, $s7, 200
			addi $t3, $t3, -1
			beqz $t3, incCounter# 3 rows
			addi $s7, $s7, 900
		incCounter:
		addi $t0, $t0, 1
		addi $s6, $s6, 1
		addi $a2, $a2, 4
		j whileLoop
	SimulateGameRestoreValue:
	move $v0, $s6
	move $v1, $s7
	move $ra, $s1
		lw $s0, ($sp) 
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)	
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $s7, 28($sp)
		addi $sp, $sp, 32
	SimulateGameDone:
	jr $ra

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
