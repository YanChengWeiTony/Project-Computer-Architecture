// Operation code for ALU_Control from Control Unit
`define INST_RTYPE  2'd1  // R-type
`define INST_ADDI   2'd2  // addi
`define INST_MEM    2'd3  // lw or sw         => ALU do adding
`define INST_REST   2'd0  // J-type or bubble => ALU do nothing

module ALU_Control
(
	funct_i,
	ALUOp_i,
	ALUCtrl_o
);

input	[5:0]	funct_i;
input	[1:0]	ALUOp_i;
output	[2:0]	ALUCtrl_o;

reg	ALUCtrl_o;

/*
000 = and
001 = or
010 = add
110 = sub

011 = mul
*/

always@(*) begin

if(ALUOp_i == 2'd1) begin //R-type
	if(funct_i == 6'b100000)
		ALUCtrl_o = 3'b010;
	else if(funct_i == 6'b100010)
		ALUCtrl_o = 3'b110;
	else if(funct_i == 6'b100100)
		ALUCtrl_o = 3'b000;
	else if(funct_i == 6'b100101)
		ALUCtrl_o = 3'b001;
	else if(funct_i == 6'b011000)
		ALUCtrl_o = 3'b011;
end
else if(ALUOp_i == 2'd2) //I-type(add)
	ALUCtrl_o = 3'b010;
else if(ALUOp_i == 2'd3) //lw, sw(add)
	ALUCtrl_o = 3'b010;
else if(ALUOp_i == 2'd0) //J-type(do nothing, default to "and")
	ALUCtrl_o = 3'b000;

end

endmodule
