module PC
(
    clk_i,
    start_i,
    Stall_i,
    pc_i,
    pc_o
);

// Ports
input               clk_i;
input               start_i;
input               Stall_i;
input   [31:0]      pc_i;
output  [31:0]      pc_o;

// Wires & Registers
reg     [31:0]      pc_o;  // Output as register.


always@(posedge clk_i or negedge start_i) begin
    if(~start_i)
        pc_o <= 32'b0;
    else begin
    	if (~Stall_i)
        	pc_o <= pc_i;
    end
end

endmodule