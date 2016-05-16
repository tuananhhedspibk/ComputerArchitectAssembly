.data
# --- Postscript1 : DCE ---
postscript1: .word  150,2300,0, 180,3000,1, 0,3000,0,  130,707,1,  150,707,1,  180,1000,1,  210,707,1,  235,690,1,  0,3000,0,       90,3000,0,  240,707,1,  210,707,1, 180,1000,1, 150,707,1, 120,707,1, 0,3000,0,  90,2000,0,  270,1000,1, 180,1500,1, 90,1000,1,  270,1000,1, 180,1500,1, 90,1000,1, 270,6000,0						

# --- Postscript BKHN ---
postscript2: .word  150,2300,0, 180,2800,1, 90,1000,1, 40,600,1, 0,500,1, 320,600,1, 270,1000,1, 0,1400,0, 90,1000,1, 140,600,1, 180,500,1, 220,550,1, 90,1000,0, 0,1400,1, 180,1400,0, 180,1400,1, 0,1400,0, 45,1900,1, 225,1850,0, 135,1900,1, 90,1000,0 0,2800,1, 180,1400,0 ,90,1400,1, 0,1400,1, 180,1400,0, 180,1400,1, 90,1000,0, 0,2800,1, 150,3200,1, 0,2800,1, 270,8500,0, 180,2800,0

# --- Postscript ANHTT --- 																							
postscript3: .word  150,2800,0, 200,3000,1, 20,3000,0, 160,3000,1, 340,1500,0  270,1000,1   20,1500,0, 90,1500,0, 180,2800,1, 0,2800,0, 150,3200,1, 0,2800,1, 90,1000,0, 180,2800,1, 0,1400,0, 90,1000,1, 180,1400,1, 0,1400,0, 0,1400,1, 90,1000,0, 90,1500,1, 270,750,0, 180,2800,1, 0,2800,0, 90,1000,0, 90,1500,1, 270,750,0, 180,2800,1, 270,9500,0

# --- Mark end of PoscriptList ---
end1: .word
MessageError: .asciiz "Error Input"

#----------------------------------------------------------------------------
.eqv HEADING 		0xffff8010	# --- The direction of travel of the MarsBot ---
					# --- Integer: An angle between 0 and 359    ---
# --- 0    : North (up)    ---
# --- 90   : East  (right) ---
# --- 180  : South (down)  ---
# --- 270  : West  (left)  ---

.eqv MOVING 		0xffff8050 		# --- Boolean: whether or not to move --- 
.eqv LEAVETRACK 	0xffff8020 		# --- Boolean (0 or non-0): whether or not to leave a track --- 
.eqv WHEREX 		0xffff8030 		# --- Integer: Current x-location of MarsBot ---
.eqv WHEREY 		0xffff8040 		# --- Integer: Current y-location of MarsBot ---

.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012 	# --- Receive row and column of the key pressed, 0 if not key pressed ---
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014 	# --- Read byte at the address 0xFFFF0014, to detect which key button was pressed ---

.text 
#--------------------------------------------------------
# --- Main procedure ---
#--------------------------------------------------------
main:
	la   $t2, end1
	addi $t2, $t2 , -4
#---------------------------------------------------------
# Enable the interrupt of Keyboard matrix 4x4 of Digital Lab
#---------------------------------------------------------
	li   $t1, IN_ADDRESS_HEXA_KEYBOARD
	li   $t3, 0x80   			# --- Bit 7 = 1 to enable --- 
	sb   $t3, 0($t1)
  	
loopCatchKey:  
	sleep:  
		addi  $v0, $zero, 32 
		li    $a0, 300 			# --- Sleep 300 ms ---
		syscall
			
		nop  				# --- WARNING: nop is mandatory here --- 
		nop
		nop
		nop
		nop
		nop
		
		b  loopCatchKey 		# --- Loop ---
 		
#-----------------------------------------------------------------
# GENERAL INTERRUPT SERVED ROUTINE for all interrupts
#-----------------------------------------------------------------
.ktext 0x80000180 
#-----------------------------------------------------------------
# SAVE the current REG FILE to stack
#-----------------------------------------------------------------
IntSR:  
	addi  $sp, $sp, 4  	# --- Save $ra, because we may change it later ---
	sw    $ra, 0($sp)
	addi  $sp, $sp, 4   	# --- Save $at, because we may change it later ---
	sw    $at, 0($sp)
	addi  $sp, $sp, 4  	# --- Save $v0, because we may change it later ---
	sw    $v0, 0($sp)
	addi  $sp, $sp, 4 	# --- Save $a0, because we may change it later ---
	sw    $a0, 0($sp)
	addi  $sp, $sp, 4 	# --- Save $t1, because we may change it later ---
	sw    $t1, 0($sp)
	addi  $sp, $sp, 4   	# --- Save $t3, because we may change it later ---
	sw    $t3, 0($sp) 

#--------------------------------------------------------
# Processing
#-------------------------------------------------------- 

get_cod_row_1:
	li  $t1, IN_ADDRESS_HEXA_KEYBOARD
	li  $t3, 0x81				# --- Check row 1 and re-enable bit 7 ---
	sb  $t3, 0($t1)				# --- Must reassign expected row ---
	li  $t1, OUT_ADDRESS_HEXA_KEYBOARD
	lb  $a0, 0($t1)
	seq $s1, $a0, 0x00000011
	beq $s1, $zero, get_cod_row_2
	la  $t1, postscript1
	j goTracking
	
get_cod_row_2:
	li  $t1, IN_ADDRESS_HEXA_KEYBOARD
	li  $t3, 0x82				# --- Check row 2 and re-enable bit 7  ---
	sb  $t3, 0($t1)				# --- Must reassign expected row ---
	li  $t1, OUT_ADDRESS_HEXA_KEYBOARD
	lb  $a0, 0($t1)
	seq $s1, $a0, 0x00000012
	beq $s1, $zero, get_cod_row_3
	la  $t1, postscript2
	j goTracking
	
get_cod_row_3:
	li  $t1, IN_ADDRESS_HEXA_KEYBOARD
	li  $t3, 0x84 				# --- Check row 3 and re-enable bit 7  ---
	sb  $t3, 0($t1)				# --- Must reassign expected row ---
	li  $t1, OUT_ADDRESS_HEXA_KEYBOARD
	lb  $a0, 0($t1)	
	seq $s1, $a0, 0x00000014
	beq $s1, $zero, printError
	la  $t1, postscript3
	j goTracking
	
goTracking:
  	jal GO
	loopTrack:
		slt  $a2, $t2, $t1		# --- If t2 < t1 -> stop ---
		bne  $a2, $zero, stopTracking
		lw   $a1, 8($t1)
		jal  TRACK			# --- Set tracking ---
		lw   $a1, 0($t1)
		jal  ROTATE			# --- Set direction of travel for MarsBot ---
		lw   $a0, 4($t1)
		jal  SLEEP			# --- Make MarsBot move ---
		jal  UNTRACK			# --- Set untracking  ---
		addi $t1, $t1, 12		# --- Move to next element of array struct ---
		
		sne  $s1, $t1, 0x10010120	# --- Check finish tracking ---
		beq  $s1, $zero, stopTracking
		sne  $s1, $t1, 0x100102ac	# --- Check finish tracking ---
		beq  $s1, $zero, stopTracking
		
		j    loopTrack	
	stopTracking:
		jal STOP
		j next_pc
   	
#-----------------------------------------------------------
# GO procedure, to start running
# param[in] none
#-----------------------------------------------------------
	GO:
   		li   $at, MOVING 	# --- Change MOVING port to logic 1 ---
  		addi $k0, $zero, 1 	 
  	 	sb   $k0, 0($at) 	# --- To Start Running ---
  	 	jr   $ra 
#-----------------------------------------------------------
# STOP procedure, to stop running
# param[in] none
#-----------------------------------------------------------
	STOP: 
	  	li   $at, MOVING 	# --- Change MOVING port to logic 0 --- 
	   	sb   $zero, 0($at) 	# --- To stop ---
	   	jr   $ra
#-----------------------------------------------------------
# TRACK procedure, to start drawing line
# param[in] $a1
# $a1 = 0 -> Non - Tracking
# $a1 = 1 -> Tracking
#-----------------------------------------------------------
 	 TRACK: 
  		li $at, LEAVETRACK 	# --- Change LEAVETRACK port to 1 --- 
  		sw $a1, 0($at) 		# --- To start tracking ---
  		jr $ra
#-----------------------------------------------------------
# ROTATE procedure, to rotate the MarsBot
# param[in] $a1, An angle between 0 and 359
#	0   : North (up)
#	90  : East  (right)
#	180 : South (down)
#	270 : West  (left)
#-----------------------------------------------------------
  	ROTATE: 
  		li $at, HEADING 	# --- Change HEADING port ---
  		sw $a1, 0($at) 		# --- To rotate robot --- 
 		jr $ra
#------------------------------------------------------------
# SLEEP procedure, to make MarsBot track
# param[in] none 
#------------------------------------------------------------  
  	SLEEP:
  		addi $v0, $zero, 32
  		syscall 
  		jr $ra
#-----------------------------------------------------------
# UNTRACK procedure, to stop drawing line
# param[in] none
#-----------------------------------------------------------
  	UNTRACK:
 	 	li $at, LEAVETRACK 	# --- Change LEAVETRACK port to 0 ---
 	 	sb $zero, 0($at) 	# --- To stop drawing tail ---
 		jr $ra 

#------------------------------------------------------------
# printError procedure, print error message when input error value with Key matrix
# param[in] none
#------------------------------------------------------------
printError:
	li $v0, 55
	la $a0, MessageError
	li $a1, 0
	syscall

#------------------------------------------------------------
# --- Evaluate the return address of main routine ---
# --- epc <= epc + 4 ---
#------------------------------------------------------------

next_pc:
	mfc0  $at, $14 				# --- $at <= Coproc0.$14 = Coproc0.epc ---
	addi  $at, $at, 4 			# --- $at = $at + 4 (next instruction) ---
	mtc0  $at, $14 				# --- Coproc0.$14 = Coproc0.epc <= $at ---

#------------------------------------------------------------
# --- RESTORE the REG FILE from STACK ---
#------------------------------------------------------------

restore:
	lw    $t3, 0($sp) 			# --- Restore the registers from stack ---
	addi  $sp,$sp,-4
	lw    $t1, 0($sp)			# --- Restore the registers from stack ---
	addi  $sp,$sp,-4
	lw    $a0, 0($sp)			# --- Restore the registers from stack ---
	addi  $sp,$sp,-4
	lw    $v0, 0($sp)			# --- Restore the registers from stack ---
	addi  $sp,$sp,-4 
	lw    $ra, 0($sp)			# --- Restore the registers from stack ---
	addi  $sp,$sp,-4 

return: eret  					# ---  Return from exception ---
