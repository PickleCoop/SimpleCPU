/**
* Evan Cooper & Steven Tieu
* Digital Systems Design SP23
*/

module Controller(Clk, Reset, ALU_s0, D_Addr, D_Wr, IR_Out, nextState, outState, 	
		   PC_Out, RF_Ra_Addr, RF_Rb_Addr, RF_W_Addr, RF_W_en, RF_s);

		input Clk, Reset;
		output logic [15:0] IR_Out;
		output logic [7:0] D_Addr;
		output logic [6:0] PC_Out;
		output logic [3:0] nextState, outState, RF_Ra_Addr, RF_Rb_Addr, RF_W_Addr;
		output logic [2:0] ALU_s0;
		output logic D_Wr, RF_W_en, RF_s;
	
		wire [15:0] q;
		wire PCClr, PCUp, IRLd;

		InstMemory ROM(.address(PC_Out), .clock(Clk), .q(q));
		IR instrucReg(.Clk(Clk), .inData(q), .outData(IR_Out), .Id(IRLd));
		/*
		module FSM(IR, 
				PC_clr, 
				IR_Id, 
				PC_up, 
				D_addr,
				D_wr, 
				RF_s, 
				RF_W_addr, 
				RF_W_en, 
				RF_Ra_addr, 
				RF_Rb_addr, 
				ALU_s0,
				outputCurrentState,
				outputNextState,
				clk,
				Reset);
		 */
		FSM stateMachine(.IR(IR_Out),
			        .PC_clr(PCClr),
				.IR_Id(IRLd),
				.PC_up(PCUp),
				.D_addr(D_Addr),
				.D_wr(D_Wr),
				.RF_s(RF_s),
				.RF_W_addr(RF_W_Addr),
				.RF_W_en(RF_W_en),
				.RF_Ra_addr(RF_Ra_Addr),
				.RF_Rb_addr(RF_Rb_Addr),
				.ALU_s0(ALU_s0),
				.outputCurrentState(outState),
				.outputNextState(nextState),
				.clk(Clk),
				.Reset(Reset));
		PC counter(.Clk(Clk), .Clr(PCClr), .Up(PCUp), .Addr(PC_Out));
		
endmodule

`timescale 1ns/1ns
module Controller_tb;
	logic Clk, Reset;
	wire D_Wr, RF_W_en, RF_s;
	wire [15:0] IR_Out;
	wire [7:0] D_Addr;
	wire [6:0] PC_Out;
	wire [3:0] nextState, outState, RF_Ra_Addr, RF_Rb_Addr, RF_W_Addr;
	wire [2:0] ALU_s0;

	Controller DUT(.Clk(Clk), .Reset(Reset), .ALU_s0(ALU_s0), .D_Addr(D_Addr), .D_Wr(D_Wr), .IR_Out(IR_Out), 
			.nextState(nextState), .outState(outState), .PC_Out(PC_Out), .RF_Ra_Addr(RF_Ra_Addr), 
			.RF_Rb_Addr(RF_Rb_Addr), .RF_W_Addr(RF_W_Addr), .RF_W_en(RF_W_en), .RF_s(RF_s));
	always begin
		Clk = 0; #10;
		Clk = 1; #10;
	end

	/* Instructions set in MIF File:
	Init from Reset = 1;
	//2 clocks to fetch and decode between each.
	Add IR: 16'b0011000000000001 = 16'h3001
	Sub IR: 16'b0100000000000001 = 16'h4001
	Load IR: 16'b0010000000000001 = 16'h2001
	Store IR: 16'b0001000000000001 = 16'h1001
	No-op IR: 16'b0000000000000001 = 16'h0001;
	HALT IR: 16'b0101000000000001 = 16'h5001
	Store IR: 16'b0001101010101011 = 16'h1001;
	*/
	initial begin
		$monitor($time,,,,
			"Reset: %b | OUTPUT SIGNALS: ALU Sel: %b | D_Addr: %b | D_wr: %b | IR_Out: %b | nextState: %b | outState: %b | PC_Out: %b | RF_Ra_Addr: %b | RF_Rb_Addr: %b | RF_W_Addr: %b | RF_W_en: %b | RF_s: %b",
			Reset, ALU_s0, D_Addr, D_Wr, IR_Out, nextState, outState, PC_Out, RF_Ra_Addr, 
			RF_Rb_Addr, RF_W_Addr, RF_W_en, RF_s);
		Reset = 0;		//Test reset, Initial already set here.
		#31 Reset = 1;
		#40;//2 clks to fetch, decode
		#20; //Add
		assert(outState == 4'h7 && nextState == 4'h1 && ALU_s0 == 3'b001 && RF_s == 1'b0 && 
				RF_W_en == 1'b1 && RF_W_Addr == 4'hC && RF_Ra_Addr == 4'hA && RF_Rb_Addr == 4'hB)
		$display($time,,,,"ADD PASSED");
		#60; //Fetch, decode, Sub
		assert(outState == 4'h9 && nextState == 4'h1 && ALU_s0 == 3'b010 && RF_s == 1'b0 && RF_W_en == 1'b1)
		$display($time,,,,"SUB PASSED");
		#60; //Fetch, decode, Load
		assert(outState == 4'h4 && nextState == 4'h5 && RF_s == 1'b1)
		$display($time,,,,"LOAD A PASSED");
		#20; //Another cycle needed to finish LOAD
		assert(outState == 4'h5 && nextState == 4'h1 && RF_s == 1'b1 && RF_W_en == 1'b1)
		$display($time,,,,"LOAD B PASSED");
		#60; //Fetch, decode, Store
		assert(nextState == 4'h1 && D_Wr == 1'b1 && D_Addr == 8'hBC)
		$display($time,,,,"STORE PASSED");
		#60; //Fetch, decode, NOOP
		assert(outState == 4'h3 && nextState == 4'h1)
		$display($time,,,,"NO-OP PASSED");
		#60; //Fetch, decode, HALT
		#60; //Attempt to store, but only recieve HALT for 3 clks
		assert(outState == 4'h8 && nextState == 4'h8)
		$display($time,,,,"HALT PASSED");
		$display($time,,,,
			"Reset: %b | OUTPUT SIGNALS: ALU Sel: %b | D_Addr: %b | D_wr: %b | IR_Out: %b | nextState: %b | outState: %b | PC_Out: %b | RF_Ra_Addr: %b | RF_Rb_Addr: %b | RF_W_Addr: %b | RF_W_en: %b | RF_s: %b",
			Reset, ALU_s0, D_Addr, D_Wr, IR_Out, nextState, outState, PC_Out, RF_Ra_Addr, 
			RF_Rb_Addr, RF_W_Addr, RF_W_en, RF_s);
		#5;
		$stop;
	end

endmodule







