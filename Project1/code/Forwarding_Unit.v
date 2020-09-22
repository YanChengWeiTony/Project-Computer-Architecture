module Forwarding_Unit
(
	ID_EX_RSaddr_i,//wire from ID to EX
	ID_EX_RTaddr_i,
	EX_MEM_RegWrite_i,
	EX_MEM_RegAddr_i,
	MEM_WB_RegWrite_i,
	MEM_WB_RegAddr_i,
	RSdatasrc_o,
	RTdatasrc_o
);

input	[4:0]	ID_EX_RSaddr_i;
input	[4:0]	ID_EX_RTaddr_i;
input			EX_MEM_RegWrite_i;
input	[4:0]	EX_MEM_RegAddr_i;
input			MEM_WB_RegWrite_i;
input	[4:0]	MEM_WB_RegAddr_i;
output	[1:0]	RSdatasrc_o;
output	[1:0]	RTdatasrc_o;

reg	    [1:0]   RSdatasrc_o;
reg	    [1:0]   RTdatasrc_o;

always@(*) begin

if(EX_MEM_RegWrite_i && EX_MEM_RegAddr_i != 5'd0 && EX_MEM_RegAddr_i == ID_EX_RSaddr_i)
	RSdatasrc_o = 2'b10;
else if(MEM_WB_RegWrite_i && MEM_WB_RegAddr_i != 5'd0 && MEM_WB_RegAddr_i == ID_EX_RSaddr_i && EX_MEM_RegAddr_i != ID_EX_RSaddr_i)
	RSdatasrc_o = 2'b01;
else
	RSdatasrc_o = 2'b00;


if(EX_MEM_RegWrite_i && EX_MEM_RegAddr_i != 5'd0 && EX_MEM_RegAddr_i == ID_EX_RTaddr_i)
	RTdatasrc_o = 2'b10;
else if(MEM_WB_RegWrite_i && MEM_WB_RegAddr_i != 5'd0 && MEM_WB_RegAddr_i == ID_EX_RTaddr_i && EX_MEM_RegAddr_i != ID_EX_RTaddr_i)
	RTdatasrc_o = 2'b01;
else
	RTdatasrc_o = 2'b00;

end

endmodule