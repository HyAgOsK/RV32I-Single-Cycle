// RAM de dados com palavras de 32 bits. Endereco de entrada em bytes.
module data_memory #(
    parameter int WORDS = 256
) (
    input  logic        clk,
    input  logic        mem_read,
    input  logic        mem_write,
    input  logic [31:0] addr,
    input  logic [31:0] write_data,
    output logic [31:0] read_data,
    output logic [31:0] debug_mem_24
);

    logic [31:0] memory [0:WORDS-1];

    initial begin : init_ram
        int i;

        for (i = 0; i < WORDS; i = i + 1) begin
            memory[i] = 32'd0;
        end
    end

    assign read_data    = mem_read ? memory[addr[31:2]] : 32'd0;
    assign debug_mem_24 = memory[24];

    always @(posedge clk) begin
        if (mem_write) begin
            memory[addr[31:2]] <= write_data;
        end
    end

endmodule
