.data
    input_path: .asciiz "Paste absolute input path here"
    output_path: .asciiz "Paste absolute output path here" # Write to this file
    p2: .asciiz "P2\n"
    gray: .space 12
    reverse_string: .space 12
    newline: .asciiz "\n"
    original: .space 61440 # length of input textfile
    
.text

.globl main
main:  
    # open file for reading

    li $v0, 13
    la $a0, input_path # absolute path of file we are reading from
    li $a1, 0
    li $a2, 0          # Read-mode
    syscall 

    move $s0, $v0      # $s0 contains file descriptor for reading file

    # Read file into some string
    li $v0, 14
    move $a0, $s0
    la $a1, original # Read string into large space in memory 
    li $a2, 61440
    syscall

    la $t0, original

    # Close file that we read from
    li $v0, 16
    move $a0, $s0
    syscall

    move $s3, $zero # $s3 is counter to count length of greyscale value

header:
    # open file for writing
    li $v0, 13
    la $a0, output_path # absolute path to file we are writing to
    li $a1, 9           # write with append
    li $a2, 0           # std mode
    syscall 

    move $s1, $v0
    # Hardcode P2 as it is greyscale now
    li $v0, 15
    move $a0, $s1
    la $a1, p2
    li $a2, 3
    syscall

    addi $t0, $t0, 3 # skip P3\n in original string

    # Write the rest of header to new file
    li $v0, 15
    move $a0, $s1
    la $a1, ($t0)
    li $a2, 16
    syscall

    addi $t0, $t0, 16

    li $t3, 10
    

reset:
    la $s5, reverse_string # Address of string line that we write to file (greyscale value in ascii)
    li $t1, 0              # byte holder for original string  
    la $s4, gray
    move $s2, $zero        # counter for RGB must loop to 3 and reset 
    move $t5, $zero        # Stores running total of RGB values, will be divided
    li $t8, 0
    
Convert_to_int:
    # Convert a string to an integer
    lb $t1, ($t0)
    add $t0, $t0 1
    # Change immediate value comparison to 0 in line 84 if lf file
    # Change immediate value comparison to 13 in line 84 if crlf file 
    beq $t1, 13, exit        
    # Change immediate value comparison to 13 in line 86 if cr file 
    beq $t1, 10, rgb
    addi $t1, $t1, -48
    mul $t4, $t4, $t3      # multiply number by 10
    add $t4, $t4, $t1
    
    j Convert_to_int

rgb:
    # Check if a full set of RGB values have been read
    add $t5, $t5, $t4 # Add R,G,B values to total
    li $t4, 0
    add $s2, $s2, 1
    beq $s2, 3, average
    j Convert_to_int

average:
    # Load integer values into FP registers
    mtc1 $t5, $f0      # Move $t5 (num) to $f0 (FP register)
    li $t6, 3
    mtc1 $t6, $f1      # Move $s1 (den) to $f1(FP register)

    # Divide $f0 (numerator) by $f1 (denominator)

    div.s $f2, $f0, $f1   # Divide and store the result in $f2
    # Round down the value to the nearest whole number(floor)
    cvt.w.s $f4, $f2      # Convert contents of $f2(greyscale integer value) from sp floating point to integer
    move $s2, $zero

greyscale:
    # Convert the new averaged value to a string to write to new file
    mfc1 $t4, $f4   	  #$t4 holds floored greyscale integer value
    la $s4, gray

int_to_str:
    #Int to str and write
    div $t4, $t3
    mfhi $t5
    mflo $t4
    addi $t5, $t5, 48
    sb $t5, ($s4)
    add $s3, $s3, 1 # Counter must count digits
    beqz $t4, counter
    # Branch if $t4 is 0 so as to stop at place of last digit
    add $s4, $s4, 1 # $s4 must refer to last end digit not place after the last digit - branch before increment
    j int_to_str

counter:
    # Get number of digits into $t8
    move $t8, $s3
    j reverse

reverse:

    # Taking the stored new value from memory and writing it 
    lb $t6, ($s4)
    sb $t6, ($s5)
    sub $s4, $s4, 1
    sub $s3, $s3, 1
    beqz $s3, write_to_file #$s3 = counter = 0 then we have reversed string
    add $s5, $s5, 1
    j reverse

write_to_file:
    # Write greyscale value to file
    la $s6, newline
    lb $t9, ($s6)
    add $s5, $s5, 1
    sb $t9, ($s5) # Append newline character
    
    li $v0, 15
    move $a0, $s1
    la $a1, reverse_string
    addi $t8, $t8, 1
    move $a2, $t8   # Write (length of greyscale value + 1 bytes to output file)
    syscall

    j reset

exit:

    li $v0, 16
    move $a0, $s1
    syscall

    li $v0, 10
    syscall