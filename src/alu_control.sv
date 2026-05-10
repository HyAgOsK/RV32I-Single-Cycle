// Decodifica a operacao especifica da ALU.
module alu_control (
    input  logic [1:0] alu_op,
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic [3:0] alu_operation
);

    localparam logic [6:0] OPCODE_RTYPE = 7'b0110011;

    localparam logic [3:0] ALU_ADD    = 4'd0;
    localparam logic [3:0] ALU_SUB    = 4'd1;
    localparam logic [3:0] ALU_AND    = 4'd2;
    localparam logic [3:0] ALU_OR     = 4'd3;
    localparam logic [3:0] ALU_XOR    = 4'd4;
    localparam logic [3:0] ALU_SLT    = 4'd5;
    localparam logic [3:0] ALU_PASS_B = 4'd6;

    always_comb begin
        alu_operation = ALU_ADD;

        unique case (alu_op)
            2'b00: alu_operation = ALU_ADD; // load/store
            2'b01: alu_operation = ALU_SUB; // branch
            2'b11: alu_operation = ALU_PASS_B; // lui

            2'b10: begin
                unique case (funct3)
                    3'b000: begin
                        if ((opcode == OPCODE_RTYPE) && funct7[5]) begin
                            alu_operation = ALU_SUB;
                        end else begin
                            alu_operation = ALU_ADD;
                        end
                    end
                    3'b111: alu_operation = ALU_AND;
                    3'b110: alu_operation = ALU_OR;
                    3'b100: alu_operation = ALU_XOR;
                    3'b010: alu_operation = ALU_SLT;
                    default: alu_operation = ALU_ADD;
                endcase
            end

            default: alu_operation = ALU_ADD;
        endcase
    end

endmodule
