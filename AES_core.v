`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: m62ammar@gmail.com
// Engineer: Mohamed Ammar , Reem Saleh
// 
// Create Date:    02:34:59 02/07/2021 
// Design Name: AES_core unit
// Module Name:    AES_core 
// Project Name: AES Encryption System
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module AES_core(
	input  clk,
	input  reset,
	input  [7:0] state,
	input  [7:0] key,
	output reg [127:0] text
    );
	
		   /* Registers */
	reg [7:0] m_state 		[0:15];		//4x4 matrix each element 8bit --- state matrix
	reg [7:0] m_key  		[0:15];		//4x4 matrix each element 8bit --- key matrix
	reg [7:0] initial_round [0:15];		//4x4 matrix each element 8bit --- first xor
	reg [7:0] IR_results    [0:15];		//4x4 matrix each element 8bit --- Initial Round results
	reg [7:0] Initial_key   [0:15];		//4x4 matrix each element 8bit --- Initial Key
	reg [7:0] new_key       [0:15];		//4x4 matrix each element 8bit --- New Key
	reg [7:0] SB_results    [0:15];		//4x4 matrix each element 8bit --- Sub Bytes results
	reg [7:0] SB_key        [0:3];		//4x4 matrix each element 8bit --- Sub Bytes of the key
	reg [7:0] SR_results    [0:15];		//4x4 matrix each element 8bit --- Shift Rows results
	reg [7:0] MC_results    [0:15];		//4x4 matrix each element 8bit --- Mix Column results
	reg [7:0] R_results     [0:15];		//4x4 matrix each element 8bit --- Round results

	/*Iteration variables*/
	reg [4:0] i= 4'b0;	
	reg [3:0] round_no;
	integer j,k;

	/* FLAGS */
	reg Initial_Round;
	reg start;
	
	/* Sub Bytes,RCon*/
	reg [7:0] S_Box [0:255]; 		//8bit vector 2D array 16 row 16 col
	reg [7:0] rcon [0:9]; 			//8bit vector 2D array 1 row 10 col
	
	initial
	begin
	$readmemh("Sbox.txt",S_Box,0,255);		//S Box elements
	end
	
	initial
	begin
	$readmemh("rcon.txt",rcon,0,9);			//Rcon elements
	end	


	always @(posedge clk) begin
		if (reset)
			Initial_Round <= 1'b0;
		else  Initial_Round <= 1'b1;
	end
	
	
			/* Initial Round */
	always @(posedge clk)begin
		if(Initial_Round == 1'b1)begin
			if(i<16) begin
				m_state[i] <= state;
				m_key[i]   <= key;
				initial_round [i] <= state ^ key;
				i	  <= i + 1'b1;
			end
			else begin
				i <= 4'b0;
				for(j= 0;j<16;j=j+1) begin
					IR_results[j] <= initial_round[j];
					Initial_key[j]   <= m_key[j];
				end
				start <= 1;
			end
		end
		else start<=0;
	

		
		if(start)begin
			if (round_no<10)begin									//SUB Bytes
				if (round_no==0)begin
					for(k=0;k<16;k=k+1)begin	
						SB_results[k]  =  Sub_Bytes(IR_results[k]);
					end
				end
				else begin
					for(k=0;k<16;k=k+1)begin	
						SB_results[k]  =  Sub_Bytes(R_results[k]);
					end
				end
		
							
							//SHIFT ROWS
				SR_results[0] = SB_results[0];
				SR_results[1] = SB_results[5];
				SR_results[2] = SB_results[10];
				SR_results[3] = SB_results[15];
				SR_results[4] = SB_results[4];
				SR_results[5] = SB_results[9];
				SR_results[6] = SB_results[14];
				SR_results[7] = SB_results[3];
				SR_results[8] = SB_results[8];
				SR_results[9] = SB_results[13];
				SR_results[10] = SB_results[2];
				SR_results[11] = SB_results[7];
				SR_results[12] = SB_results[12];
				SR_results[13] = SB_results[1];
				SR_results[14] = SB_results[6];
				SR_results[15] = SB_results[11];
				
				//MIX COL
				if (round_no < 9)begin
					for (k=0;k<16;k=k+4) begin
						MC_results[k+0]= (MultiplyByTwo(SR_results[k+0])^ MultiplyByThree(SR_results[k+1])^ SR_results[k+2]^ SR_results[k+3]);
						MC_results[k+1]= (SR_results[k+0]^ MultiplyByTwo(SR_results[k+1])^ MultiplyByThree(SR_results[k+2])^ SR_results[k+3]);
						MC_results[k+2]= (SR_results[k+0]^ SR_results[k+1]^ MultiplyByTwo(SR_results[k+2])^ MultiplyByThree(SR_results[k+3]));
						MC_results[k+3]= (MultiplyByThree(SR_results[k+0])^(SR_results[k+1])^ SR_results[k+2]^ MultiplyByTwo(SR_results[k+3]));
					end
				end
				else begin
					for (k=0;k<16;k=k+1)begin
						MC_results[k] = SR_results[k];
					end
				end
				
				
				//	Producing NEW KEY	
				if (round_no == 0)begin
					SB_key[0] = Sub_Bytes (Initial_key[13]);
					SB_key[1] = Sub_Bytes (Initial_key[14]);
					SB_key[2] = Sub_Bytes (Initial_key[15]);
					SB_key[3] = Sub_Bytes (Initial_key[12]);

					new_key [0] = SB_key[0]^rcon[round_no]^Initial_key[0];
					new_key [1] = SB_key[1]^(2'b00)^Initial_key[1];	
					new_key [2] = SB_key[2]^(2'b00)^Initial_key[2];	
					new_key [3] = SB_key[3]^(2'b00)^Initial_key[3];	

					for (k=0;k<12;k=k+1)begin
						new_key[k+4] = new_key[k] ^ Initial_key[k+4];
					end
				end
				else begin
					SB_key[0] = Sub_Bytes (new_key[13]);
					SB_key[1] = Sub_Bytes (new_key[14]);
					SB_key[2] = Sub_Bytes (new_key[15]);
					SB_key[3] = Sub_Bytes (new_key[12]);

					new_key [0] = SB_key[0]^rcon[round_no]^new_key[0];
					new_key [1] = SB_key[1]^(2'b00)^new_key[1];	
					new_key [2] = SB_key[2]^(2'b00)^new_key[2];	
					new_key [3] = SB_key[3]^(2'b00)^new_key[3];	

					for (k=0;k<12;k=k+1)begin
						new_key[k+4] = new_key[k] ^ new_key[k+4];
					end	
				end
				
				//ADD ROUND KEY
				for(k=0;k<16;k=k+1)begin
					R_results[k] = MC_results[k]^new_key[k];
				end

				round_no = round_no + 1'b1 ;	
			end
				// Output The Cipher Text
		else begin
			for (k=0;k<128;k=k+8)begin
				text[k+7-:8] = R_results[15-(k/8)];
			end
			round_no = 4'b0;
		end
		end
	end
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/*Function to replace each input with its corresponding in the S box*/
	function [7:0] Sub_Bytes;				
	input [7:0] x;
	reg [3:0] m,n;
	reg[8:0]z;
	begin
		m = x[7:4];
		n = x[3:0];
		z = m*16+n;
	
		Sub_Bytes = S_Box[z];
	end
	endfunction
	
function [7:0] MultiplyByTwo;
	input [7:0] x;
	begin 
		// multiplication by 2 is shifting on bit to the left, and if the original 8 bits had a 1 @ MSB, xor the result with 0001 1011
		if(x[7] == 1) MultiplyByTwo = ((x << 1) ^ 8'h1b);
		else MultiplyByTwo = x << 1; 
	end 	
endfunction

function [7:0] MultiplyByThree;
	input [7:0] x;
	begin 
		 // multiplication by 3 ,= 01 ^ 10 = (NUM * 01) XOR (NUM * 10) = (NUM) XOR (NUM Muliplication by 2) 
		MultiplyByThree = MultiplyByTwo(x) ^ x;
	end 
endfunction

endmodule
