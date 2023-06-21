/*
Steven Tieu
TCES 380 Project, ALU unit
16-bit ALU unit takes in two 16-bit inputs and one 16-bit output.

Overflow and underflow allowed to occur.
 */

module ALU(SelectFunc, A, B, Q);
	parameter Bits;
	input [2:0] SelectFunc;
	input [(Bits - 1):0] A, B; //Select and the inputs
	output logic [(Bits - 1):0] Q; //output;
	
	//Mux_3w_8_to_1( M, S, R, T, U, V, W, X, Y, Z);
	//Mux_3w_8_to_1 unit(Q, Sel, 3'b000, A + B, A - B, A, A ^ B, A | B, A & B, A + 3'b001);
	always @(SelectFunc, A, B) begin
		case(SelectFunc)
			3'b000: Q = 3'b000; //0
			3'b001: Q = A + B; 	//ADD
			3'b010: Q = A - B;	//SUBTRACT
			3'b011: Q = A;		//BYPASS
			3'b100: Q = A ^ B;	//XOR
			3'b101: Q = A | B;	//OR
			3'b110: Q = A & B;	//AND
			/*3'b111*/ default: Q = A + 3'b001; //ADD ONE
		endcase
	end
endmodule

module ALU_tb;
	logic [2:0] SelectFunc; //Select
	logic [15:0] A, B; //ALU inputs
	logic [15:0] Q; //ALU output
	ALU #(.Bits(16)) DUT(SelectFunc, A, B, Q);
	initial begin
		A = 16'b0101010101010101;
		B = 16'b1010101010101001;

		for(int k = 0; k < 8; k++) begin
			SelectFunc = k;
			#10;
		end

		for(int j = 0; j < 10; j++) begin
			{A, B} = $random;
			SelectFunc = $random;
			#10;
		end
	end
	initial
	$monitor( "Sel = %d \t A = %h \t B = %h \t Q = %h", SelectFunc, A, B, Q);
endmodule
	