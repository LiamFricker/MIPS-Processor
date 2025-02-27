`timescale 1ns / 1ps


module ID_pipe_stage(
    input  clk, reset,
    input  [9:0] pc_plus4,
    input  [31:0] instr,
    input  mem_wb_reg_write,
    input  [4:0] mem_wb_write_reg_addr,
    input  [31:0] mem_wb_write_back_data,
    input  Data_Hazard,
    input  Control_Hazard,
    output [31:0] reg1, reg2,
    output [31:0] imm_value,
    output [9:0] branch_address,
    output [9:0] jump_address,
    output branch_taken,
    output [4:0] destination_reg, 
    output mem_to_reg,
    output [1:0] alu_op,
    output mem_read,  
    output mem_write,
    output alu_src,
    output reg_write,
    output jump
    );
    
    wire reg_dst;
    wire branch;
    
    wire temp_mem_read, temp_mem_write, temp_alu_src, temp_reg_write, temp_mem_to_reg;
    wire [1:0] temp_alu_op;
    // write your code here 
    // Remember that we test if the branch is taken or not in the decode stage. 	
       control control(
            .reset(reset),
            .opcode(instr[31:26]), //[5:0], 
            .mem_to_reg(temp_mem_to_reg),
            .alu_op(temp_alu_op),
            .mem_read(temp_mem_read),
            .mem_write(temp_mem_write),
            .alu_src(temp_alu_src),
            .reg_write(temp_reg_write),
            .branch(branch),
            .jump(jump),
            .reg_dst(reg_dst)
        );
        
        wire [6:0] control_hazard_output;
        
        mux2#(.mux_width(7))Control_Hazard_mux(
            .a({temp_alu_op[1:0],temp_mem_read,temp_mem_write,temp_alu_src,temp_reg_write,temp_mem_to_reg}),
            .b(7'd0),
            .sel(Control_Hazard|~Data_Hazard),
            .y({control_hazard_output})
        );
        
        assign alu_op = control_hazard_output[6:5];
        assign mem_read = control_hazard_output[4];
        assign mem_write = control_hazard_output[3];
        assign alu_src = control_hazard_output[2];
        assign reg_write = control_hazard_output[1];
        assign mem_to_reg = control_hazard_output[0];
        
        
        register_file reg_file(
            .clk(clk), 
            .reset(reset),  
            .reg_write_en(mem_wb_reg_write),  
            .reg_write_dest(mem_wb_write_reg_addr),  //4:0
            .reg_write_data(mem_wb_write_back_data), //31:0
            .reg_read_addr_1(instr[25:21]), //4:0
            .reg_read_addr_2(instr[20:16]),  //4:0
            .reg_read_data_1(reg1), //output 31:0  
            .reg_read_data_2(reg2) //31:0
        );
        
        sign_extend sign_extend(
            .sign_ex_in(instr[15:0]),
            .sign_ex_out(imm_value)
        );
        
        assign branch_taken = (branch && ((reg1 ^ reg2) == 32'b0 ? 1'b1 : 1'b0));
        assign branch_address = pc_plus4 + {imm_value[8:0], 2'b00};
        assign jump_address = {instr[23:0], 2'b00};
        
        mux2 #(.mux_width(5)) destination_mux (
            .a(instr[20:16]),
            .b(instr[15:11]),
            .sel(reg_dst),
            .y(destination_reg)
        );
        
endmodule
