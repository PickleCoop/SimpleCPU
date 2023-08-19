/**
* Evan Cooper & Steven Tieu
* Digital Systems Design SP23
*
* This MUX is designed to switch between two
* 16 bit-wide inputs to an output based on a 
* given selection bit.
*/

module Mux_16w_2to1(Sel, A, B, M);
 	input Sel; // mux select line in
 	input [15:0] A, B; // mux inputs
 	output logic [15:0] M; // mux output
	
	always_comb begin
		if(Sel == 1) M = A;
		else M = B;
	end
endmodule

// Testbench
module Mux_16w_2to1_tb();
	logic Sel; //Select
	logic [15:0] A, B; //Mux inputs
	logic [15:0] M; //Mux output
	Mux_16w_2to1 DUT(.Sel(Sel), .A(A), .B(B), .M(M));
	initial begin
		A = 16'hAAAA;
		B = 16'hBBBB;
		Sel = 0; #10;
		Sel = 1; #10;

		for(int k = 0; k < 20; k++) begin
			{Sel, A, B} = $random;
			#10;
			assert (Sel ? M == A : M == B) $display ("PASSED: Sel = %b \t A = %h \t B = %h \t M = %h",
			Sel, A, B, M);
			#10;
		end
		
	end
endmodule