`timescale 1ns/1ps

module tb_rv32i_single_cycle;

    logic clk;
    logic reset;

    logic [31:0] pc_current;
    logic [31:0] instruction;
    logic [31:0] alu_result;
    logic [31:0] mem_read_data;
    logic [31:0] write_back_data;
    logic [31:0] reg_read_data1;
    logic [31:0] reg_read_data2;
    logic [31:0] debug_mem_24;
    logic [6:0]  opcode;
    logic [4:0]  rd;
    logic [2:0]  funct3;
    logic [4:0]  rs1;
    logic [4:0]  rs2;
    logic [6:0]  funct7;
    logic        reg_write;
    logic        mem_read;
    logic        mem_write;
    logic [1:0]  result_src;
    logic        alu_src;
    logic        branch;
    logic        jump;
    logic        lui;
    logic [1:0]  alu_op;
    logic        branch_type;
    logic        branch_taken;
    logic [3:0]  alu_operation;

    int errors;
    logic saw_branch_taken;
    logic saw_jal;
    logic saw_x12_pc;

    rv32i_single_cycle_top dut (
        .clk             (clk),
        .reset           (reset),
        .pc_current      (pc_current),
        .instruction     (instruction),
        .alu_result      (alu_result),
        .mem_read_data   (mem_read_data),
        .write_back_data (write_back_data),
        .reg_read_data1  (reg_read_data1),
        .reg_read_data2  (reg_read_data2),
        .debug_mem_24    (debug_mem_24),
        .opcode          (opcode),
        .rd              (rd),
        .funct3          (funct3),
        .rs1             (rs1),
        .rs2             (rs2),
        .funct7          (funct7),
        .reg_write       (reg_write),
        .mem_read        (mem_read),
        .mem_write       (mem_write),
        .result_src      (result_src),
        .alu_src         (alu_src),
        .branch          (branch),
        .jump            (jump),
        .lui             (lui),
        .alu_op          (alu_op),
        .branch_type     (branch_type),
        .branch_taken    (branch_taken),
        .alu_operation   (alu_operation)
    );

    always #5 clk = ~clk;

    task automatic check_value(input string name, input logic [31:0] got, input logic [31:0] expected);
        begin
            if (got !== expected) begin
                $error("%s esperado=%0d (0x%08h), obtido=%0d (0x%08h)",
                       name, expected, expected, got, got);
                errors++;
            end else begin
                $display("OK: %s = %0d (0x%08h)", name, got, got);
            end
        end
    endtask

    always @(negedge clk) begin
        if (!reset) begin
            $display("PC=%08h INSTR=%08h OP=%02h rs1=x%0d(%0d) rs2=x%0d(%0d) rd=x%0d ",
                     pc_current, instruction, opcode, rs1, reg_read_data1, rs2, reg_read_data2, rd);
            $display("  ctrl: reg_write=%0b mem_read=%0b mem_write=%0b alu_src=%0b result_src=%0b branch=%0b b_taken=%0b jump=%0b lui=%0b",
                     reg_write, mem_read, mem_write, alu_src, result_src, branch, branch_taken, jump, lui);
            $display("  alu: op=%0d result=%0d | mem_read_data=%0d mem[24]=%0d wb=%0d",
                     alu_operation, alu_result, mem_read_data, debug_mem_24, write_back_data);

            if ((pc_current == 32'd40) && branch_taken) begin
                saw_branch_taken = 1'b1;
            end

            if ((pc_current == 32'd52) && jump) begin
                saw_jal = 1'b1;
            end

            if (pc_current == 32'd56) begin
                saw_x12_pc = 1'b1;
            end
        end
    end

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        errors = 0;
        saw_branch_taken = 1'b0;
        saw_jal = 1'b0;
        saw_x12_pc = 1'b0;

        $dumpfile("tb/rv32i_single_cycle.vcd");
        $dumpvars(0, tb_rv32i_single_cycle);

        repeat (2) @(posedge clk);
        reset = 1'b0;

        repeat (20) @(posedge clk);
        #1;

        $display("\nRegistradores finais:");
        $display("x1  = %0d", dut.u_register_file.regs[1]);
        $display("x2  = %0d", dut.u_register_file.regs[2]);
        $display("x3  = %0d", dut.u_register_file.regs[3]);
        $display("x4  = %0d", dut.u_register_file.regs[4]);
        $display("x5  = %0d", dut.u_register_file.regs[5]);
        $display("x6  = %0d", dut.u_register_file.regs[6]);
        $display("x7  = %0d", dut.u_register_file.regs[7]);
        $display("x8  = %0d", dut.u_register_file.regs[8]);
        $display("x9  = %0d", dut.u_register_file.regs[9]);
        $display("x10 = %0d", dut.u_register_file.regs[10]);
        $display("x11 = %0d", dut.u_register_file.regs[11]);
        $display("x12 = %0d", dut.u_register_file.regs[12]);
        $display("x13 = %0d", dut.u_register_file.regs[13]);
        $display("memory[24] = %0d", dut.u_data_memory.memory[24]);

        check_value("x1",  dut.u_register_file.regs[1],  32'd28);
        check_value("x2",  dut.u_register_file.regs[2],  32'd26);
        check_value("x3",  dut.u_register_file.regs[3],  32'd54);
        check_value("x4",  dut.u_register_file.regs[4],  32'd2);
        check_value("x5",  dut.u_register_file.regs[5],  32'd24);
        check_value("x6",  dut.u_register_file.regs[6],  32'd30);
        check_value("x7",  dut.u_register_file.regs[7],  32'd6);
        check_value("x8",  dut.u_register_file.regs[8],  32'd1);
        check_value("x9",  dut.u_register_file.regs[9],  32'd54);
        check_value("x10", dut.u_register_file.regs[10], 32'd1);
        check_value("x11", dut.u_register_file.regs[11], 32'd56);
        check_value("x12", dut.u_register_file.regs[12], 32'd0);
        check_value("x13", dut.u_register_file.regs[13], 32'd96);
        check_value("memory[24]", dut.u_data_memory.memory[24], 32'd54);

        if (!saw_branch_taken) begin
            $error("Branch beq no endereco 40 nao foi observado como tomado.");
            errors++;
        end else begin
            $display("OK: branch beq foi tomado.");
        end

        if (!saw_jal) begin
            $error("jal no endereco 52 nao foi observado.");
            errors++;
        end else begin
            $display("OK: jal foi executado.");
        end

        if (saw_x12_pc) begin
            $error("PC passou pelo endereco 56; a instrucao addi x12 deveria ser pulada.");
            errors++;
        end else begin
            $display("OK: instrucao de x12 foi pulada pelo jal.");
        end

        if (errors == 0) begin
            $display("\nTESTE PASSOU: RV32I single-cycle executou o programa corretamente.");
        end else begin
            $display("\nTESTE FALHOU: %0d erro(s).", errors);
        end

        $finish;
    end

endmodule
