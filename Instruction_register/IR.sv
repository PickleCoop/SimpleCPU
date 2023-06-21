/*
	Steven Tieu
	5-25-2023
	Project - Instruction register.
	Holds instruction for FSM to process
	If Id = 1 then we send the next instruction
	else remain the same.
 */
module IR(Clk, inData, outData, Id);

	input [15:0] inData; 
	input Clk, Id; //Id = enable.
	output logic [15:0] outData;
	
	//Based on Lab 5 Part 2 flip-flop.
	always_ff @(posedge Clk) begin
		if(Id) outData <= inData;
		// else outData <= outData; Not necessary
	end

endmodule

module IR_tb;
	
	logic [15:0] inData, outData;
	logic Clk, Id;
	
	IR DUT(Clk, inData, outData, Id);
	
	always begin ////20 ns Clock for a 50Mhz clock
		Clk = 0;
		#10;
		Clk = 1;
		#10;
	end
	
	initial begin
		inData = 16'hABCD; Id = 1; #2;
		@(posedge Clk) #5;
		$display($time,,,"In = %h \t Out = %h \t Id/En = %b", inData, outData, Id); #2;
		assert(outData == inData) $display($time,,,"Id = 1 Passed!"); #2;
		inData = 16'h1234; Id = 0; #2;
		@(posedge Clk) #5;
		$display($time,,,"In = %h \t Out = %h \t Id/En = %b", inData, outData, Id); #2;
		assert(outData == 16'hABCD) $display($time,,,"Id = 0 Passed!"); #18;

		$monitor($time,,,"In = %h \t Out = %h \t Id/En = %b", inData, outData, Id);
		for(int k = 0; k < 10; k++) begin
			{inData, Id} = $random;
			#20;
		end
		$stop;
	end

endmodule