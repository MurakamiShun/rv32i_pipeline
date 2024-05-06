`ifndef ALU_FUNCTS_SVH
`define ALU_FUNCTS_SVH

package ALUFuncts;
    typedef enum logic[3:0] { 
        ADD  = 'b0000,
        SUB  = 'b1000,
        SLT  = 'b0010,
        SLTU = 'b0011,
        AND  = 'b0111,
        OR   = 'b0110,
        XOR  = 'b0100,
        SLL  = 'b0001,
        SRL  = 'b0101,
        SRA  = 'b1101,
        Unknown = 'b1111
    } Type;
endpackage

`endif