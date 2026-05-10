// Gera imediatos RV32I ja estendidos para 32 bits.
module immediate_generator (
    input  logic [31:0] instruction,
    input  logic [6:0]  opcode,
    output logic [31:0] imm_i,
    output logic [31:0] imm_s,
    output logic [31:0] imm_b,
    output logic [31:0] imm_u,
    output logic [31:0] imm_j,
    output logic [31:0] selected_imm
);

    localparam logic [6:0] OPCODE_STORE  = 7'b0100011;
    localparam logic [6:0] OPCODE_BRANCH = 7'b1100011;
    localparam logic [6:0] OPCODE_LUI    = 7'b0110111;
    localparam logic [6:0] OPCODE_JAL    = 7'b1101111;

    always_comb begin
        imm_i = {{20{instruction[31]}}, instruction[31:20]};
        imm_s = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
        imm_b = {{19{instruction[31]}}, instruction[31], instruction[7],
                 instruction[30:25], instruction[11:8], 1'b0};
        imm_u = {instruction[31:12], 12'b0};
        imm_j = {{11{instruction[31]}}, instruction[31], instruction[19:12],
                 instruction[20], instruction[30:21], 1'b0};

        unique case (opcode)
            OPCODE_STORE:  selected_imm = imm_s;
            OPCODE_BRANCH: selected_imm = imm_b;
            OPCODE_LUI:    selected_imm = imm_u;
            OPCODE_JAL:    selected_imm = imm_j;
            default:       selected_imm = imm_i;
        endcase
    end

endmodule
