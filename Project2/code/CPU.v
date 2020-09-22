/** CPU
 *  The top module of this project.
 *  
 *  Submodules:
 *      - PC             : Program counter.
 *      - *_Stage        : Pipe-lining stages. (IF -> ID -> EX -> MEM -> WB)
 *      - Hazard_Detector: (To be added...)
 *      - Forwarding_Unit: (To be added...)
 *  
 *  Ports:
 *      See the definitions in each *.v files (especially ID_Stage.v).
 */
module CPU
(
    clk_i,
    rst_i,
    start_i,

    mem_data_i,
    mem_ack_i,
    mem_data_o,
    mem_addr_o,
    mem_enable_o,
    mem_write_o
);

// Ports
input               clk_i;
input               rst_i;
input               start_i;

input   [256-1:0]   mem_data_i; 
input               mem_ack_i;    
output  [256-1:0]   mem_data_o; 
output  [32-1:0]    mem_addr_o;   
output              mem_enable_o; 
output              mem_write_o; 

// Wires from PC
wire    [31:0]  add_pc, inst_addr;

// Wires from IF 
wire    [31:0]  IF_add_pc, IF_inst_addr;

// Wires from ID
wire            ID_jump, ID_branch, ID_eq;
wire    [31:0]  ID_jump_pc, ID_branch_pc;

wire            ID_RegWrite, ID_MemToReg, ID_ALUSrc, ID_RegDst;
wire    [1:0]   ID_MemRead, ID_MemWrite, ID_ALUOp;
wire    [4:0]   ID_RSaddr, ID_RTaddr, ID_RDaddr;
wire    [5:0]   ID_funct;
wire    [31:0]  ID_RSdata, ID_RTdata, ID_ExtImmd;

// Wires from EX
wire            EX_RegWrite, EX_MemToReg;
wire    [1:0]   EX_MemRead, EX_MemWrite;
wire    [4:0]   EX_RegAddr;
wire    [31:0]  EX_WriteData, EX_ALUdata;

// Wires from MEM
wire            MEM_RegWrite, MEM_MemToReg, MEM_Stall;
wire    [4:0]   MEM_RegAddr;
wire    [31:0]  MEM_ReadData, MEM_ALUdata;

// Wires from WB
wire            WB_RegWrite;
wire    [4:0]   WB_RegAddr;
wire    [31:0]  WB_RegData;

// Wires from Hazard_Detector
wire            Stall;

// Wires from Forwarding Unit
wire    [1:0]   RSdatasrc, RTdatasrc;


PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .stall_i    (Stall),
    .mem_stall_i(MEM_Stall),
    .pc_i       (add_pc),
    .pc_o       (inst_addr)
);


IF_Stage IF_Stage(
    .clk_i      (clk_i), 
    .rst_i      (rst_i),
    .start_i    (start_i),
    .pc_i       (inst_addr),

    .Stall_i    (Stall),
    .mem_stall_i(MEM_Stall),
    .Jump_i     (ID_jump),     
    .Branch_i   (ID_branch),       
    .Eq_i       (ID_eq),           
    .JumpPC_i   (ID_jump_pc),       
    .BranchPC_i (ID_branch_pc),    

    .pc_add_o   (add_pc),
    .pc_o		(IF_add_pc),
    .inst_o		(IF_inst_addr)
);


ID_Stage ID_Stage(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .Stall_i    (Stall),
    .mem_stall_i(MEM_Stall),

    // From IF/ID register
    .pc_i       (IF_add_pc),
    .inst_i     (IF_inst_addr),

    // From WB stage
    .RegWrite_i (WB_RegWrite),
    .RegData_i  (WB_RegData),
    .RegAddr_i  (WB_RegAddr),

    // To IF stage
    .Jump_o     (ID_jump),   
    .Branch_o   (ID_branch),
    .Eq_o       (ID_eq),    

    .JumpPC_o   (ID_jump_pc),   
    .BranchPC_o (ID_branch_pc),

    // To ID/EX register
    // Control signals
    .RegWrite_o (ID_RegWrite),
    .MemToReg_o (ID_MemToReg),
    .MemRead_o  (ID_MemRead),
    .MemWrite_o (ID_MemWrite),
    .ALUOp_o    (ID_ALUOp),
    .ALUSrc_o   (ID_ALUSrc),
    .RegDst_o   (ID_RegDst),

    // Instructions fields
    .RSaddr_o	(ID_RSaddr),
    .RTaddr_o	(ID_RTaddr),
    .RDaddr_o	(ID_RDaddr),
    .Funct_o	(ID_funct),

    // Data
    .RSdata_o	(ID_RSdata),
    .RTdata_o	(ID_RTdata),
    .ExtImmd_o	(ID_ExtImmd)
);


EX_Stage EX_Stage(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .mem_stall_i(MEM_Stall),

    // From ID/EX register
    .RegWrite_i (ID_RegWrite),
    .MemToReg_i (ID_MemToReg),
    .MemRead_i  (ID_MemRead),
    .MemWrite_i (ID_MemWrite),
    .ALUOp_i    (ID_ALUOp),
    .ALUSrc_i   (ID_ALUSrc),
    .RegDst_i   (ID_RegDst),

    .RSaddr_i	(ID_RSaddr),
    .RTaddr_i	(ID_RTaddr),
    .RDaddr_i	(ID_RDaddr),
    .Funct_i	(ID_funct),
    .RSdata_i	(ID_RSdata),
    .RTdata_i	(ID_RTdata),
    .ExtImmd_i	(ID_ExtImmd),

    //From Forwarding Unit
    .RSdatasrc_i    (RSdatasrc),
    .RTdatasrc_i    (RTdatasrc),

    //From other stages, used for forwarding
    .MEM_ALU_result_i (EX_ALUdata), //EX/MEM register ALUdata
    .WB_RegData_i     (WB_RegData), //same name

    // To EX/MEM register
    .RegWrite_o	(EX_RegWrite),
    .MemToReg_o (EX_MemToReg),
    .MemRead_o	(EX_MemRead),
    .MemWrite_o	(EX_MemWrite),

    .WriteData_o(EX_WriteData),
    .ALUdata_o	(EX_ALUdata),
    .RegAddr_o  (EX_RegAddr)
);


MEM_Stage MEM_Stage(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),

    // From EX/MEM register
	.RegWrite_i	(EX_RegWrite),
    .MemToReg_i	(EX_MemToReg), 
    .MemRead_i	(EX_MemRead),
    .MemWrite_i	(EX_MemWrite),

    .WriteData_i(EX_WriteData),
    .ALUdata_i	(EX_ALUdata),
    .RegAddr_i	(EX_RegAddr),

    // To MEM/WB register
    .RegWrite_o	(MEM_RegWrite), 
    .MemToReg_o (MEM_MemToReg), 

    .ReadData_o (MEM_ReadData),
    .ALUdata_o	(MEM_ALUdata),
    .RegAddr_o  (MEM_RegAddr),

    // To all other stage register
    .mem_stall_o(MEM_Stall),

    // From Data Memory
    .mem_data_i     (mem_data_i),
    .mem_ack_i      (mem_ack_i),

    // To Data Memory
    .mem_data_o     (mem_data_o), 
    .mem_addr_o     (mem_addr_o),     
    .mem_enable_o   (mem_enable_o), 
    .mem_write_o    (mem_write_o)
);


WB_Stage WB_Stage(

    // From MEM/WB register
	.RegWrite_i (MEM_RegWrite), 
    .MemToReg_i (MEM_MemToReg), 

    .ReadData_i (MEM_ReadData),
    .ALUdata_i  (MEM_ALUdata),
    .RegAddr_i  (MEM_RegAddr),

    // To register file in ID stage
    .RegWrite_o (WB_RegWrite),
    .RegData_o  (WB_RegData),
    .RegAddr_o  (WB_RegAddr)
);


Hazard_Detector Hazard_Detector(
    .start_i    (start_i),
    .RSaddr_i   (IF_inst_addr[25:21]),
    .RTaddr_i   (IF_inst_addr[20:16]),
    .EX_MemRead_i   (ID_MemRead),
    .EX_RTaddr_i    (ID_RTaddr),
    .Stall_o    (Stall)
);


Forwarding_Unit Forwarding_Unit(
    .ID_EX_RSaddr_i     (ID_RSaddr),   //wire from ID to EX
    .ID_EX_RTaddr_i     (ID_RTaddr),
    .EX_MEM_RegWrite_i  (EX_RegWrite),
    .EX_MEM_RegAddr_i   (EX_RegAddr),
    .MEM_WB_RegWrite_i  (MEM_RegWrite),
    .MEM_WB_RegAddr_i   (MEM_RegAddr),
    .RSdatasrc_o        (RSdatasrc),
    .RTdatasrc_o        (RTdatasrc)
);


endmodule
