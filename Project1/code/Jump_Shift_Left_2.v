module Jump_Shift_Left_2(
	data_i,
	data_mux_i,//from mux(PC + 4, Branch), largest 4 bit only;
	data_o
);

input	[25:0]	data_i;
input	[3:0]	data_mux_i;
output	[31:0]	data_o;

reg	[27:0]	temp;

always @(*) begin
	temp = (data_i << 2);
end

assign  data_o = {data_mux_i, temp};

endmodule
