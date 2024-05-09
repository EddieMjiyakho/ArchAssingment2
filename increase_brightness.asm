.data
    image_filename: .asciiz "C:\Users\Sakhile Mjiyakho\Arch Assignment\sample_images\house_64_in_ascii_crlf.ppm"
    image_content_count: .space 80000 #image content space used to count length
    image_content: .space 80000 # 60000 bytes for the image file
    image_max_size: .word 80000
    output_file: .asciiz "C:\Users\Sakhile Mjiyakho\Arch Assignment\increase_image.ppm"
    header_string: .space 200 #header of the file

    temp_string: .space 4 # temp string of line if reversed
    output_string: .space 80000

    output_avg: .asciiz "Average pixel value of the original image:\n"
    output_incr_avg: .asciiz "Average pixel value of new image:\n"
    newline: .asciiz "\n"

    error: .asciiz "Error: File could not be read"

.text   

main:
#load and read input file
    li $v0, 13
    la $a0, house_64_in_ascii_crlf.ppm
    li $a1, 0
    li $a2, 0
    syscall
    move $s0, $v0 # save file name

    #open file to write on 
    li $v0, 13
    la $a0, increase_image.ppm
    li $a1, 1
    syscall
    move $s1, $v0

     bnez $v0, file_opened

     li $v0, 4
     la $a0, error
     syscall

     li $v0, 10
     syscall
    

file_opened:

    li $t0, 0 #num incremented set to zero when new num read
    li $t1, 0 #position counter of string to int part

    li $t3, 0 #length loop position 
    li $t4, 0 #count length of output_string

    li $t5, 0 #the digit counter for  temp string
    li $t6, 0 #the position counter for the int to string part
    li $t7, 0 #counter to skip first 3 lines - will incr if = "\n"

    li $t8, 0 #sumOfAverages before incr
    li $t9, 0 #sumOfAverages after incr

    li $s6, 0 #counter
    li $s3, 12292 
    li $s2, 4 #num numOfLines

read_file:
    #read 
    li $v0, 14
    move $a0, $s0
    la $a1, image_content
    la $a2, 80000
    syscall

    #close 
    li $v0, 16
    move $a0, $s0
    syscall

    j skip_three_lines

skip_three_lines:
    beq $t6, 19, ascii_to_int
    lb $t2, image_content($t1)
   
    sb $t2, output_string($t6) #add to output string then skip over for brightness process
    
    addi $t6, $t6, 1
    
    #beq $t2, 10, incr_skip_counter
    
    addi $t1, $t1, 1
    addi $t7, $t7, 1
    j skip_three_lines


incr_skip_counter: 

    addi $t7, $t7, 1
    addi $t1, $t1, 1

    
    j skip_three_lines

 
ascii_to_int:
    bge $s2, $s3, count_output_string
    lb $t2, image_content($t1)
    beq $t2, 10, incr_by_ten #when line finishes then continue process of adding to int 

    #converting to int
    sub $t2, $t2, 48
    mul $t0, $t0, 10
    add $t0, $t0, $t2

    addi $t1, $t1, 1 # incr by one (currently on \n)
    j ascii_to_int
    
incr_by_ten:
    add $t8, $t8, $t0 #add $t0 to the sum of pixels
    li $s7, 255
    addi $t0, $t0, 10 #incr with 10
    bge $t0, $s7, skip_add_ten #skip incr if at 255
    add $t9, $t9, $t0 #sum pixels after incr
    j int_to_ascii

skip_add_ten:
    li $t0, 255 #if over 255 then set to 255
    add $t9, $t9, $t0 
    j int_to_ascii
    

int_to_ascii:
    #div by 10 for unit
    div $t0, $t0, 10
    mfhi $t3 #remainder in $t3

    addi $t3, $t3, 48 #convert to ascii by adding a 0 - 48 
    sb $t3, temp_string($t5)

    
    beqz $t0, reverse_int_ascii  
    addi $t5, $t5, 1

    j int_to_ascii



reverse_int_ascii: #reverse the string to ascii 
    
    lb $t3, temp_string($t5)
    sb $t3, output_string($t6)

    addi $t6, $t6, 1
    addi $t5, $t5, -1

    beq $t5, -1, end_int_to_ascii 

    j reverse_int_ascii


end_int_to_ascii:
    li $t3, 10 #newline character
    sb $t3, output_string($t6)
    addi $t6, $t6, 1

    li $t0, 0
    li $t5, 0
    addi $t1, $t1, 1
    addi $s2, $s2, 1 #incr if line processed
    j ascii_to_int

count_output_string:
    lb $t2, output_string($s6)
    beqz $t2, finish_off

    addi $s6, $s6, 1
    addi $t4, $t4, 1 
    j count_output_string

finish_off:
    li $t2, 0 #counter for position of byte in output
    j write_to_file

write_to_file:
    
    li $v0, 13
    la $a0, output_file
    li $a1, 1
    syscall
    move $s1, $v0


    li $v0, 15
    move $a0, $s1
    la $a1, output_string
    move $a2, $t4
    syscall 

    #close file
    li $v0, 16
    move $a0, $s7
    syscall



display_avgs:
    
    #close 
    li $v0, 16
    move $a0, $s7
    syscall

    # Calc before incr
    li $s4, 3133440

    
    mtc1 $t8, $f0      
    mtc1 $s4, $f2
    div.s $f4, $f0, $f2 

    mov.s $f12, $f4


    li $v0, 4
    la $a0, output_avg
    syscall

    li $v0, 2
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    mtc1 $t9, $f0      
    mtc1 $s4, $f2
    div.s $f4, $f0, $f2 

    mov.s $f12, $f4

    li $v0, 4
    la $a0, output_incr_avg
    syscall

    li $v0, 2
    syscall

exit:

    li $v0, 10
    syscall
