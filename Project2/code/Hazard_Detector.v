// Access code for data memory reading and writing from Control Unit
`define DMEM_NOAC   2'd0  // no access (NO ACcess)
`define DMEM_BYTE   2'd1  // byte access
`define DMEM_HALF   2'd2  // half word access
`define DMEM_WORD   2'd3  // word access

module Hazard_Detector(
	start_i,
	//from ID_Stage
	RSaddr_i,
	RTaddr_i,	

	//from EX_Stage
	EX_MemRead_i,
	EX_RTaddr_i,

	//To PC, IF Stage, and ID Stage
	Stall_o,
);

//Ports
input 		start_i;
input	[4:0]	RSaddr_i;
input	[4:0]	RTaddr_i;
input	[1
:0]	EX_MemRead_i;
input	[4:0]	EX_RTaddr_i;

output		Stall_o;

assign Stall_o = (EX_MemRead_i != `DMEM_NOAC && (EX_RTaddr_i == RSaddr_i || EX_RTaddr_i == RTaddr_i)) ? 1'b1 : 1'b0;

endmodule