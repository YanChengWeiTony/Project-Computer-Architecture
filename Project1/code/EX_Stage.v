// Operation code for ALU_Control from Control Unit
`define INST_RTYPE  2'd1  // R-type
`define INST_ADDI   2'd2  // addi
`define INST_MEM    2'd3  // lw or sw         => ALU do adding
`define INST_REST   2'd0  // J-type or bubble => ALU do nothing


module EX_Stage(
    clk_i, 
    start_i,

// From ID/EX register
    RegWrite_i,
    MemToReg_i,
    MemRead_i,
    MemWrite_i,
    ALUOp_i,
    ALUSrc_i,
    RegDst_i,

    RSaddr_i,
    RTaddr_i,
    RDaddr_i,
    Funct_i,

    RSdata_i,
    RTdata_i,
    ExtImmd_i,

//From Forwarding Unit
    RSdatasrc_i,
    RTdatasrc_i,

//From other stages, used for forwarding
    MEM_ALU_result_i,//EX/MEM register ALUdata
    WB_RegData_i,//same name

// To EX/MEM register
    RegWrite_o,
    MemToReg_o,
    MemRead_o,
    MemWrite_o,

    WriteData_o,    // the data for data memory writing
    ALUdata_o,      // the result computed from ALU, could be the address of data memory
    RegAddr_o       // the register address for write-back
);

// Ports
input               clk_i, start_i;
input               RegWrite_i, MemToReg_i, ALUSrc_i, RegDst_i;
input   [1:0]       MemRead_i, MemWrite_i, ALUOp_i;
input   [4:0]       RSaddr_i, RTaddr_i, RDaddr_i;
input   [5:0]       Funct_i;
input   [31:0]      RSdata_i, RTdata_i, ExtImmd_i;

input   [1:0]       RSdatasrc_i, RTdatasrc_i;
input   [31:0]      MEM_ALU_result_i, WB_RegData_i;

output              RegWrite_o, MemToReg_o;
output  [1:0]       MemRead_o, MemWrite_o;
output  [4:0]       RegAddr_o;
output  [31:0]      WriteData_o, ALUdata_o;

// Output regs
reg                 RegWrite_o, MemToReg_o;
reg     [1:0]       MemRead_o, MemWrite_o;
reg     [4:0]       RegAddr_o;
reg     [31:0]      WriteData_o, ALUdata_o;

// Wires
wire    [2:0]       ALU_mode;
wire    [31:0]      ALU_operand1;
wire    [31:0]      ALU_operand2;
wire    [31:0]      RT_Fwd;

wire                RegWrite_w, MemToReg_w;
wire    [1:0]       MemRead_w, MemWrite_w;
wire    [4:0]       RegAddr_w;
wire    [31:0]      WriteData_w, ALUdata_w;

// Pass to next stage
assign RegWrite_w  = RegWrite_i;
assign MemToReg_w  = MemToReg_i;
assign MemRead_w   = MemRead_i;
assign MemWrite_w  = MemWrite_i;
assign WriteData_w = RT_Fwd;   //need to change

// Pass to stage register
always@(posedge clk_i or negedge start_i) begin
    if(~start_i) begin
        RegWrite_o  <= 1'd0;
        MemToReg_o  <= 1'd0;
        MemRead_o   <= 2'd0;
        MemWrite_o  <= 2'd0;
        RegAddr_o   <= 5'd0;
        WriteData_o <= 32'd0;
        ALUdata_o   <= 32'd0;
    end
    else begin
        RegWrite_o  <= RegWrite_w;
        MemToReg_o  <= MemToReg_w;
        MemRead_o   <= MemRead_w;
        MemWrite_o  <= MemWrite_w;
        RegAddr_o   <= RegAddr_w;
        WriteData_o <= WriteData_w;
        ALUdata_o   <= ALUdata_w;
    end
end


MUX2_5 MUX_RegDst(
    .data0_i    (RTaddr_i),
    .data1_i    (RDaddr_i),
    .select_i   (RegDst_i),
    .data_o     (RegAddr_w)
);

MUX2_32 MUX_ALUSrc(
    .data0_i    (RT_Fwd),
    .data1_i    (ExtImmd_i),
    .select_i   (ALUSrc_i),
    .data_o     (ALU_operand2)
);


MUX4_32 MUX_RSsrc(
    .data0_i    (RSdata_i),
    .data1_i    (WB_RegData_i),
    .data2_i    (MEM_ALU_result_i),
    .data3_i    (32'b0),
    .select_i   (RSdatasrc_i),
    .data_o     (ALU_operand1)
);


MUX4_32 MUX_RTsrc(
    .data0_i    (RTdata_i),
    .data1_i    (WB_RegData_i),
    .data2_i    (MEM_ALU_result_i),
    .data3_i    (32'b0),
    .select_i   (RTdatasrc_i),
    .data_o     (RT_Fwd)
);


ALU_Control ALU_Control(
    .funct_i    (Funct_i),
    .ALUOp_i    (ALUOp_i),
    .ALUCtrl_o  (ALU_mode)
);

ALU ALU(
    .data0_i    (ALU_operand1),
    .data1_i    (ALU_operand2),
    .ALUCtrl_i  (ALU_mode),
    .data_o     (ALUdata_w)
);

endmodule
