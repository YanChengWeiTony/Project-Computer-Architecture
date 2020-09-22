// Access code for data memory reading and writing from Control Unit
`define DMEM_NOAC   2'd0  // no access (NO ACcess)
`define DMEM_BYTE   2'd1  // byte access
`define DMEM_HALF   2'd2  // half word access
`define DMEM_WORD   2'd3  // word access


module MEM_Stage(
    clk_i,
    start_i,

// From EX/MEM register
    RegWrite_i,
    MemToReg_i, 
    MemRead_i,
    MemWrite_i,

    WriteData_i,    // the data for data memory writing
    ALUdata_i,
    RegAddr_i,

// To MEM/WB register
    RegWrite_o, 
    MemToReg_o, 

    ReadData_o,     // the data read from the data memory
    ALUdata_o,      // the result computed from ALU
    RegAddr_o       // the register address for write-back
);

// Ports
input               clk_i, start_i;
input               RegWrite_i, MemToReg_i;
input   [1:0]       MemRead_i, MemWrite_i;
input   [4:0]       RegAddr_i;
input   [31:0]      WriteData_i, ALUdata_i;

output              RegWrite_o, MemToReg_o;
output  [4:0]       RegAddr_o;
output  [31:0]      ReadData_o, ALUdata_o;

// Output regs
reg                 RegWrite_o, MemToReg_o;
reg     [4:0]       RegAddr_o;
reg     [31:0]      ReadData_o, ALUdata_o;

// Wires
wire                RegWrite_w, MemToReg_w;
wire    [4:0]       RegAddr_w;
wire    [31:0]      ReadData_w, ALUdata_w;

// Pass to next stage
assign  RegWrite_w = RegWrite_i;
assign  MemToReg_w = MemToReg_i;
assign  ALUdata_w  = ALUdata_i;
assign  RegAddr_w  = RegAddr_i;

// Pass to stage register
always@(posedge clk_i or negedge start_i) begin
    if(~start_i) begin
        RegWrite_o  <= 1'd0;
        MemToReg_o  <= 1'd0;

        RegAddr_o   <= 5'd0;
        ReadData_o  <= 32'd0;
        ALUdata_o   <= 32'd0;
    end
    else begin
        RegWrite_o  <= RegWrite_w;
        MemToReg_o  <= MemToReg_w;
        RegAddr_o   <= RegAddr_w;
        ReadData_o  <= ReadData_w;
        ALUdata_o   <= ALUdata_w;
    end
end


// Submodule
Data_Memory Data_Memory(
    .clk_i      (clk_i),
    .addr_i     (ALUdata_i),
    .MemRead_i  (MemRead_i),
    .MemWrite_i (MemWrite_i),
    .WriteData_i(WriteData_i),
    .ReadData_o (ReadData_w)
);



endmodule