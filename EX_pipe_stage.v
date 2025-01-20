`timescale 1ns / 1ps

module EX_pipe_stage(
    input [31:0] id_ex_instr,
    input [31:0] reg1, reg2,
    input [31:0] id_ex_imm_value,
    input [31:0] ex_mem_alu_result,
    input [31:0] mem_wb_write_back_result,
    input id_ex_alu_src,
    input [1:0] id_ex_alu_op,
    input [1:0] Forward_A, Forward_B,
    output [31:0] alu_in2_out,
    output [31:0] alu_result
    );
    
    // Write your code here
    
    wire [3:0] ALU_Control;
    wire [31:0] alu_in1_out;
    wire [31:0] alu_in2_outx;
    wire zero;
    
    mux4 alu_in1_mux(
        .a(reg1), 
        .b(mem_wb_write_back_result), 
        .c(ex_mem_alu_result), 
        .d(0),
        .y(alu_in1_out),
        .sel(Forward_A)
    );
    
    mux4 alu_in2_mux2(
        .a(reg2), 
        .b(mem_wb_write_back_result), 
        .c(ex_mem_alu_result), 
        .d(0),
        .y(alu_in2_out),
        .sel(Forward_B)
    );
    
    mux2 alu_in2_mux4(
        .a(alu_in2_out), 
        .b(id_ex_imm_value),
        .y(alu_in2_outx),
        .sel(id_ex_alu_src)
    );
    
    ALUControl ALUctrl(
        .ALUOp(id_ex_alu_op), 
        .Function(id_ex_instr[5:0]),
        .ALU_Control(ALU_Control)
    );   
    
    ALU alu_block(
        .a(alu_in1_out),  
        .b(alu_in2_outx), 
        .alu_control(ALU_Control),
        .zero(zero), 
        .alu_result(alu_result)
    );
          
endmodule
