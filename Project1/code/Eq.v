module Eq(
	data0_i,
	data1_i,
	eq_o
);

input	[31:0]	data0_i;
input	[31:0]	data1_i;
output		eq_o;

assign eq_o = (data0_i == data1_i) ? 1'b1 : 1'b0;

endmodule	
