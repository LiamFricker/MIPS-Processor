`timescale 1ns / 1ps


module IF_pipe_stage(
    input clk, reset,
    input en,
    input [9:0] branch_address,
    input [9:0] jump_address,
    input branch_taken,
    input jump,
    output [9:0] pc_plus4,
    output [31:0] instr
    );
    
    reg [9:0] pc;
    wire [9:0] temp_pc;
// write your code here
    /*
   always @(posedge clk or posedge reset)  
    begin   
        if(reset)   
           pc <= 10'b0000000000;  
        else if (en)
            begin
            if(jump == 1'b1)
                pc <= {jump_address[8:0], 2'b00};
            else if(branch_taken == 1'b1 && jump != 1'b1)
                pc <= pc_plus4 + {branch_address[8:0], 2'b00};
            else  
               pc <= pc_plus4;
            end  
    end  
 
    assign pc_plus4 = pc + 10'b0000000100;
        
    instruction_mem inst_mem (
        .read_addr(pc),
        .data(instr));
   */
   ///*
   always @(posedge clk or posedge reset)  
   begin   
        if(reset)   
            pc <= 10'b0000000000;
        
        else if (en)
            pc <= temp_temp_pc;    
    end
   
    
    
    //assign temp_pc = pc;
    
    mux2 #(.mux_width(10)) branch_mux (
        .a(pc_plus4),
        .b(branch_address),
        .sel(branch_taken),
        .y(temp_pc));
    wire [9:0] temp_temp_pc;
    
    mux2 #(.mux_width(10)) jump_mux (
        .a(temp_pc),
        .b(jump_address),
        .sel(jump),
        .y(temp_temp_pc)); 
    
    assign pc_plus4 = pc + 10'b0000000100; 
        
    //assign pc_plus4 = temp_pc + 10'b0000000100;
    instruction_mem inst_mem (
        .read_addr(pc),
        .data(instr));
    //*/             
endmodule
