// ALU combinacional com as operacoes usadas neste subconjunto RV32I.
module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [3:0]  alu_operation,
    output logic [31:0] result,
    output logic        zero,
    output logic        less_than
);

    localparam logic [3:0] ALU_ADD    = 4'd0;
    localparam logic [3:0] ALU_SUB    = 4'd1;
    localparam logic [3:0] ALU_AND    = 4'd2;
    localparam logic [3:0] ALU_OR     = 4'd3;
    localparam logic [3:0] ALU_XOR    = 4'd4;
    localparam logic [3:0] ALU_SLT    = 4'd5;
    localparam logic [3:0] ALU_PASS_B = 4'd6;

    always_comb begin
        unique case (alu_operation)
            ALU_ADD:    result = a + b;
            ALU_SUB:    result = a - b;
            ALU_AND:    result = a & b;
            ALU_OR:     result = a | b;
            ALU_XOR:    result = a ^ b;
            ALU_SLT:    result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            ALU_PASS_B: result = b;
            default:    result = 32'd0;
        endcase
    end

    assign zero      = (result == 32'd0);
    assign less_than = ($signed(a) < $signed(b));

endmodule
