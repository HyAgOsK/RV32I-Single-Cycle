// Unidade de controle principal do datapath single-cycle.
module control_unit (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    output logic       reg_write,
    output logic       mem_read,
    output logic       mem_write,
    output logic [1:0] result_src,
    output logic       alu_src,
    output logic       branch,
    output logic       jump,
    output logic       lui,
    output logic [1:0] alu_op,
    output logic       branch_type
);

    localparam logic [6:0] OPCODE_RTYPE  = 7'b0110011;
    localparam logic [6:0] OPCODE_ITYPE  = 7'b0010011;
    localparam logic [6:0] OPCODE_LOAD   = 7'b0000011;
    localparam logic [6:0] OPCODE_STORE  = 7'b0100011;
    localparam logic [6:0] OPCODE_BRANCH = 7'b1100011;
    localparam logic [6:0] OPCODE_JAL    = 7'b1101111;
    localparam logic [6:0] OPCODE_LUI    = 7'b0110111;

    localparam logic [1:0] RESULT_ALU = 2'b00;
    localparam logic [1:0] RESULT_MEM = 2'b01;
    localparam logic [1:0] RESULT_PC4 = 2'b10;

    always_comb begin
        reg_write  = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        result_src = RESULT_ALU;
        alu_src    = 1'b0;
        branch     = 1'b0;
        jump       = 1'b0;
        lui        = 1'b0;
        alu_op     = 2'b00;
        branch_type = 1'b0; // 0 = beq, 1 = bne

        unique case (opcode)
            OPCODE_RTYPE: begin
                reg_write = 1'b1;
                alu_op    = 2'b10;
            end

            OPCODE_ITYPE: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                alu_op    = 2'b10;
            end

            OPCODE_LOAD: begin
                reg_write  = 1'b1;
                mem_read   = 1'b1;
                result_src = RESULT_MEM;
                alu_src    = 1'b1;
                alu_op     = 2'b00; // soma base + deslocamento
            end

            OPCODE_STORE: begin
                mem_write = 1'b1;
                alu_src   = 1'b1;
                alu_op    = 2'b00; // soma base + deslocamento
            end

            OPCODE_BRANCH: begin
                branch      = 1'b1;
                alu_op      = 2'b01; // subtracao para gerar zero
                branch_type = (funct3 == 3'b001); // bne
            end

            OPCODE_JAL: begin
                reg_write  = 1'b1;
                result_src = RESULT_PC4;
                jump       = 1'b1;
            end

            OPCODE_LUI: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                lui       = 1'b1;
                alu_op    = 2'b11; // PASS_B
            end

            default: begin
                // Instrucao nao suportada: todos os sinais permanecem inativos.
            end
        endcase
    end

endmodule
