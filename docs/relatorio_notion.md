# Relatório Ténico RV32I Single-Cycle

<aside>

Feito por: Hyago Vieira Lemes Barbosa Silva

e-mail: [hyago.silva@mtel.inatel.br](mailto:hyago.silva@mtel.inatel.br) | [hyagobora@gmail.com](mailto:hyagobora@gmail.com) 

</aside>

## Objetivo do projeto

Implementar um processador RISC-V RV32I de 32 bits, single-cycle, em SystemVerilog, capaz de executar um subconjunto essencial de instrucoes R-type, I-type, load/store, branch, jump e U-type.

### Dados:

- Nome: Hyago Vieira Lemes Barbosa Silva
- N = 24
- A = N + 4 = 28
- B = N + 2 = 26
- C = 4 * N = 96
- MEM_ADDR = 4 * N = 96
- Como a memoria e enderecada por palavra, o endereco 96 acessa `memory[96 >> 2] = memory[24]`. Ou seja basicamente em 32 bits, eu pego 96 desloco de 2, eu divido por 4, por isso memory[24].

## Arquitetura single-cycle

O processador executa cada instrucao em um unico ciclo de clock. Em um ciclo, a instrucao e buscada, decodificada, os registradores sao lidos, a ALU executa a operacao, a memoria de dados pode ser acessada e o resultado pode ser escrito no banco de registradores.

O Program Counter inicia em zero apos reset. Em execucao normal, o proximo PC e `PC + 4`. Para branch tomado, o proximo PC e `PC + imediato B-type`. Para `jal`, o proximo PC e `PC + imediato J-type`, e `PC + 4` e salvo em `rd`.

## Modulos implementados

- `pc.sv`: registrador do Program Counter com reset para zero.
- `instruction_memory.sv`: ROM carregada com `$readmemh("mem/program.mem")`.
- `decoder.sv`: extrai `opcode`, `rd`, `funct3`, `rs1`, `rs2` e `funct7`.
- `immediate_generator.sv`: gera imediatos I, S, B, U e J com extensao correta.
- `control_unit.sv`: gera sinais de controle do datapath.
- `alu_control.sv`: escolhe a operacao da ALU usando `alu_op`, `opcode`, `funct3` e `funct7`.
- `alu.sv`: executa ADD, SUB, AND, OR, XOR, SLT signed e PASS_B.
- `register_file.sv`: banco com 32 registradores, duas leituras assincronas, escrita sincrona e `x0` fixo em zero.
- `data_memory.sv`: RAM de dados com suporte a `lw` e `sw`.
- `rv32i_single_cycle_top.sv`: integra todos os blocos e implementa next PC e write-back.
- `tb_rv32i_single_cycle.sv`: testbench com clock, reset, VCD, displays e verificacoes automaticas.

### Esquemático

Usando VIVADO.

[schematic.pdf](attachment:b09d1997-0e60-4114-85cd-216341e1d1aa:schematic.pdf)

![image.png](attachment:c11c8de7-120e-406a-911c-5789753ed764:image.png)

## Instrucoes suportadas

R-type:

- `add`
- `sub`
- `and`
- `or`
- `xor`
- `slt`

I-type:

- `addi`
- `andi`
- `ori`
- `xori`
- `slti`

Load/store:

- `lw`
- `sw`

Branch/jump:

- `beq`
- `bne`
- `jal`

U-type:

- `lui`

## Programa de teste

O arquivo `mem/program.mem` contem o programa abaixo em hexadecimal, uma instrucao por linha:

```
01c00093
01a00113
002081b3
40208233
0020f2b3
0020e333
0020c3b3
00112433
06302023
06002483
00348463
00000513
00100513
008005ef
06300613
06000693
```

Esse programa calcula operacoes com A = 28 e B = 26, grava o resultado da soma na memoria, le de volta, testa `beq`, testa `jal` e finaliza gravando C = 96 em `x13`.

## Valores finais esperados

- `x1 = 28`
- `x2 = 26`
- `x3 = 54`
- `x4 = 2`
- `x5 = 24`
- `x6 = 30`
- `x7 = 6`
- `x8 = 1`
- `x9 = 54`
- `x10 = 1`
- `x11 = 56`
- `x12 = 0`
- `x13 = 96`
- `memory[24] = 54`

Tambem e esperado que o `beq` no endereco 40 seja tomado e que o `jal` no endereco 52 pule a instrucao no endereco 56.

## Execução da simulação

Usando ModellSIM

O testbench gera o arquivo de waveform:

## O que observar na waveform

Sinais importantes:

- `pc_current`: sequencia normal de PC e desvios.
- `instruction`: instrucao buscada na ROM.
- `reg_write`, `mem_read`, `mem_write`, `branch`, `branch_taken`, `jump`: sinais de controle.
- `alu_result`: resultado da ALU ou endereco calculado para memoria.
- `mem_read_data`: dado lido por `lw`.
- `write_back_data`: valor escrito em `rd`.
- `debug_mem_24`: posicao `memory[24]`, que deve receber 54.

Durante o `beq`, `branch_taken` deve ficar em 1. Durante o `jal`, `jump` deve ficar em 1 e o PC deve ir para o endereco final, sem executar a instrucao que escreveria 99 em `x12`.