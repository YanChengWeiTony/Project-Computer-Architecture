// Operation code for ALU_Control from Control Unit
`define INST_RTYPE  2'd1  // R-type
`define INST_ADDI   2'd2  // addi
`define INST_MEM    2'd3  // lw or sw         => ALU do adding
`define INST_REST   2'd0  // J-type or bubble => ALU do nothing

// Access code for data memory reading and writing from Control Unit
`define DMEM_NOAC   2'd0  // no access (NO ACcess)
`define DMEM_BYTE   2'd1  // byte access
`define DMEM_HALF   2'd2  // half word access
`define DMEM_WORD   2'd3  // word access

// Operation code for ALU_Control from Control Unit
`define OP_RTYPE	6'b000000
`define OP_ADDI		6'b001000
`define OP_LW		6'b100011
`define OP_SW		6'b101011
`define OP_BRANCH	6'b000100
`define OP_JUMP		6'b000010

module Control
(
	Op_i,
	Stall_i,
	Jump_o,
	Branch_o,
	RegWrite_o,
	MemToReg_o,
	MemRead_o,
	MemWrite_o,
	ALUOp_o,
	ALUSrc_o,
	RegDst_o
);

//Ports
input	[5:0]	Op_i;
input		Stall_i;
output		Jump_o;
output		Branch_o;
output		RegWrite_o;
output		MemToReg_o;
output	[1:0]	MemRead_o;
output	[1:0]	MemWrite_o;
output	[1:0]	ALUOp_o;
output		ALUSrc_o;
output		RegDst_o;

//if Stall, output nop(all zero)

assign Jump_o = (Stall_i == 1'b1) ? 1'b0: 
		(Op_i == `OP_JUMP) ? 1'b1 : 1'b0;

assign Branch_o = (Stall_i == 1'b1) ? 1'b0: 
		  (Op_i == `OP_BRANCH) ? 1'b1 : 1'b0;

assign RegWrite_o = (Stall_i == 1'b1) ? 1'b0: 
		    (Op_i == `OP_RTYPE || Op_i == `OP_ADDI || Op_i == `OP_LW) ? 1'b1 : 1'b0;

assign MemToReg_o = (Stall_i == 1'b1) ? 1'b0: 
		    (Op_i == `OP_LW) ? 1'b1 : 1'b0;

assign MemRead_o = (Stall_i == 1'b1) ? `DMEM_NOAC: 
		   (Op_i == `OP_LW) ? `DMEM_WORD : `DMEM_NOAC;
//there's no byte, haof-word accese instruction in this assignment.

assign MemWrite_o = (Stall_i == 1'b1) ? `DMEM_NOAC: 
		    (Op_i == `OP_SW) ? `DMEM_WORD : `DMEM_NOAC;
//there's no byte, haof-word acces instruction in this assignment.

assign ALUOp_o = (Stall_i == 1'b1) ? 2'b00: 
		 (Op_i == `OP_RTYPE) ? `INST_RTYPE :      		  // R type
				 (Op_i == `OP_ADDI)  ? `INST_ADDI :       		  // I type(addi)
				 (Op_i == `OP_LW || Op_i == `OP_SW) ? `INST_MEM : // lw, sw
				 `INST_REST;                              		  // else

assign ALUSrc_o = (Stall_i == 1'b1) ? 1'b0: 
		  (Op_i == `OP_ADDI|| Op_i == `OP_LW || Op_i == `OP_SW) ? 1'b1 : //addi, lw, sw
				  1'b0;

assign RegDst_o = (Stall_i == 1'b1) ? 1'b0: 
		  (Op_i == `OP_RTYPE) ? 1'b1 : 1'b0;



// old version
/*
assign Jump_o = (0) ? 1'b0: 
		(Op_i == `OP_JUMP) ? 1'b1 : 1'b0;

assign Branch_o = (0) ? 1'b0: 
		  (Op_i == `OP_BRANCH) ? 1'b1 : 1'b0;

assign RegWrite_o = (0) ? 1'b0: 
		    (Op_i == `OP_RTYPE || Op_i == `OP_ADDI || Op_i == `OP_LW) ? 1'b1 : 1'b0;

assign MemToReg_o = (0) ? 1'b0: 
		    (Op_i == `OP_LW) ? 1'b1 : 1'b0;

assign MemRead_o = (0) ? `DMEM_NOAC: 
		   (Op_i == `OP_LW) ? `DMEM_WORD : `DMEM_NOAC;
//there's no byte, haof-word accese instruction in this assignment.

assign MemWrite_o = (0) ? `DMEM_NOAC: 
		    (Op_i == `OP_SW) ? `DMEM_WORD : `DMEM_NOAC;
//there's no byte, haof-word acces instruction in this assignment.

assign ALUOp_o = (0) ? 2'b00: 
		 (Op_i == `OP_RTYPE) ? `INST_RTYPE :      		  // R type
				 (Op_i == `OP_ADDI)  ? `INST_ADDI :       		  // I type(addi)
				 (Op_i == `OP_LW || Op_i == `OP_SW) ? `INST_MEM : // lw, sw
				 `INST_REST;                              		  // else

assign ALUSrc_o = (0) ? 1'b0: 
		  (Op_i == `OP_ADDI|| Op_i == `OP_LW || Op_i == `OP_SW) ? 1'b1 : //addi, lw, sw
				  1'b0;

assign RegDst_o = (0) ? 1'b0: 
		  (Op_i == `OP_RTYPE) ? 1'b1 : 1'b0;
*/
endmodule						
