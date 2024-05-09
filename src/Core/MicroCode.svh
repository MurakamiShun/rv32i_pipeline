`ifndef MICRO_CODE_SVH
`define MICRO_CODE_SVH

`include "RV32Consts.svh"
`include "ExeUnits/BranchUnitFuncts.svh"
`include "ExeUnits/ALUFuncts.svh"
`include "ExeUnits/CSRUnitFuncts.svh"
`include "ExeUnits/LoadStoreUnitFuncts.svh"


/* verilator lint_off DECLFILENAME */
package RS1Src;
    typedef enum logic {
        REG,
        ADDR
    } Type;
endpackage

package OP1Src;
    typedef enum logic[1:0] {
        RS1,
        ZERO,
        PC
    } Type;
endpackage

package OP2Src;
    typedef enum logic {
        RS2,
        IMM
    } Type;
endpackage

package ImmAdderSrc;
    typedef enum logic {
        RS1,
        PC
    } Type;
endpackage

package RdSrc;
    typedef enum logic[2:0] {
        ALU,
        CSR,
        LD,
        PC4,
        NotUsed
    } Type;
endpackage

typedef struct packed {
    // depend on inst type
    logic[4:0] rs1_addr;
    logic[4:0] rs2_addr;
    logic[4:0] rd_addr;
    logic rd_en;

    RV32Consts::IntReg imm_data;
    logic[31:0] pc;

    // depend on each operation
    RdSrc::Type rd_src;
    struct packed{
        ALUFuncts::Type funct;
        OP1Src::Type op1_src;
        OP2Src::Type op2_src;
        logic en;
    } alu;
    
    ImmAdderSrc::Type imm_adder_src;

    union packed{
        struct packed{
            LoadStoreUnitFuncts::Type funct;
            LoadStoreUnitBytes::Type bytes;
        } ld_st;
        BranchUnitFuncts::Type br;
        struct packed{
            CSRUnitFuncts::Type funct;
            RS1Src::Type rs1_src;
        }csr;
    } funct;
    logic br_en;
    logic ld_st_en;
    logic csr_en;
    logic jump_en;
} MicroCode;

`endif