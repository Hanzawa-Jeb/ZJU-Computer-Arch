`timescale 1ps/1ps

module HazardDetectionUnit(
    input clk,
    input Branch_ID, rs1use_ID, rs2use_ID,
    input[1:0] hazard_optype_ID,
    input[4:0] rd_EXE, rd_MEM, rs1_ID, rs2_ID, rs2_EXE,
    output PC_EN_IF, reg_FD_stall, reg_FD_flush, reg_DE_flush,
    output forward_ctrl_ls,
    output[1:0] forward_ctrl_A, forward_ctrl_B
);

    //according to the diagram, design the Hazard Detection Unit

    parameter alu_hazard = 2'b01;
    parameter load_hazard = 2'b10;
    parameter store_hazard = 2'b11;

    reg[1:0] hazard_optype_EXE = 2'b00, hazard_optype_MEM = 2'b00;

    always @(posedge clk) begin
        hazard_optype_MEM <= hazard_optype_EXE & {2{~reg_EM_flush}};
        hazard_optype_EXE <= hazard_optype_ID & {2{~reg_DE_flush}};
        // Consider the factor of register flush
    end

    wire rs1_forward_stall = (rd_EXE != 5'b0) && rs1use_ID && (rs1_ID == rd_EXE) && 
    (hazard_optype_ID != store_hazard && hazard_optype_EXE == load_hazard);
    // Only when load-use happens, we need to stall for one cycle, we use the !store hazard as the condition

    wire rs1_forward_1 = (rd_EXE != 5'b0) && rs1use_ID && (rs1_ID == rd_EXE) && (hazard_optype_EXE == alu_hazard);
    // EXE ALU Output
    wire rs1_forward_2 = (rd_MEM != 5'b0) && rs1use_ID && (rs1_ID == rd_MEM) && (hazard_optype_MEM == alu_hazard);
    // MEM ALU Output 
    wire rs1_forward_3 = (rd_MEM != 5'b0) && rs1use_ID && (rs1_ID == rd_MEM) && (hazard_optype_MEM == load_hazard);
    // MEM DMEM Output

    wire rs2_forward_stall = (rd_EXE != 5'b0) && rs2use_ID && (rs2_ID == rd_EXE) && 
    (hazard_optype_ID != store_hazard && hazard_optype_EXE == load_hazard);

    wire rs2_forward_1 = (rd_EXE != 5'b0) && rs2use_ID && (rs2_ID == rd_EXE) && (hazard_optype_EXE == alu_hazard);
    wire rs2_forward_2 = (rd_MEM != 5'b0) && rs2use_ID && (rs2_ID == rd_MEM) && (hazard_optype_MEM == alu_hazard);
    wire rs2_forward_3 = (rd_MEM != 5'b0) && rs2use_ID && (rs2_ID == rd_MEM) && (hazard_optype_MEM == load_hazard);
    // The symmetric operation as rs1, only change the number of the register

    assign forward_ctrl_A = {2{rs1_forward_1}} & alu_hazard |
                            {2{rs1_forward_2}} & load_hazard |
                            {2{rs1_forward_3}} & store_hazard |
                            2'b00;

    assign forward_ctrl_B = {2{rs2_forward_1}} & alu_hazard |
                            {2{rs2_forward_2}} & load_hazard |
                            {2{rs2_forward_3}} & store_hazard |
                            2'b00;
    
    assign forward_ctrl_ls = (rs2_EXE == rd_MEM) && (hazard_optype_EXE == store_hazard) && (hazard_optype_MEM == load_hazard);
    // Specially for load-store hazard, another forwarding circuit

    wire general_stall = rs1_forward_stall || rs2_forward_stall;
    // The general need for stalling

    assign PC_EN_IF = !general_stall;
    // When stall happens, the Instruction Fetch Process should end
    assign reg_FD_stall = general_stall;
    // IFID register should be stalled, as no update allowed
    assign reg_DE_flush = general_stall;
    // IDEXE register should be flushed, as a bubble to insert to the next stage
    
    assign reg_FD_flush = Branch_ID;
    // If branching happened, then we need to flush the IFID reg to fetch instruction another time

    assign reg_EM_flush = 1'b0;

endmodule