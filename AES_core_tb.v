`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: m62ammar@gmail.com
// Engineer: Mohamed Ammar
//
// Create Date:   02:43:44 02/06/2021
// Design Name:   matrices
// Module Name:   E:/CUFE/digital_design/verilog/Adv_Encryption_Sys/AES_Core/AES_core_tb.v
// Project Name:  AES_Encryption_System
// Target Device:  
// Tool versions:  
// Description: Test bench for the behaviour of the AES core unit
//
// Verilog Test Fixture created by ISE for module: matrices
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module AES_core_tb;

	// Inputs
	reg clk;
	reg reset;
	reg [7:0] state;
	reg [7:0] key;
	reg [127:0] full_key,full_state;
	// Outputs
	wire [127:0] text;

	// Instantiate the Unit Under Test (UUT)
	AES_core uut (
		.clk(clk), 
		.reset(reset), 
		.state(state), 
		.key(key), 
		.text(text)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		state = 0;
		key = 0;
		

		// Wait 100 ns for global reset to finish
		#100 reset = 0;
	end
   

		// Add stimulus here		
		integer i;

			always @(posedge clk)
			begin 
				if ( ~reset )
				begin 
					key <= full_key[i-:8];
					state <= full_state[i-:8];
					i = i-8;
				end 
			end 
		
		
		initial 
			begin 
					  full_key   <= 128'h2B7E151628AED2A6ABF7158809CF4F3C;
					  full_state <= 128'h3243F6A8885A308D313198A2E0370734;

			  i <= 127;
			end
					
always     #10  clk = ~clk ;
      
endmodule

