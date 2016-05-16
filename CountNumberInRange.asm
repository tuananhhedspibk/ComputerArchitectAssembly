.data
A:       	    	.space 400
Aend:    	    	.word
B:	 	   	.space 8
Message: 	    	.asciiz "Max Value Of Array Is : "
Prompt:  	    	.asciiz "Input An Integers (Cancel To Exit Input Or OK With Out Data Input To Exit) : "
Notice:  		.asciiz "Array Doesn't Have Any Elements"
NoticeForCalculate: 	.asciiz "Number Elements Of Array In Range Is : "
Space:			.asciiz " "

.text
	la   $s0, A			# $s0 = Address(A[0])
	la   $a2, A			# $a2 = Address(A[0])
	
input_array:	
	li   $v0, 51			# Display Input Dialog
	la   $a0, Prompt
	syscall
	
	beq  $a1, -1, input_array	# error in syntax -> input again
	beq  $a1, -2, main		# cancel input mode
	beq  $a1, -3, main  		# cancel input mode
	
	slti $a1, $a0, 10000		# element must less than 10000
	beq  $a1, $zero, input_array
	
	slti $a1, $a0, -9999		# element must greater than -10000
	bne  $a1, $zero, input_array
	
	sw   $a0, 0($a2)		# store inputed data to array
	
	li   $v0, 1			# Print element of array
	syscall
	
	li   $v0, 4			# Print space between elements of array
	la   $a0, Space
	syscall
	
	addi $a2, $a2, 4		# $a2 will store address of last element of array
	j    input_array  		# repeat

main :
	beq  $s0, $a2, not_have_element # if array doesn't have any element -> branch to not_have_element label
	addi $a0, $s0, 0		# load address(A[0]) to $a0
	j    find_max
	
not_have_element:
	li   $v0, 55			# Display Notice
	la   $a0, Notice
	syscall
	nop
	li   $v0, 10			# Exit
	syscall
	
find_max:
	addi $v0, $a0, 0		# $v0 store pointer of first element - init max pointer to first element
	lw   $v1, 0($v0)		# $v1 store value of first element - init max value to first element 's value
	beq  $a0, $a2, after_max
	addi $t0, $a0, 0		# init next pointer to first
	
loop:
	beq  $t0, $a2, after_max	# if next = last, jump to after max
	addi $t0, $t0, 4		# move to next element
	lw   $t1, 0($t0)		# load next element 's value to t1
	slt  $t2, $t1, $v1		# (t1 < v1) - (next < max) ?
	bne  $t2, $zero, loop		# if (next < max) -> repeat
	addi $v0, $t0, 0		# else -> next element is max element
	addi $v1, $t1, 0		# next value is max value
	j loop
	
after_max:
	addi $s1, $v1, 0		# store max value of array to $s1
	li   $v0, 56
	la   $a0, Message
	addi $a1, $s1, 0
	syscall
	
	la   $s1, B			# $s1 will store address(B[0])
	li   $s2, 0			# init $s2 = 0
input_range:
	li   $v0, 51			# Display Input Dialog
	la   $a0, Prompt
	syscall
	
	beq  $a1, -1, input_range	# handle when input error syntax
	beq  $a1, -2, input_range	# handle when input error syntax
	beq  $a1, -3, input_range	# handle when input error syntax
	
	slti $a1, $a0, 10000		# element must less than 10000
	beq  $a1, $zero, input_range
	
	slti $a1, $a0, -9999		# element must greater than -10000
	bne  $a1, $zero, input_range
	
	sw   $a0, 0($s1)		# store input data to array
	addi $s1, $s1, 4		
	addi $s2, $s2, 1		# $s2 is used to count number of input data
	beq  $s2, 2, calculate
	j    input_range  		# repeat
calculate:
	li   $s2, 0
	la   $s1, B			# $s1 will store address(B[0])
	lw   $t0, 0($s1)		# store m to $t0
	addi $s1, $s1, 4
	lw   $t1, 0($s1)		# store M to $t1
	la   $s1, B
	
	beq  $t0, $t1, input_range	# if m == M -> input again
	
	slt  $t2, $t0, $t1
	bne  $zero, $t2, process	
	move $t2, $t0			# swap if t0 > t1
	move $t0, $t1
	move $t1, $t2

process:	
	addi $a0, $s0, 0		# load address(A[0]) to $a0
	addi $v0, $a0, 0		# $v0 store pointer of first element
	li   $s1, 0			# s1 = counter for number elements in range (m,M)
	addi $v0, $v0, -4
	
loop_process: 
	addi $v0, $v0, 4		# move to next element
	slt  $t2, $v0, $a2		# approvaled all elements of array ??
	beq  $zero, $t2, end_calculate 
	lw   $v1, 0($v0)		# $v1 store value of first element
	slt  $t2, $t0, $v1		# m < v1 ??
	beq  $zero, $t2, loop_process	# repeat if m >= v1
	slt  $t2, $v1, $t1		# M > v1 ??
	beq  $zero, $t2, loop_process  	# repeat if v1 >= M
	addi $s1, $s1, 1		# if  m < v1 < M -> s1 ++
	beq  $v0, $a2, end_calculate    # if approvaled all elements of array -> exit
	j loop_process
	
end_calculate:
	li   $v0, 56
	la   $a0, NoticeForCalculate
	addi $a1, $s1, 0
	syscall
	
end_main:
