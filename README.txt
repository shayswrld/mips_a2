## CSC2002S, Computer Architecture Assignment

## Description

Programs to perform image processing on some given image input in the form of a .ppm file.
Program 1 enhances the brightness of a given image.
Program 2 converts a given colour image into a greyscale image.

## Files
- 'increase_brightness.asm': This is the MIPS assembly file that contains the code for program 1.
- 'greyscale.asm': This is the MIPS assembly file that contains the code for program 2.

## Prerequisites
To run this program, you will need:
- A MIPS simulator such as SPIM or MARS.
- A graphics editor such as GIMPS if you would like to view the modifed image.

## Usage

## Program 1

1) Ensure that the input image [.ppm file] is in the same directory as the MIPS program [increase_brightness.asm]

2) Create an output file with either a .txt or .ppm file extension. Ensure that this output file is in the same directory as both [increase_brightness.asm] and the input [.ppm] file This is where the input program will be converted and written to.

3) In the program code you will find two labels in the .data declarations, namely input_path and brighter. These will be the paths to our input and output files respectively. 

4) Find the input .ppm file, copy the absolute path (CTRL+SHIFT+C on Windows) and paste it in the input_path label.

5) Find the output file, copy the absolute path and paste it in the brighter label.

6) Run the program in the MIPS simulator, the resulting modified image will be stored in the output .ppm file created.

Note program 1:
-  The default program uses an ascii 13 [CR] character to determine when there are no more characters to read and convert
   and it assumes the newline character is ASCII 10. 
   You would want the form of the input file to be a newline character after each line [LF] and a [CR] character at the end of the file. 
   This is generally the input file in the form "house_64_in_ascii_crlf.ppm".
   Certain .ppm files may have the format of a null value [0] at the end of the file with ascii 10 as a newline character [LF files].
   In this case, simply change line 84: beq $t1, 13, exit -> beq $t1, 0, exit
   Certain .ppm files may have the format of ascii 10 value to signify the end of the file with ascii 13 as the newline character
   These are generally the [CR] files.
   In this case, change line 82: beq $t2, 13, average -> beq $t2, 10, average 
   Change line 84: beq $t2, 10, addition -> beq $t2, 13, addition

-  The average pixel values outputted represent the total sum of all Red, Green and Blue values divided by 64*64*3*255 (the total number of rows and columns * three RGB values * 255)
   This provides us with an average in the range [0,1] and is what GIMP provides in the image histogram.

## Program 2

1) Ensure that the input image [.ppm file] is in the same directory as the MIPS program [greyscale.asm]

2) Create an output file with either a .txt or .ppm file extension. Ensure that this output file is in the same directory as both [greyscale.asm] and the input [.ppm] file.
   This is where the input program will be converted and written to.

3) In the program code you will find two labels in the .data declarations, namely input_path and output_path. 
   These will be the paths to our input and output files respectively. 

4) Find the input .ppm file, copy the absolute path and paste it in the input_path label.

5) Find the output file, copy the absolute path and paste it in the brighter label.

6) Run the program in the MIPS simulator, the resulting modified image will be stored in the output .ppm file created.

Note program 2:
- The default program uses an ascii 13 [CR] character to determine when there are no more characters to read and convert
  and it assumes the newline character is ASCII 10.
  You would want the form of the input file to be a newline character after each line [LF] and a [CR] character at the end of the file. 
  This is generally the input file in the form "house_64_in_ascii_crlf.ppm". 
  Certain .ppm files may have the format of a null value at the end of the file with ascii 10 as a newline character [LF files].
  In this case, simply change line 84: beq $t1, 13, exit -> beq $t1, 0, exit
  Certain .ppm files may have the format of ascii 10 value to signify the end of the file with ascii 13 as the newline character
  These are generally the [CR] files.
  In this case, change line 84: beq $t1, 13, exit -> beq $t1, 10, exit 
  Change line 86: beq $t1, 10, rgb -> beq $t1, 13, rgb
  