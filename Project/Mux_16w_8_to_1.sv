module Mux_16w_8_to_1(in1, in2, in3, in4, in5, in6, in7, in8, s, out);
	input [15:0] in1, in2, in3, in4, in5, in6, in7, in8;
	input [2:0] s;
	output [15:0] out;
	
	always @(s, in1, in2, in3, in4 ,in5 ,in6 ,in7, in8) begin
		case (s)
			3'b000 : out = in1;
			3'b001 : out = in2;
			3'b010 : out = in3;
			3'b011 : out = in4;
			3'b100 : out = in5;
			3'b101 : out = in6;
			3'b110 : out = in7;
			default : out = in8;
		endcase
	end
endmodule

module Mux_16w_8_to_1_tb;

	logic [15:0] in1, in2, in3, in4, in5, in6, in7, in8, s;
	logic [15:0] out;
	
	Mux_16w_8_to_1 DUT (in1, in2, in3, in4, in5, in6, in7, in8, s, out);
	
	initial begin
		
	for (int i = 0; i < 8; i++) begin
      s = i;
      in1 = i;
      in2 = i + 1;
      in3 = i + 2;
      in4 = i + 3;
      in5 = i + 4;
      in6 = i + 5;
      in7 = i + 6;
      in8 = i + 7;
      #10;
    end
  end
endmodule