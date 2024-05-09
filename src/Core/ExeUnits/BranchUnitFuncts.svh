`ifndef BRANCH_UNIT_FUNCTS_SVH
`define BRANCH_UNIT_FUNCTS_SVH

package BranchUnitFuncts;
    typedef enum logic[4:0] { 
        BEQ  = 'b0000,
        BNE  = 'b0001,
        BLT  = 'b0100,
        BLTU = 'b0101,
        BGE  = 'b0110,
        BGEU = 'b0111,
        Unknown = 'b1111
    } Type;
endpackage

`endif