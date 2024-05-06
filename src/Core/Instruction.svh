`ifndef INSTRUCTION_SVH
`define INSTRUCTION_SVH

typedef union packed {
    logic[31:0] inst32;

    struct packed{
        logic[24:0] unknown; // op[31:7]
        logic[6:0] opcode;  // op[6:0]
    } common;
    struct packed {
        logic[6:0] funct7;  // op[31:25]
        logic[4:0] rs2;     // op[24:20]
        logic[4:0] rs1;     // op[19:15]
        logic[2:0] funct3;  // op[14:12]
        logic[4:0] rd;      // op[11:7]
        logic[6:0] opcode; // op[6:0]
    } Rtype;
    struct packed {
        logic       imm11;   // op[31]
        logic[10:0] imm10_0; // op[30:20]
        logic[4:0]  rs1;     // op[19:15]
        logic[2:0]  funct3;  // op[14:12]
        logic[4:0]  rd;      // op[11:7]
        logic[6:0]  opcode; // op[6:0]
    } Itype;
    struct packed {
        logic      imm11;   // op[31]
        logic[5:0] imm10_5; // op[30:25]
        logic[4:0] rs2;     // op[24:20]
        logic[4:0] rs1;     // op[19:15]
        logic[2:0] funct3;  // op[14:12]
        logic[4:0] imm4_0;  // op[11:7]
        logic[6:0] opcode; // op[6:0]
    } Stype;
    struct packed {
        logic      imm12;   // op[31]
        logic[5:0] imm10_5; // op[30:25]
        logic[4:0] rs2;     // op[24:20]
        logic[4:0] rs1;     // op[19:15]
        logic[2:0] funct3;  // op[14:12]
        logic[3:0] imm4_1;  // op[11:8]
        logic      imm11;   // op[7]
        logic[6:0] opcode; // op[6:0]
    } Btype;
    struct packed {
        logic[19:0]      imm31_12; // op[31:12]
        logic[4:0] rd;       // op[11:7]
        logic[6:0] opcode;  // op[6:0]
    } Utype;
    struct packed {
        logic      imm20;    // op[31]
        logic[9:0] imm10_1;  // op[30:21]
        logic      imm11;    // op[20]
        logic[7:0] imm19_12; // op[19:12]
        logic[4:0] rd;       // op[11:7]
        logic[6:0] opcode;  // op[6:0]
    } Jtype;
    struct packed {
        logic[11:0] csr;    // op[31:20]
        logic[4:0] rs1;     // op[19:15]
        logic[2:0] funct3;  // op[14:12]
        logic[4:0] rd;      // op[11:7]
        logic[6:0] opcode; // op[6:0]
    } CSRtype;
} Instruction;


`endif