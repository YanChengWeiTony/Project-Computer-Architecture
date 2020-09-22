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


module ID_Stage(
    clk_i,
    rst_i,
    start_i,
    Stall_i,
    mem_stall_i,

// From IF/ID register
    pc_i,
    inst_i,

// From WB stage
    RegWrite_i,
    RegData_i,
    RegAddr_i,

// To IF stage
    Jump_o,         // Jump signal
    Branch_o,       // Branch signal
    Eq_o,           // Condition: Equal

    JumpPC_o,       // Jump to this PC value
    BranchPC_o,     // Branch to this PC value

// To ID/EX register
    // Control signals
    RegWrite_o,     // write back to the register file or not
    MemToReg_o,     // write back to the register file from data memory or not   
    MemRead_o,      // read data memory or not
    MemWrite_o,     // write data memory or not
    ALUOp_o,        // operation code for ALU_Control
    ALUSrc_o,       // the second input of ALU is RT or immediate value
    RegDst_o,       // write back to RT or RD in the register file

    // Instructions fields
    RSaddr_o,       // RS address in the instruction
    RTaddr_o,       // RT address in the instruction
    RDaddr_o,       // RD address in the instruction
    Funct_o,        // function code in the instruction

    // Data
    RSdata_o,       // the data stored in RS register
    RTdata_o,       // the data stored in RT register
    ExtImmd_o       // Extended immediate value
);

// Ports
input               clk_i, rst_i, start_i, Stall_i, mem_stall_i;
input   [31:0]      pc_i, inst_i;
input               RegWrite_i;
input   [4:0]       RegAddr_i;
input   [31:0]      RegData_i;

output              Jump_o, Branch_o, Eq_o;
output   [31:0]     JumpPC_o, BranchPC_o;
output              RegWrite_o, MemToReg_o, ALUSrc_o, RegDst_o;
output   [1:0]      MemRead_o, MemWrite_o, ALUOp_o;
output   [4:0]      RSaddr_o, RTaddr_o, RDaddr_o;
output   [5:0]      Funct_o;
output   [31:0]     RSdata_o, RTdata_o, ExtImmd_o;

// Output regs
reg                 RegWrite_o, MemToReg_o, ALUSrc_o, RegDst_o;
reg      [1:0]      MemRead_o, MemWrite_o, ALUOp_o;
reg      [4:0]      RSaddr_o, RTaddr_o, RDaddr_o;
reg      [5:0]      Funct_o;
reg      [31:0]     RSdata_o, RTdata_o, ExtImmd_o;

// Wires
wire	 [31:0]	    Add_Branch_0;

wire                Jump_w, Branch_w, Eq_w;
wire     [31:0]     JumpPC_w, BranchPC_w;
wire                RegWrite_w, MemToReg_w, ALUSrc_w, RegDst_w;
wire     [1:0]      MemRead_w, MemWrite_w, ALUOp_w;
wire     [4:0]      RSaddr_w, RTaddr_w, RDaddr_w;
wire     [5:0]      Funct_w;
wire     [31:0]     RSdata_w, RTdata_w, ExtImmd_w;

// Pass to next stage
assign  RSaddr_w = inst_i[25:21];
assign  RTaddr_w = inst_i[20:16];
assign  RDaddr_w = inst_i[15:11];
assign  Funct_w  = inst_i[5:0];

// Pass to stage register
always@(posedge clk_i or negedge rst_i) begin
    if(~rst_i) begin
        RegWrite_o  <= 1'd0;
        MemToReg_o  <= 1'd0;
        ALUSrc_o    <= 1'd0;
        RegDst_o    <= 1'd0;
        MemRead_o   <= 2'd0;
        MemWrite_o  <= 2'd0;
        ALUOp_o     <= 2'd0;
        RSaddr_o    <= 5'd0;
        RTaddr_o    <= 5'd0;
        RDaddr_o    <= 5'd0;
        Funct_o     <= 6'd0;
        RSdata_o    <= 32'd0;
        RTdata_o    <= 32'd0;
        ExtImmd_o   <= 32'd0;
    end
    else if (start_i && ~mem_stall_i) begin
        RegWrite_o  <= RegWrite_w;
        MemToReg_o  <= MemToReg_w;
        ALUSrc_o    <= ALUSrc_w;
        RegDst_o    <= RegDst_w;
        MemRead_o   <= MemRead_w;
        MemWrite_o  <= MemWrite_w;
        ALUOp_o     <= ALUOp_w;
        RSaddr_o    <= RSaddr_w;
        RTaddr_o    <= RTaddr_w;
        RDaddr_o    <= RDaddr_w;
        Funct_o     <= Funct_w;
        RSdata_o    <= RSdata_w;
        RTdata_o    <= RTdata_w;
        ExtImmd_o   <= ExtImmd_w;
    end
end


Control Control(
    .Op_i       (inst_i[31:26]),
    .Stall_i    (Stall_i),
    .Jump_o     (Jump_o),
    .Branch_o   (Branch_o),
    .RegWrite_o (RegWrite_w),
    .MemToReg_o (MemToReg_w),
    .MemRead_o  (MemRead_w),
    .MemWrite_o (MemWrite_w),
    .ALUOp_o    (ALUOp_w),
    .ALUSrc_o   (ALUSrc_w),
    .RegDst_o   (RegDst_w)
);

Register Registers(
    .clk_i      (clk_i),
    .RSaddr_i   (inst_i[25:21]),
    .RTaddr_i   (inst_i[20:16]),
    .RDaddr_i   (RegAddr_i), 
    .RDdata_i   (RegData_i),
    .RegWrite_i (RegWrite_i), // signal from write back stage
    .RSdata_o   (RSdata_w), 
    .RTdata_o   (RTdata_w) 
);

Sign_Extend Sign_Extend(
    .data_i     (inst_i[15:0]),
    .data_o     (ExtImmd_w)
);

Jump_Shift_Left_2 Jump_Shift_Left_2(
	.data_i     (inst_i[25:0]),
	.data_mux_i (pc_i[31:28]),
    .data_o     (JumpPC_o)
);

Branch_Shift_Left_2 Branch_Shift_Left_2(
    .data_i     (ExtImmd_w),
    .data_o     (Add_Branch_0)
);

Adder Add_Addr(
    .data0_i    (Add_Branch_0),
    .data1_i    (pc_i),
    .data_o     (BranchPC_o)
);

Eq Eq(
	.data0_i    (RSdata_w),
	.data1_i    (RTdata_w),
	.eq_o       (Eq_o)
);

endmodule
