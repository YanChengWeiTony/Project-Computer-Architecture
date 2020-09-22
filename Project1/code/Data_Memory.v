// Access code for data memory reading and writing from Control Unit
`define DMEM_NOAC   2'd0  // no access (NO ACcess)
`define DMEM_BYTE   2'd1  // byte access
`define DMEM_HALF   2'd2  // half word access
`define DMEM_WORD   2'd3  // word access


module Data_Memory(
	clk_i,
    addr_i,
    MemRead_i,
    MemWrite_i,
    WriteData_i,
    ReadData_o
);

// Ports
input 				clk_i;
input 	[31:0] 		addr_i, WriteData_i;
input   [1:0] 		MemRead_i, MemWrite_i;
output 	[31:0] 		ReadData_o;

// Data memory
reg     [7:0]		memory 	[0:31];

// Wires
wire 	[7:0] 		read_data 	[0:3];
wire 	[7:0] 		write_data 	[0:3];


// Connection
assign  ReadData_o	[31:24]	= read_data[3];
assign  ReadData_o	[23:16]	= read_data[2];
assign  ReadData_o	[15:8]	= read_data[1];
assign  ReadData_o	[7:0]	= read_data[0];

assign  write_data[3] = WriteData_i[31:24];
assign  write_data[2] = WriteData_i[23:16];
assign  write_data[1] = WriteData_i[15:8];
assign  write_data[0] = WriteData_i[7:0];


assign 	read_data[0] = (MemRead_i > `DMEM_NOAC) ? memory[addr_i  ] : 8'd0;
assign 	read_data[1] = (MemRead_i > `DMEM_BYTE) ? memory[addr_i+1] : 8'd0;
assign 	read_data[2] = (MemRead_i > `DMEM_HALF) ? memory[addr_i+2] : 8'd0;
assign 	read_data[3] = (MemRead_i > `DMEM_HALF) ? memory[addr_i+3] : 8'd0;

always @ (posedge clk_i) begin
	if (MemWrite_i > `DMEM_NOAC)
		memory[addr_i  ] <= write_data[0];
	if (MemWrite_i > `DMEM_BYTE)
		memory[addr_i+1] <= write_data[1];
	if (MemWrite_i > `DMEM_HALF) begin
		memory[addr_i+2] <= write_data[2];
		memory[addr_i+3] <= write_data[3];
	end
end

endmodule
