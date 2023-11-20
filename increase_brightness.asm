.data
    input_path: .asciiz "C:\CSC2002S\Architecture\mips_a2\jet_64_in_ascii_lf.ppm"
    brighter: .asciiz "C:\CSC2002S\Architecture\mips_a2\jet_64_in_ascii_crlf_brighter.ppm" #Write to this file
    number: .space 12
    reverse_string: .space 12
    newline: .asciiz "\n"
    original: .space 61440
    prompt_before: .asciiz "Average pixel value of the original image:\n"
    prompt_after: .asciiz "\nAverage pixel value of new image:\n"
    result_before: .double 0.0
    result_after: .double 0.0
    divisor: .word 0x2fd000     #3*64*64=0x3000 is the total number of RGB values
                                #0x3000 * 255 will give us an average in the range [0,1]
    
.text

.globl main
main:  
    # Open file for reading

    li $v0, 13
    la $a0, input_path  # address of name of file we are opening
    li $a1, 0
    li $a2, 0           # Read-mode
    syscall

    move $s0, $v0       # Move file descriptor to $s0

    li $t1, 0           # Counter for length of string we are writing (Stores actual length of number)
    move $s3, $zero     # $s3 is counter to count length of number (used for processing)
    la $s4, original
    move $s5, $zero
    move $s6, $zero

Header:
    # Read entire file into memory
    li $v0, 14
    move $a0, $s0   # $a0 should contain descriptor of file we are reading from
    la $a1, ($s4)
    li $a2, 62000
    syscall

    li $v0, 16
    move $a0, $s0
    syscall

    # Open file for writing:
    li $v0, 13
    la $a0, brighter
    li $a1, 9       # flag for write and append
    la $a2, 0
    syscall
    move $s1, $v0   # $s1 contains file descriptor for file we write to

    li $v0, 15
    move $a0, $s1   # $a0 should contain descriptor of file we are writing to
    
    la $a1, ($s4)
    li $a2, 19
    syscall

    # Header is 19 bytes
    add $s4, $s4, $v0
    move $t4, $zero # $t4 has value of number
    li $t3, 10
    la $s2, number  # Stores address of number
    la $t7, reverse_string

reset:
    la $t0, number  # $t0 contains address of space of int_to_string number
    move $t2, $zero
    la $t7, reverse_string
    move $t1, $zero

brighten:
    #String to int
    
    lb $t2, ($s4)
    add $s4, $s4, 1
    # Change immediate value comparison to 0 if lf file in line 82
    # Change immediate value comparison to 13 if crlf file in line 82
    beq $t2, 0, average

    beq $t2, 10, addition
    addi $t2, $t2, -48
    mul $t4, $t4, $t3 # multiply number by 10
    add $t4, $t4, $t2
    
    j brighten

int_to_str:
    #Int to str and write
    div $t4, $t3
    mfhi $t5
    mflo $t4
    addi $t5, $t5, 48
    sb $t5, ($t0)
    add $s3, $s3, 1     # Counter must count digits
    beqz $t4, counter   # $t4 will contain 0 when conversion is finished
    addi $t0, $t0, 1    # $t0 must referto last end number not after 
    j int_to_str
    

addition:               # Need to keep running total
    add $s5, $s5, $t4   # Add value before brightening to running total
    addi $t4, $t4, 10   # $t4 contains brightened R,G,B value - 10 controls how much brighter we want our image
    add $s6, $s6, $t4   # Add value after brightening to running total
    bgt $t4, 255, limit
    j int_to_str

limit:
    # If new value is more than 255 make it equal to 255
    li $t4, 255
    j int_to_str

counter:
    # Get number of digits into $t1
    move $t1, $s3
    j reverse

reverse:
    # Taking the stored new value from memory and writing it 
    lb $t6, ($t0)
    sb $t6, ($t7)
    addi $t0, $t0, -1
    sub $s3, $s3, 1
    add $t7, $t7, 1
    beqz $s3, write_to_file # $s3 stores length of number
    j reverse

write_to_file:
    la $t8, newline
    lb $t9, ($t8)
    sb $t9, ($t7)
    
    li $v0, 15
    move $a0, $s1
    la $a1, reverse_string
    addi $t1, $t1, 1        # Add 1 to length of number so we write new converted value appended with a newline characeter
    move $a2, $t1
    syscall

    j reset

average:
    # Displays average value of all pixels to console in the range [0,1]
    # $s5, $s6 rspectively contain sum of R,G,B values before, and after
    li $v0, 4
    la $a0, prompt_before
    syscall

    # Load integer values into FPU registers
    mtc1 $s5, $f0      # Move $t0 (numerator) to $f0 (FPU register)
    lw $s7, divisor
    mtc1 $s7, $f1      # Move $t1 (denominator) to $f1 (FPU register)

    # Divide $f0 (numerator) by $f1 (denominator)
    div.s $f2, $f0, $f1   # Divide and store the result in $f2

    li $v0, 2 # Syscall to to print floating point to console
    mov.s $f12, $f2
    syscall


    li $v0, 4
    la $a0, prompt_after
    syscall

    # Load integer values into FPU registers
    mtc1 $s6, $f4     # Move $t0 (numerator) to $f0 (FPU register)

    # Divide $f0 (numerator) by $f1 (denominator)
    div.s $f5, $f4, $f1   # Divide and store the result in $f2

    li $v0, 2
    mov.s $f12, $f5
    syscall

exit:
    # Close file and exit program
    li $v0, 16
    move $a0, $s1
    syscall

    li $v0, 10
    syscall