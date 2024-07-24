`timescale 1ns / 1ps

`define     OP_R            7'b011_0011
`define     OP_B            7'b110_0011
`define     OP_I            7'b001_0011
`define     OP_I_LOAD       7'b000_0011
`define     OP_I_JALR       7'b110_0111
`define     OP_S            7'b010_0011
`define     OP_U_LUI        7'b011_0111
`define     OP_U_AUIPC      7'b001_0111
`define     OP_J_JAL        7'b110_1111

module tb_ctrl_unit;

    // Inputs
    reg                 clk;
    reg     [6:0]       opcode;
    reg     [6:0]       funct7;
    reg     [2:0]       funct3;
    wire    [4:0]       alu_ctrl;
    wire                regwrite;

ctrl_unit control_unit(
    .opcode         (opcode)    ,
    .funct7         (funct7)    ,
    .funct3         (funct3)    ,
    .alu_ctrl       (alu_ctrl)  ,
    .regwrite       (regwrite)  
);

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        opcode = `OP_R;
        {funct7, funct3} = 10'b00_0000_0000;    #10
        {funct7, funct3} = 10'b01_0000_0000;    #10
        {funct7, funct3} = 10'b00_0000_0001;    #10
        {funct7, funct3} = 10'b00_0000_0010;    #10
        {funct7, funct3} = 10'b00_0000_0011;    #10
        {funct7, funct3} = 10'b00_0000_0100;    #10
        {funct7, funct3} = 10'b00_0000_0101;    #10
        {funct7, funct3} = 10'b01_0000_0101;    #10
        {funct7, funct3} = 10'b00_0000_0110;    #10
        {funct7, funct3} = 10'b00_0000_0111;    #10    
        {funct7, funct3} = 10'b00_1111_0111;    #10  

        opcode = `OP_B;
        {funct7, funct3} = 10'b00_1111_0111;    #10

        opcode = `OP_I;
        {funct7, funct3} = 10'b00_0000_0001;    #10
        {funct7, funct3} = 10'b00_0000_0101;    #10
        {funct7, funct3} = 10'b01_0000_0101;    #10
        {funct7, funct3} = 10'bxx_xxxx_x000;    #10
        {funct7, funct3} = 10'bxx_xxxx_x010;    #10
        {funct7, funct3} = 10'bxx_xxxx_x011;    #10
        {funct7, funct3} = 10'bxx_xxxx_x100;    #10
        {funct7, funct3} = 10'bxx_xxxx_x110;    #10
        {funct7, funct3} = 10'bxx_xxxx_x111;    #10   
        {funct7, funct3} = 10'b00_1111_0111;       

        opcode = `OP_I_LOAD;
        {funct7, funct3} = 10'b00_1111_0111;    
    end

    // Dump waveforms
    initial begin
        $dumpfile("tb_ctrl_unit.vcd");
        $dumpvars(0, tb_ctrl_unit);
        #1000
        $finish;
    end

endmodule





module ctrl_unit(
    input   wire    [6:0]   opcode,
    input   wire    [6:0]   funct7,
    input   wire    [2:0]   funct3,
    output  wire    [4:0]   alu_ctrl,
    output  wire            regwrite
);
    wire    [6:0]   i_opcode = opcode;
    wire    [6:0]   i_funct7 = funct7;
    wire    [2:0]   i_funct3 = funct3;
    wire    [4:0]   o_alu_ctrl;
    wire            o_regwrite;
    assign          alu_ctrl = o_alu_ctrl;
    assign          regwrite = o_regwrite;

    alu_det alu_ctrl_sig(
        .opcode     (i_opcode),
        .funct7     (i_funct7),
        .funct3     (i_funct3),
        .alu_ctrl   (o_alu_ctrl)
    );

    rw_det register_wr_sig(
        .opcode     (i_opcode),
        .regwrite   (o_regwrite)
    );
endmodule

module alu_det(
    input   wire    [6:0]   opcode,
    input   wire    [6:0]   funct7,
    input   wire    [2:0]   funct3,
    output  reg     [4:0]   alu_ctrl
);
    always @(*) begin
        case (opcode)
            `OP_R:
                case ({funct7, funct3})
                    10'b0000000_000:    alu_ctrl <= 5'b00000;  //ADD
                    10'b0100000_000:    alu_ctrl <= 5'b10000;  //SUB
                    10'b0000000_001:    alu_ctrl <= 5'b00100;  //SLL
                    10'b0000000_010:    alu_ctrl <= 5'b10111;  //SLT
                    10'b0000000_011:    alu_ctrl <= 5'b11000;  //SLTU
                    10'b0000000_100:    alu_ctrl <= 5'b00011;  //XOR
                    10'b0000000_101:    alu_ctrl <= 5'b00101;  //SRL
                    10'b0100000_101:    alu_ctrl <= 5'b00110;  //SRA
                    10'b0000000_110:    alu_ctrl <= 5'b00010;  //OR
                    10'b0000000_111:    alu_ctrl <= 5'b00001;  //AND
                    default:    alu_ctrl <= 5'bxxxxx;
                endcase
            
            `OP_I:
                case ({funct7, funct3})
                    10'b0000000_001:    alu_ctrl <= 5'b00100;  //SLLI
                    10'b0000000_101:    alu_ctrl <= 5'b00110;  //SRLI
                    10'b0100000_101:    alu_ctrl <= 5'b00110;  //SRAI
                    10'bxxxxxxx_000:    alu_ctrl <= 5'b00000;  //ADDI
                    10'bxxxxxxx_010:    alu_ctrl <= 5'b10111;  //SLTI
                    10'bxxxxxxx_011:    alu_ctrl <= 5'b11000;  //SLTIU
                    10'bxxxxxxx_100:    alu_ctrl <= 5'b00011;  //XORI
                    10'bxxxxxxx_110:    alu_ctrl <= 5'b00010;  //ORI
                    10'bxxxxxxx_111:    alu_ctrl <= 5'b00001;  //ANDI
                    default:    alu_ctrl <= 5'bxxxxx;
                endcase
            
            `OP_I_LOAD,
            `OP_I_JALR,
            `OP_S,
            `OP_U_LUI,
            `OP_U_AUIPC,
            `OP_J_JAL:
                alu_ctrl <= 5'b00000;

            `OP_B:
                alu_ctrl <= 5'b10000;   //SUB

            default: alu_ctrl <= 5'b00000;
        endcase
    end
endmodule

module rw_det(
    input   wire    [6:0]   opcode,
    output  reg             regwrite   
);
    always @(*) begin
        case (opcode)
            `OP_R:          regwrite    <= 1'b1;       
            `OP_B:          regwrite    <= 1'b0;       
            `OP_I:          regwrite    <= 1'b1;       
            `OP_I_LOAD:     regwrite    <= 1'b1;  
            `OP_I_JALR:     regwrite    <= 1'b1;  
            `OP_S:          regwrite    <= 1'b0;       
            `OP_U_LUI:      regwrite    <= 1'b1;   
            `OP_U_AUIPC:    regwrite    <= 1'b1; 
            `OP_J_JAL:      regwrite    <= 1'b1;   
            default:        regwrite    <= 1'b0;
        endcase
    end
endmodule