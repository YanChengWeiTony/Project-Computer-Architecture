module IF_Stage(
    clk_i, 
    rst_i,
    start_i,
    pc_i,

    Stall_i,
    mem_stall_i,
    Jump_i,         // Jump signal
    Branch_i,       // Branch signal
    Eq_i,           // Condition: Equal
    JumpPC_i,       // Jump to this PC value
    BranchPC_i,     // Branch to this PC value

    pc_add_o,       // for PC
    pc_o,           // for IF/ID stage
    inst_o
);

// Ports
input               clk_i, rst_i, start_i, Stall_i, mem_stall_i;
input				Jump_i, Branch_i, Eq_i;
input   [31:0]      pc_i, JumpPC_i, BranchPC_i;	
output  [31:0]      pc_add_o;		
output  [31:0]      pc_o;
output  [31:0]      inst_o;

// Output regs
reg     [31:0]      pc_o, inst_o;

// Wires
wire 				branch, flush;
wire 	[31:0] 		pc_add4, pc_mux_branch;
wire    [31:0]      pc_w, inst_w;

// Connection
assign branch   = Branch_i & Eq_i;
assign pc_add_o = pc_w;
assign flush    = branch | Jump_i;

// Pass to stage register
always@(posedge clk_i or negedge rst_i) begin
    if(~rst_i || flush) begin
        pc_o   <= 32'd0;
        inst_o <= 32'd0;
    end
    else if (start_i && ~Stall_i && ~mem_stall_i) begin
        pc_o   <= pc_add4;
        inst_o <= inst_w;
    end
end


// Submodules
Adder Add_PC(
    .data0_i    (pc_i),
    .data1_i    (32'd4),
    .data_o     (pc_add4)
);

MUX2_32 MUX_Branch(
	.data0_i	(pc_add4),
	.data1_i	(BranchPC_i),
	.select_i	(branch),
	.data_o		(pc_mux_branch)
);

MUX2_32 MUX_Jump(
	.data0_i	(pc_mux_branch),
	.data1_i	(JumpPC_i),
	.select_i	(Jump_i),
	.data_o		(pc_w)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (pc_i),
    .data_o     (inst_w)
);

endmodule
