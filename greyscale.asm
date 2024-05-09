.data
   input_filename: .asciiz "C::/Users/Sakhile Mjiyakho/Arch Assignment/sample_images/input.ppm"
   output_filename:     .asciiz "C:/Users/Sakhile Mjiyakho/Arch Assignment/output.ppm"   
   Read_in: .space  100000
   Write_OUT: .space 100000
.text
.globl main

main:
#read in the file
     # Opening input file
        li $v0, 13          # syscall code for open
        la $a0, input_filename
        li $a1, 0 
        li $a2,0          
        syscall
        move $s0, $v0       # save in $s0
    
    # open output file, manually created by user
    li $v0, 13
    la $a0, output_filename
    li $a1, 1 # writing mode
    li $a2, 0
    syscall
    move $s1, $v0 # Save in $s1

INPUT:
     li $v0, 14
    move $a0, $s0
    la $a1, Read_in
    li $a2, 100000
    syscall

#intialising the buffers 
la $s2, Read_in 
la $s3, Write_OUT
la $s4, Write_OUT
li $t1, 1 # Counting

#changing p3 to p2
li $t2, 80  #ascii val for P
sb $t2, ($s3)
addi $s2, $s2, 1
addi $s3, $s3, 1
li $t2, 50 #ascii val two
sb $t2, ($s3)
addi $s2, $s2, 1
addi $s3, $s3, 1
#add a new line
li $t2, 10
sb $t2, ($s3)
addi $s2, $s2, 1
addi $s3, $s3, 1

#adding header into write buffer
HEADER:
lb $t2,($s2)
sb $t2,($s3)

addi $s3,$s3,1
addi $s2,$s2,1

beq $t2,10,newline
j HEADER

newline:
 addi $t1,$t1,1 #counting numLines
 beq $t1,4,Pixel_read #reading pixel vals

 j HEADER

 Pixel_read:
    li $t4, 0 #line
    li $t1, 0 #digits
    li  $t3,0 #i
    li $t5,0 #sum
    li $t6, 0 #numOfLines

String_to_int:

lb $t2,($s2)

beq $t2,10,Line
beq $t2,0,WRITE
#beq $t2,13,Line


sub $t2,$t2,48
mul $t4,$t4,10
add $t4,$t4,$t2

addi $s2,$s2,1


j String_to_int


Line:
addi $s2,$s2,1
 addi $t3,$t3,1
 add $t5,$t5,$t4
 li $t4,0

 beq $t3,3,AVG
j String_to_int

 AVG:
addi $t6,$t6,1
beq $t6,4097,WRITE

divu$t5,$t5,3
mflo $t4

blt $t4,100,ADD1
addi $s3,$s3,3 # ne


li $t8,10
sb $t8,($s3)

j INT_STRING


ADD1:
blt $t4,10,nADD

addi $s3,$s3,2


li $t8,10
sb $t8,($s3)

j INT_STRING


nADD:
addi $s3,$s3,1


li $t8,10
sb $t8,($s3)
j INT_STRING


INT_STRING:
    beqz $t4, end    #if int=0, conversion=done
    divu $t4, $t4, 10     
    mfhi $t3             
    addi $t3, $t3, 48     #digit to ASCII character
    sb $t3, -1($s3)       
    addi $s3, $s3, -1       #Moving pointer backward    
    addi $t1,$t1,1

    j INT_STRING

end:
add $s3,$s3,$t1
addi $s3,$s3,1
li $t1,0
li$t3,0
li $t5,0

j String_to_int

WRITE:
sb $t2,($s3)
sub $s4,$s3,$s4



 li $v0, 15
    move $a0, $s1
    la $a1, Write_OUT
    move $a2, $s4
    syscall

close:
    li $v0, 16          # syscall close
    move $a0, $s0       # input file 
    syscall

    li $v0, 16          # syscall close
    move $a0, $s1       # output file 
    syscall



  
    li $v0, 10          #exit
    syscall