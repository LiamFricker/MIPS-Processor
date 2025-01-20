`timescale 1ns / 1ps


module mips_32(
    input clk, reset,  
    output[31:0] result
    );
    
// define all the wires here. You need to define more wires than the ones you did in Lab2
    
    wire reg_write, alu_src, mem_read, mem_write, mem_to_reg;
    wire [3:0] ALU_Control;
    wire [5:0] inst_31_26, inst_5_0;
    wire [1:0] alu_op;
    wire branch_taken, jump;
    
    wire [9:0] jump_address;
    wire [9:0] branch_address;
    
    wire en, flush;
        
    wire [9:0] pc_plus4;
    wire [31:0] instr;
    wire [4:0] write_reg_addr;
    wire [31:0] write_back_data;
    wire [31:0] reg1, reg2;
    wire [31:0] imm_value;
    wire [31:0] alu_in2;
    wire zero;
    wire [31:0] alu_result;
    wire [31:0] mem_read_data;
    
    wire [4:0] destination_reg;
    
    wire [9:0] if_id_pc_plus4;
    wire [31:0] if_id_instr;
   
    wire [31:0] id_ex_instr;
    wire [31:0] id_ex_reg1, id_ex_reg2;
    wire [31:0] id_ex_imm_value;
    wire [1:0] id_ex_alu_op;
    wire id_ex_reg_write, id_ex_alu_src, id_ex_mem_read, id_ex_mem_write, id_ex_mem_to_reg;
    wire [4:0] id_ex_destination_reg;
    
    wire [31:0] alu_in2_out;
    
    wire [31:0] ex_mem_instr;
    wire [4:0] ex_mem_destination_reg;
    wire [31:0] ex_mem_alu_result;
    wire [31:0] ex_mem_alu_in2_out;
    wire ex_mem_mem_to_reg, ex_mem_mem_read, ex_mem_mem_write, ex_mem_reg_write;

    wire [31:0] mem_wb_alu_result;// = 32'b0;
    wire [31:0] mem_wb_mem_read_data;//  = 32'b0;
    wire mem_wb_mem_to_reg;// = 1'b0; 
    wire mem_wb_reg_write;// = 1'b0;
    wire [4:0] mem_wb_destination_reg;// = 5'b0;

    wire [1:0] Forward_A;
    wire [1:0] Forward_B;
    
    
// Build the pipeline as indicated in the lab manual

///////////////////////////// Instruction Fetch    
    // Complete your code here      
    IF_pipe_stage IF_stage(
        .clk(clk), //Input
        .reset(reset),
        .en(en),
        .branch_address(branch_address),
        .jump_address(jump_address),
        .branch_taken(branch_taken),
        .jump(jump),
        .pc_plus4(pc_plus4), //Output
        .instr(instr)
    );
    
    wire [41:0] IF_ID_output;     
                
///////////////////////////// IF/ID registers
    // Complete your code here
    pipe_reg_en #(.WIDTH(42)) IF_ID_instance(
        .clk(clk), //Input
        .reset(reset),
        .en(en),
        .flush(flush),
        .d({pc_plus4, instr}), //pc_plus4[9:0], instr[31:0]
        .q(IF_ID_output)//Output
    );
    assign if_id_pc_plus4 = IF_ID_output[41:32];
    assign if_id_instr = IF_ID_output[31:0];
    
///////////////////////////// Instruction Decode 
	// Complete your code here
    ID_pipe_stage ID_stage(
        .clk(clk), //Input
        .reset(reset),
        .pc_plus4(if_id_pc_plus4),
        .instr(if_id_instr),
        .mem_wb_reg_write(mem_wb_reg_write),
        .mem_wb_write_reg_addr(mem_wb_destination_reg),
        .mem_wb_write_back_data(write_back_data),
        .Data_Hazard(en),
        .Control_Hazard(flush),
        .reg1(reg1), //Output
        .reg2(reg2),
        .imm_value(imm_value),
        .branch_address(branch_address),
        .jump_address(jump_address),
        .branch_taken(branch_taken),
        .destination_reg(destination_reg), 
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .mem_read(mem_read),  
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .jump(jump)
    );
      
    wire [139:0] ID_EX_output;  
             
///////////////////////////// ID/EX registers 
	// Complete your code here  //32 + 32+ 32+ 32 + 5 + 2 + 1 + 1 + 1 + 1 + 1
    pipe_reg #(.WIDTH(140)) ID_EX_instance(
        .clk(clk), //Input
        .reset(reset),
        .d({if_id_instr, reg1, reg2, imm_value, destination_reg, mem_to_reg, alu_op, mem_read, mem_write, alu_src, reg_write}),
        .q(ID_EX_output) //Output
    );
    
    assign id_ex_instr = ID_EX_output[139:108];
    assign id_ex_reg1 = ID_EX_output[107:76];
    assign id_ex_reg2 = ID_EX_output[75:44];
    assign id_ex_imm_value = ID_EX_output[43:12];
    assign id_ex_destination_reg = ID_EX_output[11:7];
    assign id_ex_mem_to_reg = ID_EX_output[6];
    assign id_ex_alu_op = ID_EX_output[5:4];
    assign id_ex_mem_read = ID_EX_output[3];
    assign id_ex_mem_write = ID_EX_output[2];
    assign id_ex_alu_src = ID_EX_output[1];
    assign id_ex_reg_write = ID_EX_output[0];
    

///////////////////////////// Hazard_detection unit
	// Complete your code here    
    Hazard_detection Hazard_stage(
        .id_ex_mem_read(id_ex_mem_read), //Input
        .id_ex_destination_reg(id_ex_destination_reg),
        .if_id_rs(if_id_instr[25:21]), 
        .if_id_rt(if_id_instr[20:16]),
        .branch_taken(branch_taken),
        .jump(jump),
        .Data_Hazard(en), //Output
        .IF_Flush(flush)
    );
           
///////////////////////////// Execution    
	// Complete your code here
	EX_pipe_stage EX_stage(
        .id_ex_instr(id_ex_instr), //Input
        .reg1(id_ex_reg1), 
        .reg2(id_ex_reg2),
        .id_ex_imm_value(id_ex_imm_value),
        .ex_mem_alu_result(ex_mem_alu_result),
        .mem_wb_write_back_result(write_back_data),
        .id_ex_alu_src(id_ex_alu_src),
        .id_ex_alu_op(id_ex_alu_op),
        .Forward_A(Forward_A), 
        .Forward_B(Forward_B),
        .alu_in2_out(alu_in2_out), //Ouput
        .alu_result(alu_result)
    );
        
///////////////////////////// Forwarding unit
	// Complete your code here 
    EX_Forwarding_unit Forwarding_stage(
        .ex_mem_reg_write(ex_mem_reg_write), //Input
        .ex_mem_write_reg_addr(ex_mem_destination_reg),
        .id_ex_instr_rs(id_ex_instr[25:21]),
        .id_ex_instr_rt(id_ex_instr[20:16]),
        .mem_wb_reg_write(mem_wb_reg_write),
        .mem_wb_write_reg_addr(mem_wb_destination_reg),
        .Forward_A(Forward_A), //Ouput
        .Forward_B(Forward_B)
    );
   
    wire [104:0] EX_MEM_output;
     
///////////////////////////// EX/MEM registers
	// Complete your code here 
    pipe_reg #(.WIDTH(105)) EX_MEM_instance( //32 + 5 + 32 + 32 + 4 =  105
        .clk(clk), //Input
        .reset(reset),
        .d({id_ex_instr, id_ex_destination_reg, alu_result, alu_in2_out, id_ex_mem_to_reg, id_ex_mem_read, id_ex_mem_write, id_ex_reg_write}),
        .q(EX_MEM_output) //Output
    );

    assign ex_mem_instr = EX_MEM_output[104:73];
    assign ex_mem_destination_reg = EX_MEM_output[72:68];
    assign ex_mem_alu_result = EX_MEM_output[67:36];
    assign ex_mem_alu_in2_out = EX_MEM_output[35:4];
    assign ex_mem_mem_to_reg = EX_MEM_output[3];
    assign ex_mem_mem_read = EX_MEM_output[2];
    assign ex_mem_mem_write = EX_MEM_output[1];
    assign ex_mem_reg_write = EX_MEM_output[0];
    
    
///////////////////////////// memory    
	// Complete your code here
     data_memory data_mem(
        .clk(clk), //Input
        .mem_access_addr(ex_mem_alu_result),
        .mem_write_data(ex_mem_alu_in2_out),
        .mem_write_en(ex_mem_mem_write),
        .mem_read_en(ex_mem_mem_read),
        .mem_read_data(mem_read_data) //Output
    );
    
    wire [70:0] MEM_WB_output;
    
///////////////////////////// MEM/WB registers  
	// Complete your code here
    pipe_reg #(.WIDTH(71)) MEM_WB_instance( //32 + 32 + 1 + 1+ 5
        .clk(clk), //Input
        .reset(reset),
        .d({ex_mem_alu_result, mem_read_data, ex_mem_mem_to_reg, ex_mem_reg_write, ex_mem_destination_reg}),
        .q(MEM_WB_output) //Output
    );
    assign mem_wb_alu_result = MEM_WB_output[70:39];
    assign mem_wb_mem_read_data = MEM_WB_output[38:7];
    assign mem_wb_mem_to_reg = MEM_WB_output[6];
    assign mem_wb_reg_write = MEM_WB_output[5];
    assign mem_wb_destination_reg = MEM_WB_output[4:0];
    
///////////////////////////// writeback    
	// Complete your code here
    assign write_back_data = mem_wb_mem_to_reg ? mem_wb_mem_read_data : mem_wb_alu_result; //mem_wb_alu_result: mem_wb_mem_read_data;

    
endmodule
