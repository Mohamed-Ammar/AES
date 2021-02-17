# AES
**A** dvanced **E** ncryption **S** tandard (128-bit)
A specification for the encryption of electronic data established by the U.S. National Institute of Standards and Technology (NIST) in 2001.
aslo known by the name **Rijndael** 
*Implemented here is the encryption the decryption can be done through reversing the processes*
___
## Inputs

<pre>state ---> data to be encrypted (1Byte/clk)
key   ---> key used in encryption process (1Byte/clk)
</pre>
Each of the key and the state is sampled by the unit as byte per clock
so each clock it samples an input and after 16 clock the whole elements of the state and key matrix will be sampled also the matrix will be generated
<pre>
state matrix named as m_state in the code
  s11 s21 s31 s41
  s12 s22 s32 s42		(4x4 matrix each element is 1Byte)
  s13 s23 s33 s43
  s14 s24 s34 s44
key matrix as m_key in the code
  k11 k21 k31 k41
  k12 k22 k32 k42		(4x4 matrix each element is 1Byte)
  k13 k23 k33 k43
  k14 k24 k34 k44
  
  notice that it operates by columns not rows </pre>
  ___
  ## outputs 
  After all the encryption is done the output is the cipher text
  <pre>output reg [127:0] text</pre>
  ___
  ## Encryption Process
  The encryption process is done through 11 rounds divided as follow
  1 Initial Round
  9 Main Rounds
  1 Final Round
  The input of a round is the output of the previous round.
  Also the input of each stage is the output of the previous stage.
  Each round do certain processes and consists of certain stages as follow
  <pre>
Initial Round
	  Add Round key
9 Main Rounds
	  Sub Bytes - Shift Rows - Mix Column - Add Round Key
Final Round  
	  Sub Bytes - Shift Rows - Add Round Key
  </pre>
  ***notice that each round has its own key as the key itself undergoes certain process***
  ___
  ## Add Round Key
  This simply a bitwise xor between the state matrix and the round key for the initial round we do this with the input key and data
  ___
  ### Sub Bytes
  In this stage each byte in the state matrix is replaced by its corresponding in the S-Box.
  We access the S-Box with the least 4 bits indicating the row number and the most 4 bits indicating the column number
  <pre>
  example
  if Byte is A3
  then it will be replaced by the element 
  in row 10 col 3 from the S-Box
  </pre>
  The S-Box is written in a text file which is read using $readmemh in verilog.
 The S-Box is written as one column with 256 row to be read in verilog so we use a function to replace each element 
  <pre>
  a function takes the 8 bits element 
  access the S-Box at location (row x 16 + col )
  as the row is treated as base address and col is the offset
  </pre>
  ___
  ### Shift Rows
  According to the row number we rotate it 
  second row rotated once
  third row rotated twice
  and last row rotated four times
  <pre>
  input to shift rows			output
  a11 a12 a13 a14    		    a11 a12 a13 a14
  a21 a22 a23 a24      --->   	    a22 a23 a24 a21
  a31 a32 a33 a34		    a33 a34 a31 a32
  a41 a42 a43 a44		    a44 a41 a42 a43
  </pre>
  ___
  ### Mix Column
  In this stage we multiply the state matrix with the polynomial matrix modulus multiplication
  <pre>
Polynomial matrix
02 03 01 01
01 02 03 01
01 01 02 03
03 01 01 02
</pre>
___
## Key process
As we have 11 rounds the key is changed each round for the intial round the key is input then this key undergoes set of process to produce the new key for each round
___
### First step
we take the last column from the key matrix and rotate it so
<pre>
k41			k42		
k42			k43
k43    ------>		k44
k44			k41
</pre>
### Second step
We do the sub bytes process for the last column so each element in that last column will be replace by its corresponding element in the S-Box

### Third step
We take the firs column in the key and xor it with the ***Rcon*** and the last column after we rotate it and do sub bytes
Rcon is a column changed each round according to the round number
<pre>
round number 1  2  3  4  5  6  7  8  9  10
Rcon	     01 02 04 08 10 20 40 80 1B 36
The rest of the column is zeroes only firts element
is changed with round number
</pre>
All this steps is required for the first column
<pre>
last col after sub bytes and rotate xor Rcon xor first col in the key = first col in the new key
</pre>
After we construct the first col we 	XOR it with 2nd col if the old key producing the 2nd col in the new key
Similary after having the 2nd col we XOR it with 3rd col in the old key to produce the 3rd col in the new key

So, regardless the first column all the other column are as follows
<pre>
col<sub>i old key</sub>  XOR col<sub>i-1 new key </sub> = col<sub>i</sub> in the new key 
</pre> 
___
## Flow
The whole flow can be understood from the following diagram
![alt text](https://github.com/Mohamed-Ammar/AES/blob/main/Flow.jpg)
___
## Refrences 


1. Youtube video explaining the flow 
https://www.youtube.com/watch?v=gP4PqVGudtg

2.  open source site to check results
http://aes.online-domain-tools.com/
