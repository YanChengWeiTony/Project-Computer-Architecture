`define CYCLE_TIME 50            

module TestBench;

reg                Clk;
reg                Start;
integer            i, outfile, counter;
integer            stall, flush;

always #(`CYCLE_TIME/2) Clk = ~Clk;    

CPU CPU(
    .clk_i  (Clk),
    .start_i(Start)
);
  
initial begin
    counter = 0;
    stall = 0;
    flush = 0;
    
    // initialize instruction memory
    for(i=0; i<256; i=i+1) begin
        CPU.IF_Stage.Instruction_Memory.memory[i] = 32'b0;
    end
    
    // initialize data memory
    for(i=0; i<32; i=i+1) begin
        CPU.MEM_Stage.Data_Memory.memory[i] = 8'b0;
    end    
       
    // initialize Register File
    for(i=0; i<32; i=i+1) begin
        CPU.ID_Stage.Registers.register[i] = 32'b0;
    end
    
    // Load instructions into instruction memory
    $readmemb("Fibonacci_instruction.txt", CPU.IF_Stage.Instruction_Memory.memory);
    

    // Open output file
    outfile = $fopen("output.txt") | 1;
    
    
    // Set Input n into data memory at 0x00
    CPU.MEM_Stage.Data_Memory.memory[0] = 8'h5;       // n = 5 for example
    

    Clk = 1;
    //Reset = 0;
    Start = 0;
    
    #(`CYCLE_TIME/4) 
    //Reset = 1;
    Start = 1;
        
    
end
  
always@(posedge Clk) begin
    if(counter == 70)    // stop after 60 cycles
        $stop;

    // put in your own signal to count stall and flush
    if(CPU.Hazard_Detector.Stall_o == 1)stall = stall + 1;
    if(CPU.IF_Stage.flush == 1)flush = flush + 1;  

    // print PC
    $fdisplay(outfile, "cycle = %d, Start = %d, Stall = %d, Flush = %d\nPC = %d", counter, Start, stall, flush, CPU.PC.pc_o);

    // print Registers
    $fdisplay(outfile, "Registers");
    $fdisplay(outfile, "R0(r0) = %d, R8 (t0) = %d, R16(s0) = %d, R24(t8) = %d", CPU.ID_Stage.Registers.register[0], CPU.ID_Stage.Registers.register[8] , CPU.ID_Stage.Registers.register[16], CPU.ID_Stage.Registers.register[24]);
    $fdisplay(outfile, "R1(at) = %d, R9 (t1) = %d, R17(s1) = %d, R25(t9) = %d", CPU.ID_Stage.Registers.register[1], CPU.ID_Stage.Registers.register[9] , CPU.ID_Stage.Registers.register[17], CPU.ID_Stage.Registers.register[25]);
    $fdisplay(outfile, "R2(v0) = %d, R10(t2) = %d, R18(s2) = %d, R26(k0) = %d", CPU.ID_Stage.Registers.register[2], CPU.ID_Stage.Registers.register[10], CPU.ID_Stage.Registers.register[18], CPU.ID_Stage.Registers.register[26]);
    $fdisplay(outfile, "R3(v1) = %d, R11(t3) = %d, R19(s3) = %d, R27(k1) = %d", CPU.ID_Stage.Registers.register[3], CPU.ID_Stage.Registers.register[11], CPU.ID_Stage.Registers.register[19], CPU.ID_Stage.Registers.register[27]);
    $fdisplay(outfile, "R4(a0) = %d, R12(t4) = %d, R20(s4) = %d, R28(gp) = %d", CPU.ID_Stage.Registers.register[4], CPU.ID_Stage.Registers.register[12], CPU.ID_Stage.Registers.register[20], CPU.ID_Stage.Registers.register[28]);
    $fdisplay(outfile, "R5(a1) = %d, R13(t5) = %d, R21(s5) = %d, R29(sp) = %d", CPU.ID_Stage.Registers.register[5], CPU.ID_Stage.Registers.register[13], CPU.ID_Stage.Registers.register[21], CPU.ID_Stage.Registers.register[29]);
    $fdisplay(outfile, "R6(a2) = %d, R14(t6) = %d, R22(s6) = %d, R30(s8) = %d", CPU.ID_Stage.Registers.register[6], CPU.ID_Stage.Registers.register[14], CPU.ID_Stage.Registers.register[22], CPU.ID_Stage.Registers.register[30]);
    $fdisplay(outfile, "R7(a3) = %d, R15(t7) = %d, R23(s7) = %d, R31(ra) = %d", CPU.ID_Stage.Registers.register[7], CPU.ID_Stage.Registers.register[15], CPU.ID_Stage.Registers.register[23], CPU.ID_Stage.Registers.register[31]);

    // print Data Memory
    $fdisplay(outfile, "Data Memory: 0x00 = %d", {CPU.MEM_Stage.Data_Memory.memory[3] , CPU.MEM_Stage.Data_Memory.memory[2] , CPU.MEM_Stage.Data_Memory.memory[1] , CPU.MEM_Stage.Data_Memory.memory[0] });
    $fdisplay(outfile, "Data Memory: 0x04 = %d", {CPU.MEM_Stage.Data_Memory.memory[7] , CPU.MEM_Stage.Data_Memory.memory[6] , CPU.MEM_Stage.Data_Memory.memory[5] , CPU.MEM_Stage.Data_Memory.memory[4] });
    $fdisplay(outfile, "Data Memory: 0x08 = %d", {CPU.MEM_Stage.Data_Memory.memory[11], CPU.MEM_Stage.Data_Memory.memory[10], CPU.MEM_Stage.Data_Memory.memory[9] , CPU.MEM_Stage.Data_Memory.memory[8] });
    $fdisplay(outfile, "Data Memory: 0x0c = %d", {CPU.MEM_Stage.Data_Memory.memory[15], CPU.MEM_Stage.Data_Memory.memory[14], CPU.MEM_Stage.Data_Memory.memory[13], CPU.MEM_Stage.Data_Memory.memory[12]});
    $fdisplay(outfile, "Data Memory: 0x10 = %d", {CPU.MEM_Stage.Data_Memory.memory[19], CPU.MEM_Stage.Data_Memory.memory[18], CPU.MEM_Stage.Data_Memory.memory[17], CPU.MEM_Stage.Data_Memory.memory[16]});
    $fdisplay(outfile, "Data Memory: 0x14 = %d", {CPU.MEM_Stage.Data_Memory.memory[23], CPU.MEM_Stage.Data_Memory.memory[22], CPU.MEM_Stage.Data_Memory.memory[21], CPU.MEM_Stage.Data_Memory.memory[20]});
    $fdisplay(outfile, "Data Memory: 0x18 = %d", {CPU.MEM_Stage.Data_Memory.memory[27], CPU.MEM_Stage.Data_Memory.memory[26], CPU.MEM_Stage.Data_Memory.memory[25], CPU.MEM_Stage.Data_Memory.memory[24]});
    $fdisplay(outfile, "Data Memory: 0x1c = %d", {CPU.MEM_Stage.Data_Memory.memory[31], CPU.MEM_Stage.Data_Memory.memory[30], CPU.MEM_Stage.Data_Memory.memory[29], CPU.MEM_Stage.Data_Memory.memory[28]});
	
    $fdisplay(outfile, "\n");
    
    counter = counter + 1;
    
      
end

  
endmodule
