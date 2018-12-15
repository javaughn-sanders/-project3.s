.data 
  emptyErrorMessage: .asciiz "Input is empty."
  lengthErrorMessage: .asciiz "Input is too long."
  baseErrorMessage: .asciiz "Invalid base-36 number."
  userInput: .space 1000

.text 
 main:
   li $v0, 8
   la $a0, userInput
   li $a1, 100
   syscall 

 deleteSpace:
   li $t8, 32  # ascii space 
   lb $t9, 0($a0)
   beq $t8, $t9, deletechar
   move $t9, $a0
   j checkLength

 deletechar:
   addi $a0, $a0, 1
   j deleteSpace

checkLength:
addi $t0, $t0, 0
addi $t1, $t1, 10
add $t4, $t4, $a0

lengthLoop:
lb $t2, 0($a0)
beqz $t2, done  
beq $t2, $t1, done
addi $a0, $a0, 1
addi $t0, $t0, 1
j lengthLoop

done:
beqz $t0, emptyError
slti $t3, $t0, 5
beqz $t3, lengthError
move $a0, $t4
j checkString

emptyError:
li $v0, 4
la $a0, emptyErrorMessage
syscall
j exit

lengthError:
li $v0, 4
la $a0, lengthErrorMessage
syscall
j exit

checkString:
   lb $t5, 0($a0)
   beqz $t5, conversions
   beq  $t5, $t1, conversions
   slti $t6, $t5, 48	# if char < ascii(48), input invalid, ascii(48) = 0
   bne $t6, $zero, baseError
   slti $t6, $t5, 58	# if char < ascii(58), input is valid, ascii(58) = 9
   bne $t6, $zero, Increment
   slti $t6, $t5, 65	# if char < ascii(65), input invalid, ascii(65) = A
   bne $t6, $zero, baseError
   slti $t6, $t5, 90	# if char > ascii(90), input is valid, ascii(90) = Z
   bne $t6, $zero, Increment
   slti $t6, $t5, 97	# if char < ascii(97), input invalid, ascii(97) = a
   bne $t6, $zero, baseError
   slti $t6, $t5, 122	# if char < ascii(122), input is valid, ascii(122) = z
   bne $t6, $zero, Increment
   bgt $t5, 121, baseError 

Increment:
addi $a0, $a0, 1
j checkString

baseError:
li $v0, 4
la $a0, baseErrorMessage
syscall
j exit

conversions:
move $a0, $t4
addi $t7, $t7, 0 
add $s0, $s0, $t0
addi $s0, $s0, -1
li $s3, 3
li $s2, 2
li $s1, 1
li $s5, 0

convertString:
lb $s4, 0($a0)
beqz $s4, displaySum
beq $s4, $t1, displaySum
slti $t6, $s4, 58
bne $t6, $zero, Numbers
slti $t6, $s4, 90
bne $t6, $zero, Upletters
slti $t6, $s4, 122
bne $t6, $zero, Lowletters

Numbers:
addi $s4, $s4, -48
j nextStep

Upletters:
addi $s4, $s4, -55
j nextStep

Lowletters:
addi $s4, $s4, -87

threeP:
li $s6, 46656
mult $s4, $s6
mflo $s7
add $t7, $t7, $s7
addi $s0, $s0, -1
addi $a0, $a0, 1
j convertString

twoP:
li $s6, 1296
mult $s4, $s6
mflo $s7
add $t7, $t7, $s7
addi $s0, $s0, -1
addi $a0, $a0, 1
j convertString

oneP:
li $s6, 36
mult $s4, $s6
mflo $s7
add $t7, $t7, $s7
addi $s0, $s0, -1
addi $a0, $a0, 1
j convertString

zeroP:
li $s6, 1
mult $s4, $s6
mflo $s7
add $t7, $t7, $s7

nextStep:
beq $s0, $s3, threeP
beq $s0, $s2, twoP
beq $s0, $s1, oneP
beq $s0, $s5, zeroP

displaySum:
li $v0, 1
move $a0, $t7
syscall

exit:
li $v0, 10
syscall