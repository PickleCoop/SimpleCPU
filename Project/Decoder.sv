/* Steven Tieu
 * TCES330 Spring 2023
 * Tuesday 4/22/2023
 * Decoder for 16 hexadecimal numbers, from figure 2 in HW3.pdf
 */
module Decoder(In, Out);

	input [3:0] In;
	output logic [6:0] Out;
	
	///NOTE: 1 = off, 0 = on.
	always @(In) begin
		case(In)
			4'b0000: Out = 7'b0000001; //0
			4'b0001: Out = 7'b1001111; //1
			4'b0010: Out = 7'b0010010; //2
			4'b0011: Out = 7'b0000110; //3
			4'b0100: Out = 7'b1001100; //4
			4'b0101: Out = 7'b0100100; //5
 			4'b0110: Out = 7'b0100000; //6
			4'b0111: Out = 7'b0001111; //7
			4'b1000: Out = 7'b0000000; //8
			4'b1001: Out = 7'b0000100; //9
			4'b1010: Out = 7'b0001000; //A
			4'b1011: Out = 7'b1100000; //B
			4'b1100: Out = 7'b0110001; //C
			4'b1101: Out = 7'b1000010; //D
			4'b1110: Out = 7'b0110000; //E
			default: Out = 7'b0111000; //F //Can only be 4'b1111
		endcase
	end
endmodule
