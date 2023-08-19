/**
* Evan Cooper & Steven Tieu
* Digital Systems Design SP23
*
* This is the top level module of the
* simple processor. It connects all the modules
* together and will use files generated in Quartus
* for the ROM and RAM.
*/

module Processor(Clk, Reset, IR_Out, PC_Out, State, NextState, ALU_A, ALU_B, ALU_Out);
	input Clk, Reset;
	output logic [15:0] IR_Out, ALU_A, ALU_B, ALU_Out;
	output logic [6:0] PC_Out;
	output logic [3:0] State, NextState;
	logic [2:0] ALU_s0;
	logic [7:0] D_Addr;
	logic D_Wr, RF_W_en, RF_s;
	logic [3:0] RF_Ra_Addr, RF_Rb_Addr, RF_W_Addr;

	/*Controller(Clk, Reset, ALU_s0, D_Addr, D_Wr, IR_Out, nextState, outState, 	
		   PC_Out, RF_Ra_Addr, RF_Rb_Addr, RF_W_Addr, RF_W_en, RF_s);*/
	Controller controller(.Clk(Clk), .Reset(Reset), .ALU_s0(ALU_s0), 
							.D_Addr(D_Addr), .D_Wr(D_Wr), .IR_Out(IR_Out), 
							.nextState(NextState), .outState(State), .PC_Out(PC_Out),
							.RF_Ra_Addr(RF_Ra_Addr), .RF_Rb_Addr(RF_Rb_Addr), 
							.RF_W_Addr(RF_W_Addr), .RF_W_en(RF_W_en), .RF_s(RF_s));

	/*module Datapath(ALU_s0, D_addr, clk, rdAddrA, D_wr, RF_sel, WriteAddr, 
                rdAddrB, RF_W_en, ALU_A_out, ALU_B_out, ALUout);*/
	Datapath datapath(.ALU_s0(ALU_s0), .D_addr(D_Addr), .clk(Clk), .rdAddrA(RF_Ra_Addr), 
						.D_wr(D_Wr), .RF_sel(RF_s), .WriteAddr(RF_W_Addr), .rdAddrB(RF_Rb_Addr), 
						.RF_W_en(RF_W_en), .ALU_A_out(ALU_A), .ALU_B_out(ALU_B), .ALUout(ALU_Out));

	/* Translating the pseudocode from project pdf.
		Turn in the following sample program compiled and loaded into Instruction Memory:
			RF[0A] = D[1B] - D[2A] + D[3C] - D[7E];
			D[6A] = RF[0A];
			HALT
		LOAD D[1B] to RF[01] --> 16'h21B1 in ROM reg 0, 8'h1B = 8'd27
		LOAD D[2A] to RF[02] --> 16'h22A2 in ROM reg 1, 8'h2A = 8'd42
		LOAD D[3C] to RF[03] --> 16'h23C3 in ROM reg 2, 8'h3C = 8'd60
		LOAD D[7E] to RF[04] --> 16'h27E4 in ROM reg 3, 8'h7E = 8'd126
		SUB RF[01] - RF[02] = RF[05] --> 16'h4125 in ROM reg 4
		ADD RF[05] + RF[03] = RF[06] --> 16'h3536 in ROM reg 5
		SUB RF[06] - RF[04] = RF[0A] --> 16'h464A in ROM reg A
		STORE RF[0A] to D[6A] --> 16'h1A6A in ROM reg 7
		HALT --> 16'h5xxx in ROM reg 8

		Data memory should initially contain
			D[1B] = 0x21BA
			D[2A] = 0xA04E
			D[3C] = 0x71AC
			D[7E] = 0xB17F
		RF[0A] = 0x21BA - 0xA04E + 0x71AC - 0xB17C
		RF[0A] = 0x21BA - 0xA04E + 0x71AC - 0xB17C
	*/

	/* Instructions set in MIF File:
	Init from Reset = 1;
	//2 clocks to fetch and decode between each.
	Add IR: 16'b0011000000000001 = 16'h3001 (Opcode[15:12], rdAddrA[11:8] + rdAddrB[7:4], WriteAddr[3:0])
	Sub IR: 16'b0100000000000001 = 16'h4001 (Opcode[15:12], rdAddrA[11:8] - rdAddrB[7:4], WriteAddr[3:0])
	Load IR: 16'b0010000000000001 = 16'h2001 (Opcode[15:12], D_addr[11:4], WriteAddr[3:0])
	Store IR: 16'b0001000000000001 = 16'h1001 (Opcode[15:12], rdAddrA[11:8], D_addr[7:0]) 
	No-op IR: 16'b0000000000000001 = 16'h0001; (Opcode[15:12], xxxx[11:0]) 
	HALT IR: 16'b0101000000000001 = 16'h5001 (Opcode[15:12], xxxx[11:0])
	Store IR: 16'b0001101010101011 = 16'h1001; is attempted store after HALT, nothing should happen.
	*/
endmodule



