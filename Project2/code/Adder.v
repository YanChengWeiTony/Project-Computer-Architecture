module Adder
(
	data0_i,
	data1_i,
	data_o
);

input	[31:0]	data0_i, data1_i;
output	[31:0]	data_o;

assign	data_o = data0_i + data1_i;

endmodule 