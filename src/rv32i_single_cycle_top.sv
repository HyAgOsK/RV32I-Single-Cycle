// Top-level do processador RV32I single-cycle.
module rv32i_single_cycle_top (
    input  logic        clk,
    input  logic        reset,

    output logic [31:0] pc_current,
    output logic [31:0] instruction,
    output logic [31:0] alu_result,
    output logic [31:0] mem_read_data,
    output logic [31:0] write_back_data,
    output logic [31:0] reg_read_data1,
    output logic [31:0] reg_read_data2,
    output logic [31:0] debug_mem_24,

    output logic [6:0]  opcode,
    output logic [4:0]  rd,
    output logic [2:0]  funct3,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [6:0]  funct7,

    output logic        reg_write,
    output logic        mem_read,
    output logic        mem_write,
    output logic [1:0]  result_src,
    output logic        alu_src,
    output logic        branch,
    output logic        jump,
    output logic        lui,
    output logic [1:0]  alu_op,
    output logic        branch_type,
    output logic        branch_taken,
    output logic [3:0]  alu_operation
);

    logic [31:0] pc_next;
    logic [31:0] pc_plus4;
    logic [31:0] imm_i;
    logic [31:0] imm_s;
    logic [31:0] imm_b;
    logic [31:0] imm_u;
    logic [31:0] imm_j;
    logic [31:0] selected_imm;
    logic [31:0] alu_operand_b;
    logic        alu_zero;
    logic        alu_less_than;

    localparam logic [1:0] RESULT_ALU = 2'b00;
    localparam logic [1:0] RESULT_MEM = 2'b01;
    localparam logic [1:0] RESULT_PC4 = 2'b10;

    assign pc_plus4 = pc_current + 32'd4;

    pc u_pc (
        .clk     (clk),
        .reset   (reset),
        .next_pc (pc_next),
        .pc_out  (pc_current)
    );

    instruction_memory u_instruction_memory (
        .addr        (pc_current),
        .instruction (instruction)
    );

    decoder u_decoder (
        .instruction (instruction),
        .opcode      (opcode),
        .rd          (rd),
        .funct3      (funct3),
        .rs1         (rs1),
        .rs2         (rs2),
        .funct7      (funct7)
    );

    immediate_generator u_immediate_generator (
        .instruction  (instruction),
        .opcode       (opcode),
        .imm_i        (imm_i),
        .imm_s        (imm_s),
        .imm_b        (imm_b),
        .imm_u        (imm_u),
        .imm_j        (imm_j),
        .selected_imm (selected_imm)
    );

    control_unit u_control_unit (
        .opcode      (opcode),
        .funct3      (funct3),
        .reg_write   (reg_write),
        .mem_read    (mem_read),
        .mem_write   (mem_write),
        .result_src  (result_src),
        .alu_src     (alu_src),
        .branch      (branch),
        .jump        (jump),
        .lui         (lui),
        .alu_op      (alu_op),
        .branch_type (branch_type)
    );

    register_file u_register_file (
        .clk        (clk),
        .reset      (reset),
        .reg_write  (reg_write),
        .rs1        (rs1),
        .rs2        (rs2),
        .rd         (rd),
        .write_data (write_back_data),
        .read_data1 (reg_read_data1),
        .read_data2 (reg_read_data2)
    );

    alu_control u_alu_control (
        .alu_op        (alu_op),
        .opcode        (opcode),
        .funct3        (funct3),
        .funct7        (funct7),
        .alu_operation (alu_operation)
    );

    assign alu_operand_b = alu_src ? selected_imm : reg_read_data2;

    alu u_alu (
        .a             (reg_read_data1),
        .b             (alu_operand_b),
        .alu_operation (alu_operation),
        .result        (alu_result),
        .zero          (alu_zero),
        .less_than     (alu_less_than)
    );

    data_memory u_data_memory (
        .clk          (clk),
        .mem_read     (mem_read),
        .mem_write    (mem_write),
        .addr         (alu_result),
        .write_data   (reg_read_data2),
        .read_data    (mem_read_data),
        .debug_mem_24 (debug_mem_24)
    );

    always_comb begin
        unique case (result_src)
            RESULT_ALU: write_back_data = alu_result;
            RESULT_MEM: write_back_data = mem_read_data;
            RESULT_PC4: write_back_data = pc_plus4;
            default:    write_back_data = alu_result;
        endcase
    end

    always_comb begin
        branch_taken = 1'b0;

        if (branch) begin
            if (!branch_type) begin
                branch_taken = alu_zero;  // beq
            end else begin
                branch_taken = !alu_zero; // bne
            end
        end
    end

    always_comb begin
        if (jump) begin
            pc_next = pc_current + imm_j;
        end else if (branch_taken) begin
            pc_next = pc_current + imm_b;
        end else begin
            pc_next = pc_plus4;
        end
    end

endmodule
