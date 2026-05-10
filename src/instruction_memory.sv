// ROM de instrucoes. O endereco recebido e em bytes, mas a memoria e por palavra.
module instruction_memory #(
    parameter string PROGRAM_FILE = "mem/program.mem",
    parameter int    WORDS        = 256
) (
    input  logic [31:0] addr,
    output logic [31:0] instruction
);

    logic [31:0] memory [0:WORDS-1];

    initial begin : init_rom
        int i;

        for (i = 0; i < WORDS; i = i + 1) begin
            memory[i] = 32'h00000013; // addi x0, x0, 0 (NOP)
        end

        $readmemh(PROGRAM_FILE, memory);
    end

    assign instruction = memory[addr[31:2]];

endmodule
