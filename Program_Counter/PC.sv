/*
	Steven Tieu
	5-23-2023
	Project - Program Counter.
	Counter for instruction memory.
 */

module PC(Clk, Clr, Up, Addr);
	input Clk;
	input Clr; 	//Clr is 1 when we init, addr = 7'd0;
	input Up;//up signals to go to next instruction, basically up = Enable.
	output logic [6:0] Addr; //Next address to do.

	always_ff @(posedge Clk) begin //Inferred latch is fine in always_ff
		if(Clr) Addr <= 7'd0; //Clr is on
		else if(Up) Addr <= Addr + 1'b1; //Increment
		// else Addr <= Addr; //if(!Up), NOTE TO SELF: may cause quartus errors. 
		//also once we reach max instructions, just repeat the last one.
	end
	
endmodule 

`timescale 1ns/1ps
module PC_tb();

	logic Clk, Clr, Up;
	logic [6:0] addr;
	
	PC DUT(Clk, Clr, Up, addr);
	
	always begin ////20 ns Clock for a 50Mhz clock
		Clk = 0;
		#10;
		Clk = 1;
		#10;
	end
	
	initial begin
		Clr = 1; Up = 1; #20;
		Clr = 0; 	 	 
		for(int k = 0; k < 127; k++) begin
			#10;
			assert(addr == k); //Throws error if something is wrong.
			#10;
		end 
		$stop;
	end
	
	initial $monitor($time,,,"Clr = %b \t En/Up = %b \t addr = %b", Clr, Up, addr);
endmodule 