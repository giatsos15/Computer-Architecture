        .data
padding:
        .space 0  # (number in bytes) modify to see mapping to different cache indices
array:
        .word   1
        .space  2048   # Large enough for all variations of the lab.
        
        .text
main:

# Supply values for array size, step size, and repetition count.
# arraysize must be a positive power of 2, less than or equal the number of bytes
#   allocated for "array".
# summary of register use:
#  $s0 = arraySize
#  $s1 = option: 0 - clear array, 1 increment array items by 1
#  $s2 = stepSize
#  $s3 = repCount - number of times to repeat
# -------
#  $s5 = index in bytes
#  $s6 = &array[index/4]
# -------------------------------------------------------------------
# Set code parameters here:
    li     $s0, 128     # arraySize
    li     $s1, 1      # option
    li     $s2, 16      # stepSize
    li     $s3, 4      # repCount
# Don't modify below the line
# -------------------------------------------------------------------

    sll    $s4, $s2, 2  # Convert step size from words to bytes (x4)
outerloop:
    # loop initialization: $s5 contains index, $s6 contains &array[index]
    add    $s5, $zero, $zero    # i = 0
    la     $s6, array           # ptr = &(array[0])

innerloop:
    bne    $s1, $zero, else   # if option == 0
    sw     $zero, 0($s6)      #   array[i] = 0
    j      skip
else:                         # else
    lw     $t0, 0($s6)
    addi   $t0, $t0, 1
    sw     $t0, 0($s6)        #   array[index] += 1
        
skip:
    add    $s5, $s5, $s2      # i += stepSize
    add    $s6, $s6, $s4      # ptr += 4*stepSize
    # inner loop done?
    slt    $t0, $s5, $s0
    bne    $t0, $zero, innerloop  # while i < arraySize
        
    addi   $s3, $s3,   -1     # j--
    bne    $s3, $zero, outerloop  # while j > 0
                
    # exit syscall
    li     $v0, 10
    syscall
