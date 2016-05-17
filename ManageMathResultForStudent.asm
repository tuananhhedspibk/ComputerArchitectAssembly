.data					#declare data, asciiz = store string withou null
mes0: .asciiz "Number of Students : "  
mes1: .asciiz "Student "
mes2: .asciiz " Name: "
mes3: .asciiz " Mark: "
mes5: .asciiz "Mark of Student:"
mes4: .asciiz "Mark for pass exam : "
mes6: .asciiz "\n"
mes7: .asciiz "\n-------------------------------\n"

array: .space 1240
.text
MAIN:

inputNumberStudents:
	li   $v0, 51				# Display Input Dialog
	la   $a0, mes0
	syscall
	
	beq $a1, -1, inputNumberStudents	# if not integer, input again
	beq $a1, -2, endMain			# if cancel , out program
	beq $a1, -3, inputNumberStudents	# if Ok without number, input agin
 	slti $t1, $a0, 1  			#if v0 < 1, t1 = 1 else t1 = 0	
	bnez $t1, inputNumberStudents		#if t1 = 1 (< 1)  try input again
	move $t0, $a0				# store numberOfStudents at t0 register
		
	la $a0,mes0				#print "Number of Students:"
	li $v0,4
	syscall
		 
	move $a0, $t0				#print number 
	li $v0,1				#a0  = integer to print	(a0 == number)				
	syscall
		
	la $a0,mes6				#print "\n"		
	li $v0,4
	syscall

la $s0,array 					#s0 = array
li $s1,0					#s1 = 0
move $s2, $t0					#s2 = number of Students	
	
loopOne:					# while run from s1 to s2
	slt $t0,$s1,$s2				#if s1<s2 (i < n), t0 = 1 else t0 = 0				
	beq $t0,$0,endLoopOne			#if t0 == 0 (s1 >= s2 , i >= n), goto endLoopOne
	#print ("Student %d",i+1)
		la $a0,mes1
		li $v0,4
		syscall
		
		addi $a0,$s1,1			#print i + 1			
		li $v0,1			#a0  = integer to print	(a0 = t0 = s1+1)			
		syscall
		
		la $a0,mes6			# print "\n"	
		li $v0,4
		syscall

inputName:
		la $a0,mes2			#print "student :"
		li $v0,4
		syscall		
		
		move $a0, $s0
		li $a1,29			#a1 = maximum number of characters to read
		li $v0,8			#lb $0,29($s0)#them \0 vao cuoi ten
		syscall
						
inputMark:
		la $a0, mes5
		li $v0, 51			# Display Input Dialog
		syscall
		
		beq $a1, -1, inputMark		#if not integer try again
		slti $t1, $a0, 11		#if v0 < 11, t1 = 1 else t1 = 0
		slti $t2, $a0, 0   		#if v0 < 0, t2 = 1 else t2 = 0	
		beqz $t1, inputMark		#if t1 = 0 ( > 10)try input again
		bnez $t2, inputMark		#if t2 = 1 (< 0)  try input again
		move $t0, $a0			#store mark at t0 register (because i need $a0 to print another mes)
		
		la $a0,mes3			#print "Mark" 
		li $v0,4
		syscall
		 
		move $a0, $t0			#print mark
		li $v0,1			#a0  = integer to print	(a0 == mark)				
		syscall
		
		la $a0,mes6			#print "\n"		
		li $v0,4
		syscall
				
		sb $t0,30($s0)			
		#i++, pointer++
		addi $s1,$s1,1
		addi $s0,$s0,31
		j loopOne
endLoopOne:					#end while

inputMarkPass:
	
	li   $v0, 51			# Display Input Dialog
	la   $a0, mes4
	syscall
	
	beq $a1, -1, inputMarkPass
	slti $t9, $a0, 11		#neu v0 < 11, t9 = 1 else t9 = 0
	slti $t8, $a0, 0   		#neu v0 < 0, t8 = 1 else t8 = 0	
	beqz $t9, inputMarkPass		#neu t9 = 0 ( > 10)try input again
	bnez $t8, inputMarkPass		#neu t8 = 1 (< 0)  try input again
	move $s3, $a0			#store mark for pass at s3 register
	
	la $a0, mes4			#print "Mark For Pass Exam"
	li $v0, 4
	syscall
		 
	move $a0, $s3			#print mark for pass
	li $v0, 1			#a0  = integer to print	(a0 == markPass)				
	syscall
		
	la $a0, mes6			#print "\n"		
	li $v0, 4
	syscall
	
#i=0,s0=array
li $s1, 0
la $s0, array
		
loopTwo:
	slt $t0, $s1, $s2				#while s1 < s2
	beq $t0, $0, endLoopTwo			
	#if array[i].mark >= markPass
		lb $t0, 30($s0)
		slt $t0, $t0, $s3			# mark < markPass, t0 = 1 else t0 = 0
		beqz  $t0, nothing			# t0 = 0, ++i (s1), t0 = 1 print Name and Mark
		#print "Name "			
			la $a0,mes2
			li $v0,4
			syscall
			
			move $a0,$s0
			li $v0,4
			syscall
		#print "Mark "
			la $a0,mes3
			li $v0,4
			syscall
			
			lb $a0,30($s0)
			li $v0,1
			syscall
		#print "----------------------"
			la $a0,mes7
			li $v0,4
			syscall
nothing:
	#i++,pointer++
	addi $s1,$s1,1
	addi $s0,$s0,31
	j loopTwo

endLoopTwo:
endMain:
