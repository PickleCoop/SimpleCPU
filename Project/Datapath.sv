/*
Steven Tieu
TCES 380 Project, Datapath unit
Assembles ALU, Mux, RegFIle and a LPM 1 Port 1 into Datapath unit.

Overflow and underflow allowed to occur in ALU.
Based on Figure 4 in Datapath view.
 */
module Datapath(ALU_s0, D_addr, clk, rdAddrA, D_wr, RF_sel, WriteAddr, 
                rdAddrB, RF_W_en, ALU_A_out, ALU_B_out, ALUout);

	input clk;
	input D_wr, RF_sel, RF_W_en; //Data write enable, Register select, Register write enable.
	input [7:0] D_addr; //Data address to access.
	input [3:0] WriteAddr, rdAddrA, rdAddrB; //write address, read address A, and B
	input [2:0] ALU_s0; //ALU select

    logic [15:0] Data_to_Mux; //Data output to Mux input B
	logic [15:0] Wr_Data; //Mux to RegFiles: data to write
	logic [15:0] Ra_data, Rb_data; //RegFiles to ALU
    logic [15:0] ALU_out_to_Mux; //ALU out to mux input
 	
    //Monitor outputs
	output logic [15:0] ALU_A_out, ALU_B_out, ALUout;
	assign ALU_A_out = Ra_data;
	assign ALU_B_out = Rb_data;
	assign ALUout = ALU_out_to_Mux;

	/*regfile16x16a
	(input clk,
	 input write,
	 input [3:0] wrAddr,
	 input [15:0] wrData,
	 input [3:0] rdAddrA,
	 output logic [15:0] rdDataA,
	 input [3:0] rdAddrB,
	 output logic [15:0] rdDataB );*/

	regfile16x16a RegUnit(clk, RF_W_en, WriteAddr, Wr_Data, rdAddrA, Ra_data, rdAddrB, Rb_data); 

    //DataMemory (address, clock, data, wren, q);
    DataMemory RAMunit(D_addr, clk, Ra_data, D_wr, Data_to_Mux);

    //Mux_16w_2to1(Sel, A, B, M);
    Mux_16w_2to1 MuxUnit(RF_sel, Data_to_Mux, ALU_out_to_Mux, Wr_Data); //1 to send DataMem, 0 to send ALU out.


    //ALU(SelectFunc, A, B, Q); 
    ALU #(.Bits(16)) ALUunit(ALU_s0, Ra_data, Rb_data, ALU_out_to_Mux);

endmodule

`timescale 1ns/1ns
module Datapath_tb();

    logic clk;
	logic D_wr, RF_sel, RF_W_en; //Data write enable, Register select, Register write enable.
    logic [2:0] ALU_s0; //ALU select
	logic [7:0] D_addr; //Data address to access.
	logic [3:0] WriteAddr, rdAddrA, rdAddrB; //write address, read address A, and B
 	
    //Monitor outputs
	logic [15:0] ALU_A_out, ALU_B_out, ALUout;

    //Instruction from IR to be executed:

    //First 4 bits of instruction ommitted due to being OpCode.
    logic [11:0] IR;
    // assign WriteAddr = IR[3:0];
    // assign rdAddrA = IR[11:8];
    // assign rdAddrB = IR[7:4];
    assign {rdAddrA, rdAddrB, WriteAddr} = IR;
    //D_addr can be either IR[11:4] or IR[7:0]

    Datapath DUT(ALU_s0, D_addr, clk, rdAddrA, D_wr, RF_sel, WriteAddr, 
                rdAddrB, RF_W_en, ALU_A_out, ALU_B_out, ALUout);
    
    always begin //50 Mhz Clock
		clk = 0; #10;
		clk = 1; #10;
	end 

    //TODO 
        //DO we need to run the tests posted on classes
        //Why do we need to wait clock cycle to enable w_en

        //EDGE CASES: START AND END OF REG, START AND END OF DATA MEM?
        //CLEAR SIGNALS AFTER TESTING EVERY OP?
    
    initial begin
        //Init: PC_clr = 1, Fetch IR_Id = 1, PC_up = 1, Decode are 
        //Controller Unit states only.

        #5; 
        $monitor($time,,,,"SELECT SIGNALS | ALU Sel: %b | RF Sel: %b | D_wr: %b | RF_wrEn: %b",
                ALU_s0, RF_sel, D_wr, RF_W_en); 
        /**************LOAD INTO REG 1 A (First clock cycle)**************/
        $display($time,,"LOAD (A) 1111 in REG 1: ");
        RF_W_en = 1'b0;
        IR = 12'h011; // RF[01] = D[01]
        D_addr = IR[11:4];
        D_wr = 1'b0;
        //WriteAddr = IR[3:0];
        RF_sel = 1'b1;
        @(negedge clk) 
        $display($time,,,,"NEGCLK: Load into REG 1 A | IR: %b | DataToMux: %b | write: %b | wr data: %b",
                  IR, DUT.Data_to_Mux, DUT.RegUnit.write, DUT.RegUnit.wrData);      
        #5;
        //assert(DUT.RAMunit.address == 8'h03 && DUT.RAMunit.data == 4'b3333);

        /**************LOAD INTO REG 1 B (Second clock cycle)**************/
        //D_addr = IR[11:4];
        //WriteAddr = IR[3:0];
        $display($time,,"LOAD (B) 1111 in REG 1: ");
        RF_W_en = 1'b1;
        @(negedge clk)
        $display($time,,,,"NEGCLK: Load into REG 1 A | IR: %b | DataToMux: %b | write: %b | wr data: %b",
                  IR, DUT.Data_to_Mux, DUT.RegUnit.write, DUT.RegUnit.wrData);     
        assert(DUT.RegUnit.wrData == 16'h1111) $display($time,,,,"LOAD_1111 PASSED \n"); 
        #5;

        /**************STORE**************/
        $display($time,,"Store Operation ");
        IR = 12'h16A; //D[6A] = RF[01]
        D_addr = IR[7:0]; 
        RF_W_en = 1'b0;
        D_wr = 1'b1;
        //rdAddrA = IR[11:8];
        @(negedge clk)
        $display($time,,,,"NEGCLK: IR: %b | Wr Addr: %b ", IR, WriteAddr);     
        assert(DUT.Ra_data == 16'h1111 && DUT.D_addr == 8'h6A) $display($time,,,,"STORE PASSED \n");   
        #5;

        /**************LOAD INTO REG 2 A (First clock cycle)**************/
        $display($time,,"LOAD (A) 2222 in REG 2: ");
        RF_W_en = 1'b0;
        IR = 12'h022; // RF[02] = D[02]
        D_addr = IR[11:4];
        //WriteAddr = IR[3:0];
        RF_sel = 1'b1;
        D_wr = 1'b0;
        @(negedge clk)
        $display($time,,,,"NEGCLK: Load 2222 into REG 2 A | IR: %b | DataToMux: %b | write: %b | wr data: %b",
                  IR, DUT.Data_to_Mux, DUT.RegUnit.write, DUT.RegUnit.wrData);        
        #5;
        /**************LOAD INTO REG 2 B (Second clock cycle)**************/
        $display($time,,"LOAD (B) 2222 in REG 2: ");
        //D_addr = IR[11:4];
        //WriteAddr = IR[3:0];
        RF_W_en = 1'b1;
        @(negedge clk)
        $display($time,,,,"NEGCLK: IR: %b | DataToMux: %b | write: %b | wr data: %b",
                  IR, DUT.Data_to_Mux, DUT.RegUnit.write, DUT.RegUnit.wrData);   
        assert(DUT.RegUnit.wrData == 16'h2222) $display($time,,,,"LOAD_2222 PASSED \n");     
        #5; 

        /**************ADD 1**************/
        $display($time,,"Add 1 Operation ");
        IR = 12'h123; //Reg 3 = Reg 1 + Reg 2 
        ALU_s0 = 3'b001;
        RF_sel = 1'b0;
        RF_W_en = 1'b1;
        @(negedge clk)
        $display($time,,,,"NEGCLK: Add Operation: Wr Addr = %b | A Addr = %b | B Addr = %b",
                 WriteAddr, rdAddrA, rdAddrB); 
        assert(DUT.RegUnit.wrData == 16'h3333) $display($time,,,,"ADD 1 PASSED \n");
        #5; //Two clocks needed.

        /**************ADD 2**************/
        $display($time,,"Add 2 Operation ");
        IR = 12'h234; //Reg 4 = Reg 2 + Reg 3
        RF_W_en = 1'b1;
        @(negedge clk)
        $display($time,,,,"NEGCLK: Add Operation: Wr Addr = %b | A Addr = %b | B Addr = %b",
                 WriteAddr, rdAddrA, rdAddrB); 
        assert(DUT.RegUnit.wrData == 16'h5555) $display($time,,,,"ADD 2 PASSED \n");
        #5; //Two clocks needed.      

        /**************SUB 1**************/
        $display($time,,"Sub 1 Operation ");
        IR = 12'h210; //Reg 0 = Reg 2 - Reg 1? double check with order
        //WriteAddr = IR[3:0]; 
        //rdAddrA = IR[11:8];
        //rdAddrB = IR[7:4];
        RF_W_en = 1'b1;
        ALU_s0 = 3'b010;
        RF_sel = 1'b0;
        @(negedge clk)
        $display($time,,,,"NEGCLK: Sub Operation: Wr Addr = %b | A Addr = %b | B Addr = %b",
                 WriteAddr, rdAddrA, rdAddrB);
        //assert(Reg 0 = 2222 - 1111 = 1111)
        assert(DUT.RegUnit.wrData == 16'h1111) $display($time,,,,"SUB PASSED \n");      
        #5;

        /**************EDGE CASE A**************/
        $display($time,,"EDGE CASE LOAD Operation ");
        IR = 12'hFFF; // RF[F] = D[FF]
        RF_W_en = 1'b0;
        D_addr = IR[11:4];
        D_wr = 1'b0;
        //WriteAddr = IR[3:0];
        RF_sel = 1'b1;
        @(negedge clk) 
        $display($time,,,,"NEGCLK: Load into REG 1 A | IR: %b | DataToMux: %b | write: %b | wr data: %b",
                  IR, DUT.Data_to_Mux, DUT.RegUnit.write, DUT.RegUnit.wrData);      
        #5;
        //assert(DUT.RAMunit.address == 8'h03 && DUT.RAMunit.data == 4'b3333);

        /**************EDGE CASE B**************/
        //D_addr = IR[11:4];
        //WriteAddr = IR[3:0];
        RF_W_en = 1'b1;
        @(negedge clk)
        $display($time,,,,"NEGCLK: Load into REG 1 A | IR: %b | DataToMux: %b | write: %b | wr data: %b",
                  IR, DUT.Data_to_Mux, DUT.RegUnit.write, DUT.RegUnit.wrData);     
        assert(DUT.RegUnit.wrData == 16'hFFFF) $display($time,,,,"EDGE CASE LOAD PASSED \n"); 
        #5;

        /**************EDGE CASE STORE**************/
        $display($time,,"EDGE CASE Store Operation ");
        IR = 12'hFFE; //D[FE] = RF[F]
        D_addr = IR[7:0]; 
        RF_W_en = 1'b0;
        D_wr = 1'b1;
        //rdAddrA = IR[11:8];
        @(negedge clk)
        $display($time,,,,"NEGCLK: IR: %b | Wr Addr: %b ", IR, WriteAddr);     
        assert(DUT.Ra_data == 16'hFFFF && DUT.D_addr == 8'hFE) $display($time,,,,"EDGE CASE STORE PASSED \n");   
        #5;

        /**************NO-OP AND HALT**************/
        $display($time,,"NO-OP Operation ");
        ALU_s0 = 3'b000;
        D_wr = 1'b0;
        RF_sel = 1'b0;
        RF_W_en = 1'b0;
        @(negedge clk)
        $display($time,,,,"NEGCLK: IR: %b | Data Addr: %b | A Addr: %b",
                  IR, D_addr, rdAddrA);        
        #5;
        assert(DUT.RegUnit.wrData == 16'h0000 && RF_W_en == 1'b0);
        assert(DUT.Ra_data == 16'hFFFF && D_wr == 1'b0)
        $display($time,,,,"NO-OP PASSED");
        $stop;
    end
endmodule