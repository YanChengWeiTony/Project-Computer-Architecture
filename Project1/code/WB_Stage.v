module WB_Stage(

// From MEM/WB register
    RegWrite_i, 
    MemToReg_i, 

    ReadData_i,
    ALUdata_i,
    RegAddr_i,

// To register file in ID stage
    RegWrite_o,
    RegData_o,      // the data to be writen into the register file.
    RegAddr_o       // the register address for write-back
);


// Ports
input               RegWrite_i, MemToReg_i;
input   [31:0]      ReadData_i, ALUdata_i;
input   [4:0]       RegAddr_i;
output              RegWrite_o;
output  [4:0]       RegAddr_o;
output  [31:0]      RegData_o;

// Submodule
MUX2_32 MUX_ALUSrc(
    .data0_i    (ALUdata_i),
    .data1_i    (ReadData_i),
    .select_i   (MemToReg_i),
    .data_o     (RegData_o)
);


// Connection
assign  RegWrite_o = RegWrite_i;
assign  RegAddr_o  = RegAddr_i;


endmodule