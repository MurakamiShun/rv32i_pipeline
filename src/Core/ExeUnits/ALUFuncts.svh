`ifndef ALU_FUNCTS_SVH
`define ALU_FUNCTS_SVH

package ALUFuncts;
    typedef enum logic[4:0] { 
        ADD  = 'b00_000,
        SUB  = 'b01_000,
        SLT  = 'b00_010,
        SLTU = 'b00_011,
        AND  = 'b00_111,
        OR   = 'b00_110,
        XOR  = 'b00_100,
        SLL  = 'b00_001,
        SRL  = 'b00_101,
        SRA  = 'b01_101,
        MUL    = 'b10_000,
        MULH   = 'b10_001,
        MULHSU = 'b10_010,
        MULHU  = 'b10_011,
        // DIV  = 'b10_100,
        // DIVU = 'b10_101,
        // REM  = 'b10_110,
        // REMU = 'b10_111,
        Unknown = 'b11_111
    } Type;
endpackage

`endif