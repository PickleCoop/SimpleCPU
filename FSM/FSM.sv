/**
* Evan Cooper & Steven Tieu
* Digital Systems Design SP23
*/

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

	input [15:0] IR;
	input clk, Reset;
	output logic [7:0] D_addr;
	output logic [3:0] RF_W_addr, RF_Ra_addr, RF_Rb_addr;
	output logic PC_clr, IR_Id, PC_up, D_wr, RF_s, RF_W_en;
	output logic [2:0] ALU_s0;
	output logic [3:0] outputCurrentState, outputNextState;
	logic [3:0] currentState, nextState;
	assign outputCurrentState = currentState;
	assign outputNextState = nextState;
	localparam Init = 4'h0, Fetch = 4'h1, Decode = 4'h2, NOOP = 4'h3, LOAD_A = 4'h4, 
			   LOAD_B = 4'h5, STORE = 4'h6, ADD = 4'h7, HALT = 4'h8, SUB = 4'h9;
	
	always_comb begin
		PC_clr = 1'b0;
		PC_up = 1'b0;
		IR_Id = 1'b0;
		D_wr = 1'b0;
		RF_W_en = 1'b0;
		RF_s = 1'b0;
		ALU_s0 = 3'b000;
		D_addr = 8'b0;
		RF_W_addr = 4'b0;
		RF_Ra_addr = 4'b0;
		RF_Rb_addr = 4'b0;
		
		case(currentState)
			Init: begin
				PC_clr = 1'b1;
				nextState = Fetch;
			end
			Fetch: begin
				PC_up = 1'b1; 
				IR_Id = 1'b1;
				nextState = Decode;
			end
			Decode: begin
				if(IR[15:12] == 4'b0101) nextState = HALT;
				else if(IR[15:12] == 4'b0010) nextState = LOAD_A;
				else if(IR[15:12] == 4'b0001) nextState = STORE;
				else if(IR[15:12] == 4'b0011) nextState = ADD;
				else if(IR[15:12] == 4'b0100) nextState = SUB;
				else if(IR[15:12] == 4'b0000) nextState = NOOP;
				else nextState = Fetch; //This is Reset?
			end
			NOOP: begin
				nextState = Fetch;
			end
			LOAD_A: begin
				D_addr = IR[11:4];
				RF_s = 1'b1;
				RF_W_addr = IR[3:0];
				RF_W_en = 1'b0;
				nextState = LOAD_B;
			end
			LOAD_B: begin
				D_addr = IR[11:4];
				RF_s = 1'b1;
				RF_W_addr = IR[3:0];
				RF_W_en = 1'b1;
				nextState = Fetch;
			end
			STORE: begin
				D_addr = IR[7:0];
				D_wr = 1'b1;
				RF_Ra_addr = IR[11:8];
				nextState = Fetch;
			end
			ADD: begin
				RF_W_addr = IR[3:0];
				RF_W_en = 1'b1;
				RF_Ra_addr = IR[11:8];
				RF_Rb_addr = IR[7:4];
				ALU_s0 = 3'b001;
				RF_s = 1'b0;
				nextState = Fetch;
			end
			SUB: begin
				RF_W_addr = IR[3:0];
				RF_W_en = 1'b1;
				RF_Ra_addr = IR[11:8];
				RF_Rb_addr = IR[7:4];
				ALU_s0 = 3'b010;
				RF_s = 1'b0;
				nextState = Fetch;
			end
			HALT: begin
				nextState = HALT;
			end
			default nextState = Init;
		endcase
	end
		
	always_ff @(posedge clk) begin
		if(!Reset) currentState <= Init;
		else currentState <= nextState;
	end

endmodule



module FSM_tb;
	logic [15:0] IR;
	logic clk, Reset;
	logic [7:0] D_addr;
	logic [3:0] RF_W_addr, RF_Ra_addr, RF_Rb_addr;
	logic PC_clr, IR_Id, PC_up, D_wr, RF_s, RF_W_en;
	logic [2:0] ALU_s0;
	logic [3:0] currentState, nextState;

	FSM DUT (IR, PC_clr, IR_Id, PC_up, D_addr, D_wr, RF_s, 
		RF_W_addr, RF_W_en, RF_Ra_addr, RF_Rb_addr, ALU_s0,
		 currentState, nextState, clk, Reset);

	always begin
		clk = 0; #10;
		clk = 1; #10;
	end

	initial begin

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

		Reset = 0;
    	@ ( posedge clk ) 
		#15;		
		assert(currentState == 4'h0) //Init; test for clr
		$display($time,,,, "RESET PASSED");
    	#5 Reset = 1; 
		assert(PC_clr == 1'b1 && currentState == 4'h0 && nextState == 4'h1)		
		$display($time,,,, "INITIAL PASSED");

		//Fetch; test for IR_Id, PC_up
		#20;
		//$display("IR_Id = %d, PC_up = %d", IR_Id, PC_up);
		assert(IR_Id == 1'b1 && PC_up == 1'b1 && currentState == 4'h1)
		$display($time,,,, "FETCH PASSED, SENDING IR...");
		IR = 16'h3536; //RF[5] + RF[3] = RF[6];
		//Decode
		#20;
		assert(currentState == 4'h2)
		$display($time,,,, "DECODE PASSED\n");
		//ADD
		#20;
		$display($time,,,, "Add Operation: Write Address = %b | Write Enable = %d | A Address = %b | B Address = %b | ALU Select = %b",
		 RF_W_addr, RF_W_en, RF_Ra_addr, RF_Rb_addr, ALU_s0);
		assert(currentState == 4'h7 && RF_Ra_addr == 4'h5 && RF_Rb_addr == 4'h3 && RF_W_addr == 4'h6 && RF_W_en == 1'b1);
		$display($time,,,, "ADD PASSED");

		//SUB
		#20;
		assert(IR_Id == 1'b1 && PC_up == 1'b1 && currentState == 4'h1)
		$display($time,,,, "FETCH PASSED, SENDING IR...");
		IR = 16'h4125; //RF[1] - RF[2] = RF[5];
		#20;
		assert(currentState == 4'h2)
		$display($time,,,, "DECODE PASSED\n");
		//Add
		#20;
		$display($time,,,, "Sub Operation: Write Address = %b | Write Enable = %d | A Address = %b | B Address = %b | ALU Select = %b",
		 RF_W_addr, RF_W_en, RF_Ra_addr, RF_Rb_addr, ALU_s0);
		assert(currentState == 4'h9 && RF_Ra_addr == 4'h1 && RF_Rb_addr == 4'h2 && RF_W_addr == 4'h5 && RF_W_en == 1'b1);
		$display($time,,,, "SUB PASSED");

		//Load
		#20;
		assert(IR_Id == 1'b1 && PC_up == 1'b1 && currentState == 4'h1)
		$display($time,,,, "FETCH PASSED, SENDING IR...");
		IR = 16'h26AA; //RF[0A] = D[6A];
		#20;
		assert(currentState == 4'h2)
		$display($time,,,, "DECODE PASSED\n");
		#20;
		assert(D_addr == 8'h6A && RF_s == 1'b1 && RF_W_addr == 4'hA && RF_W_en == 1'b0)
		$display($time,,,, "LOAD A PASSED");
		$display($time,,,,"Load A Operation | Data Address: %b | Register File Select Bit: %b | Write Address: %b | Write Enable: %b", D_addr, RF_s, RF_W_addr, RF_W_en);
		#20;
		assert(D_addr == 8'h6A && RF_s == 1'b1 && RF_W_addr == 4'hA && RF_W_en == 1'b1)
		$display($time,,,, "LOAD B PASSED");
		$display($time,,,,"Load B Operation | Data Address: %b | Register File Select Bit: %b | Write Address: %b | Write Enable: %b", D_addr, RF_s, RF_W_addr, RF_W_en);

		//Store
		#20;
		assert(IR_Id == 1'b1 && PC_up == 1'b1 && currentState == 4'h1)
		$display($time,,,, "FETCH PASSED, SENDING IR...");
		IR = 16'h1A6A; //RF[0A] = D[6A];
		#20;
		assert(currentState == 4'h2)
		$display($time,,,, "DECODE PASSED\n");

		#20;
		assert(D_addr == 8'h6A && D_wr == 1'b1 && RF_Ra_addr == 4'hA)
		$display($time,,,, "STORE PASSED");
		$display($time,,,,"Store Operation | Data Address: %b | Data Write: %b | A Address: %b", D_addr, D_wr, RF_Ra_addr);
		
		//No-op
		#20;
		assert(IR_Id == 1'b1 && PC_up == 1'b1 && currentState == 4'h1)
		$display($time,,,, "FETCH PASSED, SENDING IR...");
		IR = 16'h0125; //NOOP
		#20;
		assert(currentState == 4'h2)
		$display($time,,,, "DECODE PASSED\n");
		#20;
		$display($time,,,,"Previous Sub Operation w/ NOOP: Write Address = %b | Write Enable = %d | A Address = %b | B Address = %b | ALU Select = %b", RF_W_addr, RF_W_en, RF_Ra_addr, RF_Rb_addr, ALU_s0);
		assert(RF_s == 1'b0 && RF_W_en == 1'b0 && D_wr == 1'b0 && ALU_s0 == 3'b000)
		$display($time,,,, "NOOP PASSED");
		
		//Halt
		#20;
		assert(IR_Id == 1'b1 && PC_up == 1'b1 && currentState == 4'h1)
		$display($time,,,, "FETCH PASSED, SENDING IR...");
		IR = 16'h5125; //HALT
		#20;
		assert(currentState == 4'h2)
		$display($time,,,, "DECODE PASSED");
		#20;
		assert(currentState == 4'h8 && nextState == 4'h8)
		$display($time,,,, "HALT PASSED");
		
		//Store again after halt
		//IR = 16'b0001101010101011; #20;
		//$display("Store Operation After Halt (Should not Change from Previous Store) | Data Address: %b | Data Write: %b | A Address: %b", D_addr, D_wr, RF_Ra_addr);

		$stop;

	end

	initial begin
		$monitor($time,,,, "IR_load = %b | PC_up = %b | Instruction = %h | Wr_Addr = %b | Wr_En = %b | rdAddrA = %b | rdAddrB = %b | DataAddr = %b | DataWr_En = %b | ALU_sel = %b | (RF)Mux_sel = %b",
		IR_Id, PC_up, IR, RF_W_addr, RF_W_en, RF_Ra_addr, RF_Rb_addr, D_addr, D_wr, ALU_s0, RF_s);
	end


endmodule




























