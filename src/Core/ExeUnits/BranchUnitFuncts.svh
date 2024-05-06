`ifndef BRANCH_UNIT_FUNCTS_SVH
`define BRANCH_UNIT_FUNCTS_SVH

package BranchUnitFuncts;
    typedef enum logic[3:0] { 
        BEQ  = 'b0000,
        BNE  = 'b0001,
        BLT  = 'b0100,
        BLTU = 'b0101,
        BGE  = 'b0110,
        BGEU = 'b0111,
        JAL  = 'b0011,
        JALR = 'b0010,
        Unknown = 'b1000
    } Type;
endpackage

`endif