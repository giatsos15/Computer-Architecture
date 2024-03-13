
# DO NOT DELCARE main IN THE .globl DIRECTIVE. BREAKS MUNIT!
          .globl strcmp, rec_b_search

          .data

aadvark:  .asciiz "aadvark"
ant:      .asciiz "ant"
elephant: .asciiz "elephant"
gorilla:  .asciiz "gorilla"
hippo:    .asciiz "hippo"
empty:    .asciiz ""

          # make sure the array elements are correctly aligned
          .align 2
sarray:   .word aadvark, ant, elephant, gorilla, hippo
endArray: .word 0  # dummy

.text

main:
   	la   $a0, empty
    	addi $a1, $a0,   0 # 16
    	jal  strcmp

   	la   $a0, sarray
  	la   $a1, endArray
	addi $a1, $a1,     -4  # point to the last element of sarray
   	la   $a2, hippo
   	jal  rec_b_search

  	addiu      $v0, $zero, 10    # system service 10 is exit
    	syscall                      # we are outa here.
 

# a0 - address of string 1
# a1 - address of string 2
strcmp:
######################################################

		# save $ra in the stack
    	addi $sp, $sp, -4
    	sw $ra, 0($sp)

 	add $t0,$zero,$zero
       	add $t1,$zero,$a0
       	add $t2,$zero,$a1

nextbyte:
        lb $t3,0($t1)  	#load a byte from each string
        lb $t4,0($t2)
        beq $t3,$zero,checkt2 	#str1 end
        beq $t4,$zero,missmatch_smaller

      	#compare two bytes
        slt $t5,$t3,$t4  #compare two bytes
        bne $t5,$zero,missmatch_smaller
        beq $t5,$zero,missmatch_larger

        addi $t1,$t1,1  	#t1 points to the next byte of str1
        addi $t2,$t2,1
        j nextbyte

# compare $t3, $t4 to find which is smaller or larger and return 1 or -1 respectively

missmatch_smaller:
		# $a0 < $a1
	addi $v0,$zero,-1  # or maybe li $v0,-1
        j endfunction

missmatch_larger:
		# $a0 > $a1
        addi $v0,$zero,1  # or maybe li $v0,1
        j endfunction

checkt2:
        bne $t4,$zero,missmatch_larger
        add $v0,$zero,$zero 	# both strings match

endfunction:    

        
        lw $ra, 0($sp)
    	addi $sp, $sp, 4
    	jr $ra
######################################################


# a0 - base address of array
# a1 - address of last element of array
# a2 - pointer to string to try to match

#########################
before_calling_binary_search:
	li $v0, 0xfffffffc
#########################

rec_b_search:
######################################################
    	# middle = (start + end ) / 2
    	add $t0, $a0, $a1                   # $t0 = start + end
    	sra  $s1, $t0, 1                    # $s1 = $t0 / 2 (middle)

    	# save $ra in the stack
    	addi $sp, $sp, -4
    	sw $ra, 0($sp)

    	# base case
    	slt $t6, $a1, $a0
    	bne $t6, $zero, returnNegative1     # if (end < start) 

    	sll $s4, $s1, 2
    	add $t1, $a0, $s4                   # $t1 = arr[middle]
    	lw  $t2, 0($a2)                     # $t2 = val ($a2) 
    	beq $t1, $t2, returnMiddle          # if (arr[middle] == val)
	slt $t5, $t2, $t1
    	bne $t5, $zero, returnFirstPart     # if (val < arr[middle])
    	beq $t5, $zero, returnLastPart      # if (val > arr[middle])  


returnNegative1:
       	li $v0, -1
       	j Exit       
returnMiddle:
      	add $v0, $s1, $zero                # return middle
       	j Exit   

returnFirstPart:
      	add $t3, $s1, $zero               # temp = middle     
    	addi $t3, $t3, -1            # temp --
  	add $a1, $t3, $zero                # end = temp
	jal rec_b_search
       	j Exit

returnLastPart:                             
       	add $t3, $s1, $zero                    # temp = middle
       	addi $t3, $t3, 1                 # temp++
       	add $a0, $t3, $zero                    # start = temp
       	jal rec_b_search
       	j Exit   

Exit:   
   	lw $ra, 0($sp)
	addi $sp, $sp, 4
 	jr $ra
######################################################

