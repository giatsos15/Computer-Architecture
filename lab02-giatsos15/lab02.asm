
# lab02.asm - Binary search in an array of 32bit signed integers
#   coded in  MIPS assembly using MARS
# for MYΥ-505 - Computer Architecture, Fall 2020
# Department of Computer Science and Engineering, University of Ioannina
# Instructor: Aris Efthymiou

        .globl bsearch # declare the label as global for munit
        
###############################################################################
        .data
sarray: .word 1, 5, 9, 20, 321, 432, 555, 854, 940

###############################################################################
        .text 
# label main freq. breaks munit, so it is removed...
        la         $a0, sarray
        li         $a1, 9
		li         $a2, 1  # the number sought


bsearch:
###############################################################################

	add 	$t0, $zero, $zero	#Set first to 0
	addi 	$t7, $a1, -1		#Set last to length-1	
	add	$t1, $t7, $zero		#Arxikopoihsh
	add	$s7, $zero, $zero	#Arxikopoihsh
	
loop: 
	slt 	$t2, $t1, $t0		#Check if last<first
	bne 	$t2, $zero, error	#Go to error: if last<first = True
	add 	$t3, $t0, $t1		#t3=first+last
	sra 	$s1, $t3, 1		#s1 = a[m] = t3/2
	sll 	$s2, $s1, 2		#Calculate offset s2 = s1 * 4
	add	$t4, $a0, $s2		#Show a[m]
	lw 	$t5, 0($t4)		#Load integer of a[m]
	slt 	$t6, $t5, $a2		#Check if m=t5<a2=9
	beq 	$t6, $zero, elseif	#Go to elseif: if middle >= a2
	addi 	$t0, $s1, 1		#first = middle + 1 (L := m + 1)
	j 	loop
	
elseif:
	slt 	$t6, $a2, $t5		#Check if a2 < t5 
	beq	$t6, $zero, else	#And if (a2<t5) is not true then go to the only else left (else:)
	addi	$t1, $s1, -1		#If false then do last = m ? 1 (R := m - 1)
	j 	loop
	
else:
	add 	$s7, $t4, $zero		#We come here only if a[m] is equal to a2 and we return its value to register s7.
	
error:
	j 	exit



###############################################################################
   
	

###############################################################################
# End of your code.
###############################################################################
exit:
        addiu      $v0, $zero, 10    # system service 10 is exit
        syscall                      # we are outta here.


